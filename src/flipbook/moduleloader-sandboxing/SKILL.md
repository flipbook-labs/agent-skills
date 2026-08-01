---
name: moduleloader-sandboxing
description: "The ModuleLoader sandbox model: worlds, the same-loader invariant, why two React instances crash, environment detection, and how to debug cross-world failures. Use when: working on story/storybook loading, debugging 'attempt to index nil with useState' or silently-blank stories, reasoning about what a sandboxed module can see, or instrumenting code that runs under ModuleLoader."
type: knowledge
---

# ModuleLoader Sandboxing

Storyteller loads Story and Storybook modules through [ModuleLoader](https://github.com/flipbook-labs/module-loader) sandboxes. Agents consistently build wrong mental models of this boundary and burn hours chasing phantom bugs. This skill is the model, the invariants, and the debugging moves. The July 2026 crash hunt that produced it is written up in `failure-archaeology`'s incident `2026-07-19-sandboxed-storyteller-react-crash.md`.

## The world model

One ModuleLoader instance is one **world**:

- Every module a loader requires is **loadstring-evaluated from its Source**, producing a fresh module table per world. Two loaders requiring the same ModuleScript produce two distinct evaluations with distinct identities.
- The loader's registry is **instance-keyed**: within one world, every require of the same ModuleScript instance returns the same evaluation. There is no name-based lookup and no cross-world sharing.
- Chunks receive `script` (the original ModuleScript instance) and `require` (the loader's own closure) as parameters. `script`-relative navigation walks the **real** DataModel; link files (`Packages/React.lua`, Rotriever links) therefore resolve to the same target instances in every world — identity converges *within* a world, never across worlds.
- Chunk names are set to `GetFullName()` of the source instance. Two evaluations of the same file are **indistinguishable by chunk name** — only table identities (`tostring(module)`) distinguish worlds.
- The wrapper joins the source and its closing tokens with spaces: a module whose source ends in a comment without a trailing newline swallows the closing `end end` and becomes a syntax error (known module-loader bug).

## The same-loader invariant

A story and the storybook whose closures wrap it must be evaluated by the **same loader**. A storybook's `mapStory` closes over module-scope requires (React, provider components); if those come from world A while the story's own requires come from world B, one tree carries two React instances and rendering dies (see below). `loadStoryModule` guarantees the invariant by re-requiring the storybook through the story's loader before evaluating the story ("cram the storybook into the loader"). Never bypass this by passing a storybook loaded elsewhere directly into render paths.

## Two React instances: the failure signature

`attempt to index nil with 'useState'` (or any hook) is **always** an instance mismatch: a component calling hooks on React B while a reconciler built with React A renders it. React A's `renderWithHooks` set the dispatcher on A's shared internals; B's are untouched. Corollaries:

- The crash aborts the whole commit — a consistent-looking tree that mounted fine can end with zero descendants because one foreign component poisoned the pass.
- The error is caught by React's error boundary and rethrown through the scheduler, so top-of-stack frames point at `SchedulerHostConfig`, not the culprit.
- A silently-blank story with no error can be the same class: check whether the commit produced descendants before assuming the pipeline failed.

## Storyteller inside a sandbox

Story modules whose dependency graphs include Storyteller (Flipbook's own stories do, via `ContextProviders` → `StorytellerProvider`) evaluate a **complete Storyteller copy inside their world**. That copy must stay inert:

- `StorytellerStore.start()` no-ops when sandboxed. If it ran, its discovery would spawn a fresh loader per storybook, re-evaluating entire React/Foundation graphs on a self-sustaining publish → re-render → restart loop, feeding short-lived worlds' components into live trees.
- `StorytellerStore.instance` is created lazily on first access, and `StorytellerContext` resolves it at render/hook time — requiring Storyteller transitively costs nothing.
- Sandboxed hooks still work as a library: they return empty-but-stable data.

## Environment detection

| Environment | `require` | `_G` | Charm freeze |
| --- | --- | --- | --- |
| Native (plugin/runtime) | C builtin | bare global table | on in Studio |
| ModuleLoader sandbox | Lua closure (loader param) | **metatabled proxy** | on in Studio |
| Jest (cloud tests) | Lua closure (Jest runtime) | bare global table | off (O2) |

- The reliable sandbox probe is `getmetatable(_G) ~= nil`. A `require`-based probe (`debug.info(require, "s") ~= "[C]"`) **misfires under Jest**, which also wraps require.
- Cloud tests run at O2 where Charm's freeze is disabled — the entire Studio freeze/sandbox bug class is **invisible to CI**. A green suite proves nothing about these behaviors; Studio verification is part of done.

## Debugging cross-world failures

1. **Fingerprint worlds by identity, not by name.** Print `tostring(React)` (or any module table) at module scope and at use sites. Equal hashes = same world. Chunk names cannot do this.
2. **Read log attribution to identify the source sandbox.** Native prints attribute to the real script (`- StyleProvider:50`); sandbox prints mis-attribute to the loadstring host (`- SchedulerHostConfig.default:50`). `[string "<GetFullName>"]` stack frames are loadstring chunks. The same file printing under both attributions means both a native and a sandboxed copy are running — track which is which before drawing any conclusion.
3. **Pin the dying render with a dispatcher guard.** Inside the failing component: if `React.__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED.ReactCurrentDispatcher.current == nil`, print `debug.traceback()`. It fires only in the failure case and reveals which root is rendering. A traceback with no application frames above the reconciler means a top-level scheduled root, not an explicit render call.
4. **Expect multiple copies of everything in dev places.** A dev place typically contains the plugin's native modules, a Rojo-synced codebase copy, and N sandbox evaluations. Before reasoning about "the" React or "the" Storyteller, enumerate which copies exist (see `build-and-toolchain`'s Dev-Place Topology section).
5. **Instrumentation discipline is its own skill.** Assert your probes applied and verify they shipped before interpreting silence — see the org `instrumented-debugging` skill; a silently missing probe once produced a completely false "this pipeline never ran" conclusion.

## Provenance and Maintenance

Distilled from the July 2026 sandboxed-Storyteller crash investigation (Storyteller #144 review cycle). Update when module-loader changes its chunk wrapping, env injection, or grows a first-class sandbox-detection API (preferred over the `_G` probe long-term).
