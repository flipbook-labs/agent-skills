@AGENTS.md

# Claude-specific routing

The skills in this repository live under `src/<scope>/<name>/SKILL.md` (a
vendor-neutral home shared with every other agent tool), **not** `.claude/skills/`,
so they are **not** auto-surfaced by the Skill tool. Route yourself: when a task
matches a trigger in the Project Skills index above (imported from AGENTS.md),
read the matching `src/<scope>/<name>/SKILL.md` before working.

Authoring and maintenance conventions are in [CONTRIBUTING.md](CONTRIBUTING.md) —
skills are living documents; if your work contradicts one, fix it here and add a
`.changes/` entry (this library is a versioned package, so the fix reaches consumers
on their next version bump).
