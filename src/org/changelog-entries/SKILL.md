---
name: changelog-entries
description: "What goes in a changelog / .changes entry and who it is for: release notes read by a user with no PR context, tailored to the project's audience. Use when: writing or editing a Changewrite `.changes/` entry or any CHANGELOG body in a flipbook-labs repo. Covers reading in isolation, dropping PR-process references, cutting length, and matching a library vs plugin audience. Defers to org/writing-style for voice."
type: process
---

# Changelog Entries

A changelog entry is release notes for the people who use the project. It gets read later in the assembled `CHANGELOG.md` by someone who never saw your PR. Write it for them.

Most repos here collect entries as Changewrite `.changes/` files: frontmatter `bump:` and `category:`, then a body. This skill is about that body. For the `bump` and `category` mechanics, see the repo's own `.changes/README.md`.

## Read it in isolation

The reader has no branch, no diff, no PR thread. The entry has to stand on its own next to a hundred others.

- Drop references to PRs, branches, and in-progress work. "gains the same support in its own PR" tells a user nothing, and it rots the moment that PR merges or stalls.
- Describe what the released version does, in the present tense. Leave out the development story ("previously", "used to", "as part of this change"). That framing is you talking to the reviewer, and it belongs in the PR body. Dev narrative goes in the PR, never in the shipped artifact.

## Cut the length

Aim to cut a first draft roughly in half. One or two short sentences carry almost every change: what changed, and if it helps the reader, why it matters to them. Drop implementation detail that does not change how they use the project.

## Match the audience

Judge by who installs the released artifact, and pitch the entry to them:

- **Library or package** (consumed by other developers: Storyteller, ModuleLoader, this library): the reader writes code against it and takes an interest in specifics. Naming the affected API, type, or behavior is useful and welcome.
- **Plugin or app** (a broad end-user audience: Flipbook, a Roblox Studio plugin): aim for a high-level summary in plain language. Short sentences, no internal names or module paths. Say what the user can now do, and leave out how it was wired.

When you are unsure which a repo is, ask who reads its changelog: another developer bumping a dependency, or a person who installed the app.

## Before and after

A real edit from Storyteller (a library, so the specifics stay), quoted here as a frozen illustration:

Before:

> Apply a storybook's `mapStory` middleware in the Fusion, Vide, and Manual renderers. Previously only React and Roact used it (flipbook-labs/flipbook#552), and the in-progress Iris renderer gains the same support in its own PR.

After:

> Apply a storybook's `mapStory` middleware in the Fusion, Vide, and Manual renderers, matching the existing behavior in React and Roact.

The cross-repo issue link and the in-progress-PR aside both go, because a user can act on neither. The "previously only" development framing goes. One sentence carries the fact. The affected renderers stay, because a Storyteller user works at that level.

## Voice

Everything in [`org/writing-style`](../writing-style/SKILL.md) applies to the body: no em dashes, no hype words, no antithesis framing, then the self-critic pass. This skill governs what to include and for whom. That one governs how it reads.

---

## Provenance and Maintenance

**Date stamped:** 2026-07-05. Written from the maintainer's guidance on a Storyteller changelog review: entries should read in isolation, drop in-progress-PR references, cut length by about half, and match the project's audience (developer-facing detail for a library, high-level summaries for a plugin like Flipbook).

**Re-verify these claims when this skill next loads:** nothing. This `org/` skill is pure doctrine with no single-repo anchors. The before/after above is a frozen snapshot quoted for illustration, not a live pointer into Storyteller source. The audience examples (Storyteller as a library, Flipbook as a plugin) are stable facts about the org. When the house approach to changelogs changes, update this skill and add a `.changes/` entry.
