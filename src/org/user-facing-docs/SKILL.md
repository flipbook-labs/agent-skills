---
name: user-facing-docs
description: "How to write a README or user-facing doc for a flipbook-labs library, action, or CLI: center the product not its implementation, apply the is-this-useful-to-an-end-user filter, and ship at least one concrete runnable example. Use when: writing or editing a repo README or the getting-started docs for a package. For prose voice see org/writing-style; for Flipbook's Obsidian docs site see flipbook/write-docs."
type: process
---

# User-Facing Docs

How to write the README and getting-started docs a person reads when they pick up one of our packages. The audience is a user installing the thing, not a maintainer of it. These are the corrections Marin makes when a README documents the wrong altitude.

## Center the product, not its implementation

Write from the perspective of the product being the thing the reader wants. What it is built on is an implementation detail they should not have to care about by default. Marin, on an action that shells out to another tool: *"The use of flipbook-cli should be an implementation detail. Write the readme from the perspective of deploy-storybook being the primary product."* Mention the internals only lightly, for the power user who needs the escape hatch, never as the main narrative.

## Apply the end-user utility filter

Before a section earns a place in the README, ask: **is this useful to someone using the package?** Marin: *"Ask yourself: Is this useful to an end-user? This section is a definite No."* Internal development notes, "this repository is in early setup," CLI-installation minutiae, and process docs fail the filter. They belong in `AGENTS.md`, a skill, or the wiki. Trim the README to what a user needs to install and use the thing.

## Ship a concrete, runnable example

Public API docs need at least one real example before release, and the example must actually work.

- **Real, not placeholder.** Use a real build command and realistic names (*"Let's use a real rojo build example"*; a display name like `Flipbook Stories`, not `my-input-here`). Users copy-paste, so a synthetic or wrong example breaks their first run.
- **Watch for characters that break in practice.** Marin hit trouble using `#` in a Roblox place name and cut it from the example. When a value has environment constraints, keep the example inside them and note the constraint.

## Nudge setup toward the right primitives

When the doc walks a user through credentials or configuration, point them at the durable primitive rather than the quick one: for secrets in an action, a GitHub Environment holding the key and variables, not repo-level secrets. The README is where a good default gets established.

## When not to use

This skill is about what belongs in user-facing docs and at what altitude. For the prose voice (banned patterns, no em dashes, the self-critic pass), follow [`org/writing-style`](../writing-style/SKILL.md). For authoring Flipbook's Obsidian vault and Docusaurus site specifically (wikilinks, callouts, the sidebar), that repo's [`flipbook/write-docs`](../../flipbook/write-docs/SKILL.md) owns the mechanics. For a changelog entry rather than a doc, see [`org/changelog-entries`](../changelog-entries/SKILL.md).

---

## Provenance and Maintenance

**Date stamped:** 2026-07-07. Distilled from Marin's review comments on README and getting-started docs across deploy-storybook and agent-gateway (center the product, the is-this-useful-to-an-end-user filter, concrete runnable examples, GitHub Environments for secrets). Quotes are frozen illustrations, not live pointers into any repo.

**Re-verify these claims when this skill next loads:** nothing mechanical. This is `org/` doctrine with no single-repo anchors. If the org's README expectations change, update the affected section and add a `.changes/` entry.
