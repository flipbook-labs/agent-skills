---
bump: minor
category: Changes
---

Add the Changewrite release workflow and the `.changes/` entry convention. Releases now bump the version, roll pending `.changes/` entries into `CHANGELOG.md`, tag, and publish a GitHub release; a `changelog` CI check requires every PR to add an entry.
