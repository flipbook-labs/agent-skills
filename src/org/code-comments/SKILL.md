---
name: code-comments
description: "When and how to write code comments: a comment earns its place by stating a constraint or rationale the code cannot show. Use when: writing or editing code in any flipbook-labs repo, deciding whether a change needs a comment, or reviewing a diff whose comments narrate instead of explain. Covers the test for whether a comment belongs, the forbidden kinds, and an exemplar."
type: process
---

# Code Comments

The discipline for comments in code you write or edit. The bar: a comment earns its place by stating something true and load-bearing that the code itself cannot show. Everything else is noise that rots.

The "change-log talk" this skill bans is the comment-local face of a wider failure. [`org/durable-writing`](../durable-writing/SKILL.md) names the root and covers its PR-body and changelog siblings.

## The test

Before writing a comment, ask: **if a competent reader deleted the code below it and rewrote it from scratch, would this comment have stopped them from reintroducing a bug or removing something load-bearing?**

- Yes: write it. These comments capture off-site constraints (another system's behavior, a platform quirk, an ordering requirement), the consequence of the "obvious simplification," or the reason a strange-looking construct is deliberate.
- No: delete it. The code already says what it does.

Link the issue or PR when a fuller story exists. The comment holds the constraint, the link holds the archaeology.

## Forbidden kinds

- **Narration:** restating what the next line does ("create the frame", "loop over stories"). The code says this already.
- **Change-log talk:** where the code came from or how it differs from before ("moved from X", "previously this used Y", "new in this PR"). That is you talking to the reviewer. It is stale the moment the change merges. Put it in the PR body instead. This is the single most common tell in agent-written refactors: narrating how the code *used to be*. After a thorough refactor none of that history is relevant. Marin: *"It's always interesting when agents can't help but talk about how something used to be... if a thorough job is done then all history relating to this particular folder shouldn't be relevant anyway."*
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

## Delete generated comment slop

Agents tend to comment every few lines by default. When you have generated a block of code, take a pass and delete the comments that only narrate, keeping the rare one that meets the test. Marin says this bluntly in review (*"Just get rid of all the comments please"*, *"Let's remove this and all other agent-made comments in this PR"*). The goal is not zero comments, it is that every surviving comment earns its place. The same applies to generated prose: a README does not need a paragraph explaining an obvious field.

## A good comment names the off-site constraint

The comments worth keeping most often explain a constraint from *outside* the file that the code cannot show: a platform limit, an API quirk, an environment difference. "ScriptEditorService is not accessible from a Luau execution context, so we cannot use it in CI" stops a future contributor from "fixing" a workaround they do not understand. When a design choice is genuinely uncertain or aspirational, it is fine to say so honestly rather than feign confidence.

---

## Provenance and Maintenance

**Date stamped:** 2026-07-07. Doctrine written for the exemplar from storyteller#132, which the maintainer flagged as the house bar for code comments. Updated 2026-07-07 with the refactor "how it used to be" tell, deleting generated comment slop, and naming off-site constraints, from recurring corrections across Changewrite, ModuleLoader, deploy-storybook, and flipbook-cli reviews. Updated 2026-07-13 to cross-link `org/durable-writing`, the cross-cutting root this skill applies to comments.

**Re-verify these claims when this skill next loads:** nothing. This `org/` skill carries no single-repo anchors — the exemplar above is a frozen snapshot quoted for illustration, deliberately *not* a live pointer into Storyteller source (broader-scope skills must avoid single-repo anchors; see CONTRIBUTING.md). It stands on its own even if that file later changes. The doctrine has no volatile layer.
