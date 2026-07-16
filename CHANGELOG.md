# Changelog

All notable changes to this project will be documented in this file.


## v0.5.0

### Changes

- Upgrade the Changewrite release action to `v0.7.0` and adopt its `publish-lock` check.

- Format all Markdown with Prettier and add a `format` CI job that keeps it enforced.

### Features

- Add `org/durable-writing`, the root for writing PR bodies, comments, and changelog entries to the durable why rather than narrating the change, and tighten two conventions it leans on: an AI-authorship disclosure line is required on agent-generated PR bodies, and each PR carries a single changelog entry.

- Add the `flipbook/` skill scope and route agents working in this repo through the same Project Skills index the library ships.


## v0.4.0

### Changes

- Sharpen `org/write-luau-code` so a module carries one responsibility and trivial single-use helpers fold into their caller.

### Features

- Add `org/review-pass`, the procedure for applying the skills over a diff and at task close so routing is not a one-time startup read.


## v0.3.0

### Changes

- `org/changelog-entries` now caps an entry at one short sentence of about 140 characters.

- Cap every CI job at a 5-minute timeout.

- Add `org/github-actions`, the authoring companion to `org/repo-conventions` for writing workflows and actions.

- Add `org/repo-conventions`, the repo setup and CI conventions for flipbook-labs repos.

- Add `org/reviewable-changes` and `org/user-facing-docs`, and reinforce four existing skills from org-wide review mining.

- Add `org/write-luau-code`, the house Luau style for any flipbook-labs repo.

- `org/writing-style` now covers commit messages and PR titles: write a plain imperative summary and skip conventional-commit prefixes (`feat:`, `fix:`, `docs:`, and the rest).

- `org/writing-style` now bans a double hyphen (`--`) used as sentence punctuation, closing the gap agents used to slip past the em-dash ban.

### Fixes

- Refer to the maintainer with gender-neutral language in the `org/repo-conventions` and `org/changelog-entries` provenance notes.


## v0.2.0

### Changes

- Use a colon instead of an em dash in the `agent-gateway/use-agent-gateway` index entry, so the AGENTS.md index follows the no-em-dash house style it now documents.

- Add the `org/changelog-entries` skill for writing changelog entries that read on their own and fit the project's audience.

- Add `org/code-comments`, the discipline for when a code comment earns its place: a comment has to state a constraint or rationale the code cannot show. Covers the delete-and-rewrite test, the forbidden comment kinds, and an annotated exemplar.


## v0.1.0

### Changes

- Add skill validation as Lute-native `.spec.luau` tests (frontmatter + `AGENTS.md`↔`src/` consistency, run by `lute test`) and `lute run analyze` strict type-checking, wired as `test` and `analyze` CI jobs to gate skill PRs.

- Add `agent-gateway/use-agent-gateway`, the generic skill for discovering and driving AgentGateway-backed Studio plugins over the `list`/`call` protocol.

- Add the Changewrite release workflow and the `.changes/` entry convention. Releases now bump the version, roll pending `.changes/` entries into `CHANGELOG.md`, tag, and publish a GitHub release; a `changelog` CI check requires every PR to add an entry.

- Add `org/write-luau-tests`, the vendor-neutral test-quality doctrine (red-first gate, forbidden moves, definition-of-good rubric) generalized from Flipbook's `write-flipbook-tests`.

- Add `org/writing-style` (the house voice, banned patterns, and self-critic pass) and `flipbook/write-docs` (the Flipbook and Obsidian docs-site mechanics, deferring to `org/writing-style` for voice), split out of Flipbook's `write-docs` skill.
