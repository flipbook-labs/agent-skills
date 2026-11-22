---
name: changelog-entries
description: "What goes in a changelog / .changes entry and who it is for: release notes read by a user with no PR context, tailored to the project's audience. Use when: writing or editing a Changewrite `.changes/` entry or any CHANGELOG body in a flipbook-labs repo. Covers reading in isolation, dropping PR-process references, one entry per PR (split the PR, not the entry), cutting length (a one-line `summary`, with detail in `body`), matching a library vs plugin audience, and picking the category, kind, flags, highlight, and release summary that shape the rendered release notes. Defers to org/writing-style for voice."
type: process
---

# Changelog Entries

A changelog entry is release notes for the people who use the project. It gets read later in the assembled `CHANGELOG.md` by someone who never saw your PR. Write it for them.

Most repos here collect entries as Changewrite `.changes/` files. Each one is a Luau file that returns its fields:

```luau
return {
	bump = "patch",
	category = "Fixes",
	kind = "controls",
	summary = "Keep story controls connected after a story reloads.",
}
```

The `summary` is the line the reader sees in the changelog, and an optional `body` holds more detail. This skill is about those two and the choices around them. For the field mechanics and each repo's list of kinds, see the repo's own `.changes/README.md`.

A repo on a Changewrite release older than v0.14 still writes Markdown entries, with the fields in frontmatter and the summary as the body. After it upgrades, `changewrite check --fix` converts its pending entries to Luau.

## Read it in isolation

The reader has no branch, no diff, no PR thread. The entry has to stand on its own next to a hundred others.

- Drop references to PRs, branches, and in-progress work. "gains the same support in its own PR" tells a user nothing, and it rots the moment that PR merges or stalls.
- Describe what the released version does, in the present tense. Leave out the development story ("previously", "used to", "as part of this change"). That framing is you talking to the reviewer, and it belongs in the PR body. Dev narrative goes in the PR, never in the shipped artifact.

Reading in isolation is the changelog case of writing for the later reader. [`org/durable-writing`](../durable-writing/SKILL.md) is the cross-cutting root.

## One entry per PR

Write one `.changes` entry per PR. Agents reach for a second when a PR seems to carry more than one distinct change, but a second entry doubles down on the sprawl instead of resolving it. How many changes a PR holds is a fact about the PR, not the changelog: if it genuinely bundles unrelated changes, the fix is to split it into separate PRs ([`org/reviewable-changes`](../reviewable-changes/SKILL.md)), each with one entry, rather than keep the bundle and describe it twice.

Most of the time the PR is simply large, and one entry is still right. Collapse to a single entry and rework it with [`org/durable-writing`](../durable-writing/SKILL.md): name the change at the altitude the reader cares about and stop, the same move as "Cut the length" below. When the additions share a theme, one sentence names the theme. When they do not, that is the split signal again.

## Cut the length

A summary has to be scannable. The changelog is read as a list of many entries, and a reader hunting for one fact skips over anything that looks like a paragraph, so a long summary loses the information it carries.

- One short sentence: what changed, and only when it changes what the reader does, why.
- Keep it to one line of at most 140 characters, which `changewrite check` enforces. A repo can change the limit with `max_summary_length`. When a summary runs over, cut content rather than compressing the grammar.
- When a change has many parts, name the change and stop. "Add `org/repo-conventions`, the repo setup and CI conventions for flipbook-labs repos." is a complete entry. Following it with a colon and every convention inside the skill turns the entry into a wall of text, and a reader who wants the list opens the skill.
- Drop implementation detail that does not change how the reader uses the project.

The `body` is for detail a reader may need after the summary, such as a migration step or a requirement. It renders collapsed under the summary, so the list stays scannable. Most entries need no body. It follows the same rules as the summary: no PR references, no development story, nothing the reader can't use. When a summary runs long, cut it first, and move a sentence to the body only when a reader would miss it.

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

## Category, kind, and bump

