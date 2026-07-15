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

Reading in isolation is the changelog case of writing for the later reader. [`org/durable-writing`](../durable-writing/SKILL.md) is the cross-cutting root.

## Cut the length

An entry has to be scannable. The changelog is read as a list of many entries, and a reader hunting for one fact skips over anything that looks like a paragraph, so a long entry loses the information it carries.

- One short sentence: what changed, and only when it changes what the reader does, why.
- Treat about 140 characters as the ceiling. Past it, cut content rather than compressing the grammar.
- When a change has many parts, name the change and stop. "Add `org/repo-conventions`, the repo setup and CI conventions for flipbook-labs repos." is a complete entry. Following it with a colon and every convention inside the skill turns the entry into a wall of text, and a reader who wants the list opens the skill.
- Drop implementation detail that does not change how the reader uses the project.

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

## Category and bump

- **Keep category names consistent, in the present tense.** Use the same headings across entries so the assembled changelog reads uniformly: `Features`, `Fixes`, `Changes`, `Dependencies`, not a mix like `Add`/`Added`/`Fixed`. Match whatever set the repo already uses.
- **Use `patch` as the catch-all when the tool offers no "skip".** Changewrite requires a bump on every entry and has no internal or skip level, so a change with no user-facing effect (CI, tooling, a pure refactor) takes `patch`. Marin: _"We're essentially using patch as a catch-all for actual patches and anything else a PR could possibly do since there's no skip option."_ Reserve `minor` and `major` for changes a consumer would actually notice.

## Voice

Everything in [`org/writing-style`](../writing-style/SKILL.md) applies to the body: no em dashes, no hype words, no antithesis framing, then the self-critic pass. This skill governs what to include and for whom. That one governs how it reads.

---

## Provenance and Maintenance

**Date stamped:** 2026-07-07. Written from the maintainer's guidance on a Storyteller changelog review: entries should read in isolation, drop in-progress-PR references, cut length by about half, and match the project's audience (developer-facing detail for a library, high-level summaries for a plugin like Flipbook). The length rule was tightened on 2026-07-07 from reviews of agent-skills#14 and agent-skills#18: one short sentence with a ceiling of about 140 characters, because an entry that enumerates a change's every part stops being scannable. Consistent present-tense category names and the `patch` catch-all bump were added the same day, from agent-gateway, Storyteller, and ModuleLoader reviews. Updated 2026-07-13 to cross-link `org/durable-writing`, the cross-cutting root this skill applies to changelog bodies.

**Re-verify these claims when this skill next loads:** nothing. This `org/` skill is pure doctrine with no single-repo anchors. The before/after above is a frozen snapshot quoted for illustration, not a live pointer into Storyteller source. The audience examples (Storyteller as a library, Flipbook as a plugin) are stable facts about the org. When the house approach to changelogs changes, update this skill and add a `.changes/` entry.
