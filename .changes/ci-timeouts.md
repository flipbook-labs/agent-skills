---
bump: patch
category: Changes
---

Align CI job timeouts with the org convention: lower the changelog `require-entry` job from 10 to 5 minutes, and set `timeout-minutes: 5` on the `test` and `analyze` jobs, which had no timeout at all.
