# agent-skills

The shared, vendor-neutral home for **every agent skill in the flipbook-labs org**:
cross-cutting doctrine, the Flipbook↔Storyteller↔ModuleLoader family contract, and
repo-specific knowledge. Distributed as a versioned Loom package (`AgentSkills`) so
any repo can depend on it and pin a known-good version. See [README.md](README.md)
for how to consume it and [CONTRIBUTING.md](CONTRIBUTING.md) for how to author skills.

## How routing works

Skills live under `src/<scope>/<name>/SKILL.md` and are **loaded on demand**, not
kept in always-on context. Routing is manual: **scan the Project Skills index below;
when a task matches a trigger, read that `SKILL.md` first.** The index is part of the
library. **Adding, renaming, or retiring a skill requires updating this index in the
same commit**, or the skill silently stops being found.

Scopes:

- **`org/`**: cross-cutting doctrine that applies to any flipbook-labs repo.
- **`family/`**: the Flipbook / Storyteller / ModuleLoader repo family.
- **`flipbook/`**: Flipbook-specific knowledge and runbooks.
- **`agent-gateway/`**: AgentGateway protocol and workflows.

Each entry declares a genre. `type: process` is a runbook (what to do next) and
`type: knowledge` is reference (how the system is and why). See CONTRIBUTING.md.

## Project Skills

> Scaffold: no skills seeded yet. Entries land here (in the same commit as each
> skill) as the library is populated. Format per line:
> `` - `<scope>/<name>`: <trigger-rich one-liner>. ``

### Cross-cutting (`org/`)

- `org/write-luau-tests`: writing unit tests that specify intended behavior and can actually fail. The red-first gate, forbidden moves (tautologies, mocking the subject, coverage theater), and the definition-of-good rubric. Vendor-neutral doctrine. Repo-specific runner and framework mechanics live in that repo's own test skill. `type: process`.
- `org/writing-style`: the house voice for prose you generate (skills, docs, PRs, changelog entries). The banned patterns (antithesis framing, hype words, em dashes, semicolon overuse) and the self-critic pass. Run it over any prose you write or edit. `type: process`.

### Family: Flipbook / Storyteller / ModuleLoader (`family/`)

_none yet_

### Flipbook (`flipbook/`)

- `flipbook/write-docs`: authoring Flipbook's docs (the Obsidian vault and Docusaurus site). The workflow, the site mechanics (wikilinks, callouts, sidebar, code samples), and conventions. Defers to `org/writing-style` for voice. `type: process`.

### AgentGateway (`agent-gateway/`)

- `agent-gateway/use-agent-gateway`: driving Studio plugins that expose actions via an AgentGateway. Connecting to the Roblox Studio MCP server, discovering gateways by tag, and speaking the `list`/`call` protocol. `type: knowledge`.
