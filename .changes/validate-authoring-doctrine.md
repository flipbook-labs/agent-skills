---
bump: patch
category: Changes
---

`lute test` enforces the mechanical half of the authoring checklist over every markdown file a skill ships, not only its `SKILL.md`. The frontmatter checks cover `name` and `description`, including the 1024-character limit past which Codex silently refuses to load a skill. A file that has to break a prose rule, like the bad-example drafts in `org/durable-writing`, opts out with a `doctrine-exempt` marker that names the rule and states why.
