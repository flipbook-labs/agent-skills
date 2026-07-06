---
name: code-comments
description: "When and how to write code comments: a comment earns its place by stating a constraint or rationale the code cannot show. Use when: writing or editing code in any flipbook-labs repo, deciding whether a change needs a comment, or reviewing a diff whose comments narrate instead of explain. Covers the test for whether a comment belongs, the forbidden kinds, and an exemplar."
type: process
---

# Code Comments

The discipline for comments in code you write or edit. The bar: a comment earns its place by stating something true and load-bearing that the code itself cannot show. Everything else is noise that rots.

## The test

Before writing a comment, ask: **if a competent reader deleted the code below it and rewrote it from scratch, would this comment have stopped them from reintroducing a bug or removing something load-bearing?**

- Yes: write it. These comments capture off-site constraints (another system's behavior, a platform quirk, an ordering requirement), the consequence of the "obvious simplification," or the reason a strange-looking construct is deliberate.
- No: delete it. The code already says what it does.

Link the issue or PR when a fuller story exists. The comment holds the constraint, the link holds the archaeology.

## Forbidden kinds

- **Narration:** restating what the next line does ("create the frame", "loop over stories"). The code says this already.
- **Change-log talk:** where the code came from or how it differs from before ("moved from X", "previously this used Y", "new in this PR"). That is you talking to the reviewer. It is stale the moment the change merges. Put it in the PR body instead.
- **Self-justification:** asserting your change is correct or safe ("this is fine because the tests pass"). Verification lives in tests and the PR, not in comments.
- **Vague hedges:** "this might break if things change." Name the thing and the failure, or say nothing.

## What a good one looks like

A static snapshot from Storyteller ([storyteller#132](https://github.com/flipbook-labs/storyteller/pull/132)) — reproduced here as an illustration of the bar, not a live anchor into that repo's source:

```lua
if result.packages and getmetatable(result.packages) == nil then
	-- Loaded storybooks get stored in Charm state, which deep-freezes
	-- everything it can reach in Studio, but skips tables that have a
	-- metatable. UI libraries mutate their module-level state while
	-- rendering (React reassigns ReactCurrentDispatcher.current on every
	-- render), so freezing has to stop at this foreign-module boundary
	-- (flipbook-labs/storyteller#100).
	--
	-- The clone matters: when the storybook declares `packages` directly,
	-- the table belongs to the author's module and may be shared between
	-- storybooks or frozen, so we must not attach a metatable in place
	result.packages = setmetatable(table.clone(result.packages), {})
end
```

Why this is the bar:

- Without the comment, the code reads as deletable noise: clone a table, attach an empty metatable, apparently for nothing. Every piece looks like a simplification target.
- It states the off-site constraint the code cannot show: Charm deep-freezes state in Studio and skips metatable-carrying tables, and React's own module state must stay mutable.
- It pre-empts each "obvious" cleanup by naming what breaks: drop the metatable and Studio freezes React's internals, drop the clone and you mutate (or throw on) a table the storybook author owns.
- It links the issue for the full archaeology instead of inlining it.

Match the comment density of the surrounding file. One comment that meets the test beats five that narrate.

---

## Provenance and Maintenance

**Date stamped:** 2026-07-05. Doctrine written for the exemplar from storyteller#132, which the maintainer flagged as the house bar for code comments.

**Re-verify these claims when this skill next loads:** nothing. This `org/` skill carries no single-repo anchors — the exemplar above is a frozen snapshot quoted for illustration, deliberately *not* a live pointer into Storyteller source (broader-scope skills must avoid single-repo anchors; see CONTRIBUTING.md). It stands on its own even if that file later changes. The doctrine has no volatile layer.
