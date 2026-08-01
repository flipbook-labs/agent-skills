# Sandboxed Storyteller React crash (2026-07-19)

**Status:** Resolved on Storyteller branch `perf/store-story-loading` (#144), commit `5f40c7e`. Related follow-ups filed: storybook double-load at discovery startup (pre-existing, reproduces on main), module-loader trailing-comment wrapping bug, Flipbook prune-step cache-skip.

**Companion skills:** `moduleloader-sandboxing` (the model this incident produced), org `instrumented-debugging` (the process discipline it enforced).

## Symptom

In Flipbook's dev place (plugin + Rojo-synced codebase), opening any FlipbookCore React story crashed with:

```
Error: attempt to index nil with 'useState'
...Foundation.Providers.Style.StyleProvider ... StyleSheetContextWrapper
```

Stories with no dependencies rendered fine. `main` Storyteller did not crash; the `#144` branch did. Cloud CI was fully green throughout — the entire class is invisible at O2 where Charm's freeze is off and nothing evaluates Storyteller through a sandbox.

## Dead theories, in order, and what killed each

**1. Charm freeze regression.** The #144 review had removed in-store freeze exclusions; the error superficially matched #132's documented symptom (freeze reaching React internals). Exclusions were reinstated with a red-gated spec — a real hardening, but the crash survived. *Killed by: the fix not fixing it.* (The reinstatement stands on its own merits.)

**2. Duplicate Flipbook from contaminated builds.** The prod plugin was found to ship a second FlipbookCore storybook because incremental builds cache-skipped the prune step — a real bug (filed), and it genuinely explained mixed plugin/synced-copy stack frames in early traces. A clean build removed the duplicate; the crash survived. *Killed by: the control build still crashing.*

**3. Release-time loader clearing.** The record store cleared its shared ModuleLoader when the last request released; theory: a mounted tree lazily requiring through a cleared registry re-evaluates React fresh. Plausible mechanism, matched a documented caveat — but instrumentation showed no release/cleanup activity in the crash window at all. *Killed by: lifecycle probes staying silent while the crash fired.*

**4. Loader-identity break in the record pipeline.** Identity probes proved the opposite: `freshStorybook: true`, storybook React == story packages == renderer, `mapStory` world-consistent. The mounted story's own wrapper rendered with a healthy dispatcher. *Killed by: every printed identity matching.*

A fifth false conclusion deserves its own line: **"the record store never runs"** — reached because two of three probe patches had silently no-op'd (unasserted anchors). The probes were missing, not the execution. Assert every scripted patch; verify probes shipped into the artifact.

## Root cause

Flipbook's own stories transitively require Storyteller (`ContextProviders` → `StorytellerProvider`), so each story world evaluates a **complete sandboxed Storyteller copy**. The story tree's provider/hooks **started** that copy. Its discovery then re-evaluated all eleven storybooks' React/Foundation package graphs in fresh loaders on a self-sustaining loop (~300 ms per sweep: publish → subscribed story tree re-renders → provider restart → next sweep). Components from those short-lived worlds reached a live tree's async render pass: reconciler from one world, `StyleSheetContextWrapper` from another, dispatcher nil, commit aborted — blank story plus one error.

Why main appeared immune while #144 crashed was never fully isolated — the differences in hook architecture changed which store's publishes the story tree subscribed to — and became moot once sandboxed copies were made inert, which removes the entire mechanism on any branch.

## The discriminating evidence

- **Log attribution**: native prints attribute to real script paths (`- StyleProvider:50`); sandbox prints mis-attribute to the loadstring host (`- SchedulerHostConfig.default:*`). One re-read of an existing log under this lens revealed a *sandboxed* Storyteller running discovery sweeps — the pivotal observation, available all along.
- **Identity fingerprints** (`tostring(React)` per evaluation) separated worlds that chunk names could not.
- **A dispatcher-nil guard + traceback** inside the failing component fired only at death and showed a top-level scheduled root with zero application frames — eliminating every "the story tree pulled it in via X" theory.
- **Engineer topology corrections** at three separate points ("two Flipbooks are present", "stack traces get wonky with ModuleLoader", "Storyteller is evaluated in the story's sandbox and shouldn't be doing work") each redirected the investigation faster than any probe.

## Fix

Sandboxed Storyteller copies do no work (Storyteller `5f40c7e`):

- `start()` no-ops under ModuleLoader, detected via the metatabled `_G` proxy (`getmetatable(_G) ~= nil`). A `require`-closure probe was rejected: Jest also wraps require and the suite went red.
- `StorytellerStore.instance` created lazily on first access (spec-pinned, red-gated).
- `StorytellerContext` resolves the instance at render/hook time, not module scope.

## Verdicts

- **Do not** re-enable any work in sandboxed Storyteller copies without solving cross-world component leakage first.
- **Do not** diagnose `useState`-nil crashes by reading code paths; fingerprint instance identities first. The code can be provably self-consistent while the tree is not.
- The `_G`-metatable probe is a stopgap; a first-class sandbox-detection API in module-loader is the durable form.
- Cloud green ≠ Studio green for anything touching sandboxes or Charm's freeze: Studio verification is part of done for this area.
