@AGENTS.md

# Claude-specific routing

Follow [`AGENTS.md`](AGENTS.md) first. Its "Using these skills while you work here"
gate applies to you before any skill, doc, code, or PR prose: read the Project
Skills index in full, then read the matching skill before the work it covers. Its
subagent-forwarding rule applies every time you use the Task tool.

The skills live under `src/<scope>/<name>/SKILL.md` (a vendor-neutral home shared
with every other agent tool), **not** `.claude/skills/`, so the Skill tool does not
surface them. You route to them yourself by following the gate above. This repo is
the source of the skills, so read them straight from `src/`; there is no store path
to resolve.

Authoring and maintenance conventions are in [CONTRIBUTING.md](CONTRIBUTING.md).
Skills are living documents, so if your work contradicts one, fix it here and add a
`.changes/` entry in the same PR. This library is a versioned package, so the fix
reaches consumers on their next version bump.
