---
bump: patch
category: Changes
---

Add a self-referential routing gate to `AGENTS.md` and `CLAUDE.md` so an agent working in this repo reads the Project Skills index up front, routes to `src/<scope>/<name>/SKILL.md` on demand, and forwards the gate to any subagent it spawns. The library now applies its own routing discipline to itself.