- **Pick the category from the repo's list.** Each repo sets `categories` in `changewrite.toml`, and Changewrite rejects anything else. The org's repos share `Features`, `Changes`, `Fixes`, `Dependencies`, and `Internal`, in present-tense form, so the assembled notes read the same everywhere.
- **Put maintenance under `Internal`.** A change nobody using the released artifact can see (CI, release automation, review routing, contributing docs) takes `Internal`. That section starts collapsed in release notes, so the changes a user cares about stay on top.
- **Pick the kind by where the reader would look.** The kind renders as a chip beside the entry, so a skimming reader can find the changes to the part of the project they use. Choose from the repo's `[kind]` table. A refactor takes the kind of whatever it touches. The project kinds (`docs`, `build`, `tooling`, `packages`, `ci`, `release`, `contributing`) mean the same thing in every repo.
- **Use `patch` as the catch-all when the tool offers no "skip".** Changewrite requires a bump on every entry and has no internal or skip level, so a change with no user-facing effect (CI, tooling, a pure refactor) takes `patch`. Marin: _"We're essentially using patch as a catch-all for actual patches and anything else a PR could possibly do since there's no skip option."_
- **Pick the level by surface area, not by how much the change registers.** `minor` is for surface area a consumer can reach for that did not exist before. `major` is for taking surface area away, or changing it so existing usage breaks. Everything that refines what is already there stays on `patch`, however much a consumer notices it. In agent-skills that means `minor` for a new skill, `major` for retiring or renaming one, and `patch` for an edit to a skill that stays.

## Flags, highlights, and the release summary

Most entries need none of these. Each one pulls a reader's eye, so it only works when it is rare.

- **`flags`** mark a change that asks the reader to act, written as a list such as `flags = { "Breaking" }`. `Breaking` means existing usage stops working, so it pairs with a `major` bump, and Changewrite gathers those entries under their own heading with a banner. Say what the reader has to do in the body, which opens by default under that heading. `Deprecated` means surface area still works but is going away. `Security` means the update fixes a vulnerability.
- **`highlight`** names one of the few changes this release's readers should not miss, in a few words such as `Vide renderer`. The entry's summary and body appear under Highlights at the top of the notes. The summary still follows the length rule above.
- **`release.md`** opens the notes with one or two sentences on what the release brings, in the audience's terms. It describes the whole release, so it is written while preparing the release rather than by each feature PR.

## Voice

Everything in [`org/writing-style`](../writing-style/SKILL.md) applies to the body: no em dashes, no hype words, no antithesis framing, then the self-critic pass. This skill governs what to include and for whom. That one governs how it reads.

---

## Provenance and Maintenance

**Date stamped:** 2026-07-07. Written from the maintainer's guidance on a Storyteller changelog review: entries should read in isolation, drop in-progress-PR references, cut length by about half, and match the project's audience (developer-facing detail for a library, high-level summaries for a plugin like Flipbook). The length rule was tightened on 2026-07-07 from reviews of agent-skills#14 and agent-skills#18: one short sentence with a ceiling of about 140 characters, because an entry that enumerates a change's every part stops being scannable. Consistent present-tense category names and the `patch` catch-all bump were added the same day, from agent-gateway, Storyteller, and ModuleLoader reviews. Updated 2026-07-13 to cross-link `org/durable-writing`, the cross-cutting root this skill applies to changelog bodies. The one-entry-per-PR rule was added 2026-07-16, from the maintainer's observation that agents write a second entry when a PR feels like more than one change. The resolution is to split the PR or collapse to one reworked entry, not to add the second. The `minor` boundary was sharpened 2026-07-28, after an agent read "changes a consumer would actually notice" as covering new doctrine added to an existing skill and took `minor`, against the repo's practice in agent-skills#22, #34, and #36. The test is whether the change adds surface area, takes it away, or refines what is already there, rather than how much it registers.

Updated 2026-11-15 for Changewrite 0.11's rich release notes, which every flipbook-labs repo adopted (flipbook-labs/infra#37): the `kind` chip, the collapsed `Internal` category, `flags`, `highlight`, and `release.md`.

Updated 2026-11-22 for Changewrite v0.14, which writes entries as Luau with a checked one-line `summary` and an optional `body`, and capitalizes flag names. The org's repos move to it under flipbook-labs/infra#47.

**Re-verify these claims when this skill next loads:** nothing. This `org/` skill is pure doctrine with no single-repo anchors. The before/after above is a frozen snapshot quoted for illustration, not a live pointer into Storyteller source. The audience examples (Storyteller as a library, Flipbook as a plugin) are stable facts about the org. When the house approach to changelogs changes, update this skill and add a `.changes/` entry.
