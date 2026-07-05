# Changelog

All notable changes to the `agent-skills` library are documented here. This file
is managed by [Changewrite](https://github.com/flipbook-labs/changewrite); each
change to the library ships with an entry so that consumers reviewing a version
bump can see exactly which skills changed and why.

## Unreleased

- Scaffold the repository: authoring doctrine (`CONTRIBUTING.md`), routing
  convention (`AGENTS.md` / `CLAUDE.md`), package identity (`loom.config.luau`),
  and the scoped `src/` layout.
- Add `agent-gateway/use-agent-gateway` — the generic skill for discovering and
  driving AgentGateway-backed Studio plugins over the `list`/`call` protocol.
