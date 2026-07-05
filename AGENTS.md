# agent-skills

The shared, vendor-neutral home for **every agent skill in the flipbook-labs org** —
cross-cutting doctrine, the Flipbook↔Storyteller↔ModuleLoader family contract, and
repo-specific knowledge. Distributed as a versioned Loom package (`AgentSkills`) so
any repo can depend on it and pin a known-good version; see [README.md](README.md)
for how to consume it and [CONTRIBUTING.md](CONTRIBUTING.md) for how to author skills.

## How routing works

Skills live under `src/<scope>/<name>/SKILL.md` and are **loaded on demand**, not
kept in always-on context. Routing is manual: **scan the Project Skills index below;
when a task matches a trigger, read that `SKILL.md` first.** The index is part of the
library — **adding, renaming, or retiring a skill requires updating this index in the
same commit**, or the skill silently stops being found.

Scopes:

- **`org/`** — cross-cutting doctrine that applies to any flipbook-labs repo.
- **`family/`** — the Flipbook / Storyteller / ModuleLoader repo family.
- **`flipbook/`** — Flipbook-specific knowledge and runbooks.
- **`agent-gateway/`** — AgentGateway protocol and workflows.

Each entry declares a genre (`type: process` = runbook / what to do next;
`type: knowledge` = reference / how the system is and why); see CONTRIBUTING.md.

## Project Skills

> Scaffold — no skills seeded yet. Entries land here (in the same commit as each
> skill) as the library is populated. Format per line:
> `` - `<scope>/<name>` — <trigger-rich one-liner>. ``

### Cross-cutting (`org/`)

_none yet_

### Family — Flipbook / Storyteller / ModuleLoader (`family/`)

_none yet_

### Flipbook (`flipbook/`)

_none yet_

### AgentGateway (`agent-gateway/`)

_none yet_
