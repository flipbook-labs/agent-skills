# Changelog

All notable changes to this project will be documented in this file.


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
