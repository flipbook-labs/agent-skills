---
name: reviewable-changes
description: "How to scope a change so it is easy to review and safe to land in a flipbook-labs repo: keep the diff small, separate refactoring from features, make a reorganization's diff tell its story, do not expose public API or add dependencies ahead of the feature that needs them, and remove temporary code before merge. Use when: planning a PR, deciding whether a change is doing too much, or refactoring alongside a feature."
type: process
---

# Reviewable Changes

How to shape a change so a reviewer can actually follow it. These are the scope and hygiene corrections Marin makes when a PR is technically fine but hard to review or premature. The reviewer's attention is the scarce resource. Spend it deliberately.

## Keep the diff small, and do not move code you do not have to

A large diff full of shifted-around code is expensive to review even when every line is correct, because the reviewer cannot tell a real change from a relocation. Marin: _"Try not to rewrite the components unless you have to. It makes the review process easier if things don't get shifted around too much."_ Touch what the change needs and leave the rest where it is. When a diff gets big enough that a reviewer says _"there are too many file changes for me to review here,"_ it needed to be split.

## Separate refactoring from features

Structural work (extracting, moving, renaming, deleting) goes in its own PR, apart from behavior changes. Mixing them means a reviewer cannot isolate the logic change from the rearrangement, and a bisect later cannot either. Land the refactor first, then build the feature on top, or the other way around, but not both in one diff.

## When you must reorganize, make the diff tell its story

If a reorganization is unavoidable, shape it so the reason is visible. Order the change so the diff reads in a logical flow, and state why code moved. Marin: _"I want to rework this so the diff makes more sense,"_ and, on an extraction: _"Ripping these out to `src/loading-strategies` since I need `requireWithLoadstring` for `createProxyModuleLoader`."_ A one-line rationale in the PR or commit turns an unexplained move into a reviewable decision.

## Do not get ahead of the change

- **Do not expose public API prematurely.** Keep a new capability internal until the PR that deliberately exposes it. If a change touches the public surface as a side effect, revert that part. On a v0 library the public surface should stay small and you should be critical of every export, since breaking changes are still cheap. Marin: _"We'll expose everything off the public API in a follow-up PR."_
- **Do not add a dependency before the feature that uses it.** No new `wally.toml` / manifest entry until the code that needs it lands in the same PR.
- **Expose an internal effect as a documented method rather than letting consumers scrape it.** When another repo needs to observe internal state (a lock, a tag), add a small public accessor for it instead of having the consumer reach into internals.

## Defer discovered rework to a follow-up

When review turns up a larger problem (a vestigial code path, a design that wants reworking), do not balloon the current PR to fix it. Note it and split it out. Marin: _"Let's rip out the surfaces in a new PR. This is vestigial."_ The current PR stays focused; the follow-up gets its own review.

## Leave nothing temporary behind

Remove debug code, scaffolding, and temporary config before merge (_"Remember to remove this before merging"_). If something must stay in temporarily, say why in the PR rather than letting it slip in silently.

## When not to use

This skill is about the shape and scope of a change. For the house Luau style inside it, see [`org/write-luau-code`](../write-luau-code/SKILL.md). For whether the tests are any good, see [`org/write-luau-tests`](../write-luau-tests/SKILL.md). For the PR body's wording and disclosure conventions, follow the repo's PR template and the org changelog voice in [`org/changelog-entries`](../changelog-entries/SKILL.md).

---

## Provenance and Maintenance

**Date stamped:** 2026-07-07. Distilled from Marin's review comments across Flipbook, Storyteller, agent-gateway, and ModuleLoader, where the same scope corrections recur (keep diffs small, separate refactoring from features, explain reorganizations, defer public-API exposure and new dependencies, remove temporary code). Quotes are frozen illustrations, not live pointers into any repo.

**Re-verify these claims when this skill next loads:** nothing mechanical. This is `org/` doctrine with no single-repo anchors. If the org adopts a different review or branching workflow, update the affected section and add a `.changes/` entry.
