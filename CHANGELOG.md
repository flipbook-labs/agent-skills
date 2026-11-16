# Changelog

All notable changes to this project will be documented in this file.


## v0.7.0

Changes 6 · Fixes 1

### Changes

1. <picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/flipbook-labs/agent-skills/main/.changes/assets/kind-validation-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/flipbook-labs/agent-skills/main/.changes/assets/kind-validation-light.svg"><img src="https://raw.githubusercontent.com/flipbook-labs/agent-skills/main/.changes/assets/kind-validation-light.png" alt="Validation" height="18" align="texttop"></picture> `lute test` enforces the mechanical half of the authoring checklist over every markdown file a skill ships, not only its `SKILL.md`. ([#38](https://github.com/flipbook-labs/agent-skills/pull/38))
2. <picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/flipbook-labs/agent-skills/main/.changes/assets/kind-flipbook-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/flipbook-labs/agent-skills/main/.changes/assets/kind-flipbook-light.svg"><img src="https://raw.githubusercontent.com/flipbook-labs/agent-skills/main/.changes/assets/kind-flipbook-light.png" alt="Flipbook" height="18" align="texttop"></picture> Consolidate the 22 `flipbook/` skills into six (`architecture`, `dev-env`, `release`, `troubleshooting`, `use-studio-mcp-for-flipbook`, `write-docs`), checked against current Flipbook. ([#54](https://github.com/flipbook-labs/agent-skills/pull/54))
3. <picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/flipbook-labs/agent-skills/main/.changes/assets/kind-org-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/flipbook-labs/agent-skills/main/.changes/assets/kind-org-light.svg"><img src="https://raw.githubusercontent.com/flipbook-labs/agent-skills/main/.changes/assets/kind-org-light.png" alt="Org" height="18" align="texttop"></picture> `org/durable-writing` covers how to write each PR body section, and `org/writing-style` adds sentence craft for all prose. ([#49](https://github.com/flipbook-labs/agent-skills/pull/49))
4. <picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/flipbook-labs/agent-skills/main/.changes/assets/kind-flipbook-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/flipbook-labs/agent-skills/main/.changes/assets/kind-flipbook-light.svg"><img src="https://raw.githubusercontent.com/flipbook-labs/agent-skills/main/.changes/assets/kind-flipbook-light.png" alt="Flipbook" height="18" align="texttop"></picture> Keep Flipbook fork code outside secret-bearing test and preview runners. ([#43](https://github.com/flipbook-labs/agent-skills/pull/43))
5. <picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/flipbook-labs/agent-skills/main/.changes/assets/kind-org-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/flipbook-labs/agent-skills/main/.changes/assets/kind-org-light.svg"><img src="https://raw.githubusercontent.com/flipbook-labs/agent-skills/main/.changes/assets/kind-org-light.png" alt="Org" height="18" align="texttop"></picture> `org/changelog-entries` covers picking an entry's kind, flags, and highlight, and release notes show each entry's kind as a chip. ([#57](https://github.com/flipbook-labs/agent-skills/pull/57))
6. <picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/flipbook-labs/agent-skills/main/.changes/assets/kind-packages-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/flipbook-labs/agent-skills/main/.changes/assets/kind-packages-light.svg"><img src="https://raw.githubusercontent.com/flipbook-labs/agent-skills/main/.changes/assets/kind-packages-light.png" alt="Packages" height="18" align="texttop"></picture> Ship the manifest as `pkg.luau`, which installs only with Lute nightlies newer than `1.0.1-nightly.20261031`. ([#58](https://github.com/flipbook-labs/agent-skills/pull/58))

### Fixes

1. <picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/flipbook-labs/agent-skills/main/.changes/assets/kind-flipbook-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/flipbook-labs/agent-skills/main/.changes/assets/kind-flipbook-light.svg"><img src="https://raw.githubusercontent.com/flipbook-labs/agent-skills/main/.changes/assets/kind-flipbook-light.png" alt="Flipbook" height="18" align="texttop"></picture> Document how to drive and capture Flipbook through Studio MCP when the build has no AgentGateway, including embedding without the gateway and the virtual-input quirks that make clicks land. ([#48](https://github.com/flipbook-labs/agent-skills/pull/48))


## v0.6.0

### Features

- Add a Flipbook Studio MCP workflow for semantic actions, embedded Play-mode checks, and screenshots.


## v0.5.2

### Changes

- `org/changelog-entries` now picks a bump by whether a change adds surface area, takes it away, or refines what is already there.

- `org/write-luau-tests` now covers tests that cannot fail: triaging a green break-check, and assertions and fixtures that do not discriminate.

- Document Flipbook review ownership and the Changewrite release flow.

- GitHub App workflow examples use the public Client ID organization variable.


## v0.5.1

### Changes

- `org/durable-writing` now covers tense, framing it as a surface of the destination-versus-transition root: describe states that are true of the merged artifact, which lands you in present tense, and reserve past tense for real completed events like verification or a rejected alternative.

- `org/write-luau-code` now says Luau function types carry parameter names, reversing its earlier no-names rule.


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
