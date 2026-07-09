# agent-skills

The single hub for **agent skills across the flipbook-labs org**. Instead of each
repo growing its own `.agents/skills/` in isolation, skills live here once and are
distributed as a versioned [Loom](https://github.com/luau-lang/lute) package
(`AgentSkills`). Consumers depend on it, pin a version, and pull updates as a
deliberate, changelog-reviewed bump — exactly like any other package in the org.

Skills are plain, vendor-neutral `SKILL.md` files (usable by Claude Code, Fable,
Cursor, or any agent tool), organized by scope under `src/`:

| Scope | What lives here |
| --- | --- |
| `src/org/` | Cross-cutting doctrine that applies to any repo (test discipline, change control, research methodology, writing style). |
| `src/family/` | The Flipbook ↔ Storyteller ↔ ModuleLoader repo family (dev-env setup, checks, dependency testing, the domain contract). |
| `src/flipbook/` | Flipbook-specific knowledge and runbooks. |
| `src/agent-gateway/` | AgentGateway protocol and workflows. |

See [`AGENTS.md`](AGENTS.md) for the routing index and [`CONTRIBUTING.md`](CONTRIBUTING.md)
for the authoring doctrine.

## Consuming the library

1. **Depend on it.** Add `AgentSkills` to your repo's `loom.config.luau`:

   ```luau
   AgentSkills = {
       rev = "v0.1.0", -- pin the version you validated against
       sourceKind = "github",
       source = "https://github.com/flipbook-labs/agent-skills",
   },
   ```

   `lute run install` fetches it into `~/.loom/store/AgentSkills@<version>/`.

2. **Route to it.** Add a short block to your repo's `CLAUDE.md` / `AGENTS.md`
   telling agents the shared library is installed, where to find its `AGENTS.md`
   index (under the installed package's `src/`), and to read a skill before working.

3. **Update deliberately.** Bump the pinned `rev` when you want newer skills; the
   [`CHANGELOG.md`](CHANGELOG.md) shows what changed between versions.

## Contributing

Skills are living documents. When your work contradicts a skill — a renamed symbol
an anchor points at, a changed config value, a "known bug" you just fixed — fix the
skill and add a [`.changes/`](.changes/README.md) entry in the same PR. Because this
is a versioned package, that fix reaches consumers on their next bump. Read
[`CONTRIBUTING.md`](CONTRIBUTING.md) before authoring or heavily editing a skill.

Versioning and releases are managed by
[Changewrite](https://github.com/flipbook-labs/changewrite): each PR adds a `.changes/`
entry (`bump:` + a sentence), and the release workflow rolls those into
[`CHANGELOG.md`](CHANGELOG.md), bumps the version in `changewrite.toml` (mirrored into
`loom.config.luau`), tags, and publishes a GitHub release.
