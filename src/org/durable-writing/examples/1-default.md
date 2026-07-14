## Summary

Reworks the `Upgrade Roblox Packages` workflow so the weekly run always makes a meaningful change to the in-flight upgrade PR instead of bailing out when the branch already exists.

- Authenticate as the **flipbook-backend GitHub App** (via `FLIPBOOK_BACKEND_APP_ID` / `FLIPBOOK_BACKEND_APP_PRIVATE_KEY`), matching our other PR-based workflows (e.g. Storyteller release). Commits and the PR created by this token trigger CI without a maintainer having to approve the run.
- When an upgrade branch already exists, **check it out and stack the version bump on top** rather than recreating it from `main`. This avoids destroying the code changes we often need to make to accommodate the new Foundation/RobloxPackages versions while a bump sits open.
- The version bump is now an **in-place edit** of the `ROBLOX_PACKAGES_VERSION` line (targets the assignment, so it works regardless of what version the branch currently has), committed and force-pushed on top of existing history (fast-forward only, so nothing is discarded).
- If there's no net change to `project.luau` (branch already at latest), it no-ops. The PR is only opened when the branch is newly created.

Replaces the `peter-evans/create-pull-request` step, whose default force-push-from-base behavior is what erased in-progress work before.

## Test plan

- [ ] Manually dispatch the workflow when no `upgrade-roblox-packages` branch exists → new branch + PR created, CI runs without approval.
- [ ] Add a local change to the branch, then dispatch again with a newer Studio version available → version bumped in place, prior commit preserved, no new PR opened.
- [ ] Dispatch when the branch is already at the latest version → no-op (nothing pushed).
