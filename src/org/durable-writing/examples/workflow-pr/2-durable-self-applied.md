## What this changes

The weekly RobloxPackages upgrade updates the in-flight upgrade PR in place, including when its branch already exists.

## Why it's built this way

- **Runs as the flipbook-backend GitHub App** rather than the default `GITHUB_TOKEN`. A push or PR authored by `GITHUB_TOKEN` cannot trigger `on: push` / `on: pull_request` workflows, so CI on the upgrade PR would sit unrun until a maintainer manually approved it. An app token triggers those workflows, matching the other PR-based workflows in the org (e.g. Storyteller's release).
- **Stacks the version bump onto the existing branch instead of rebuilding it from `main`.** An upgrade can stay open for weeks while we work out the code changes needed to accommodate the new packages; rebuilding the branch from base each run would discard that work. Checking out the branch and committing on top preserves it.
- **Plain push, not force.** If someone pushes to the branch between the fetch and the push, the push fails and the run can be retried, rather than a force push silently overwriting their commit.
- **The version edit rewrites the `ROBLOX_PACKAGES_VERSION` assignment line**, so it lands the latest version regardless of what the branch currently holds, and no-ops when the branch already matches.

## Watch out for

- Depends on `FLIPBOOK_BACKEND_APP_ID` / `FLIPBOOK_BACKEND_APP_PRIVATE_KEY` being available to this repo. They're org secrets used by sibling repos, but worth confirming they're granted here.
- A pull request is opened only when the branch is created fresh; on an existing branch the job just pushes the bump.

## Verifying

- Dispatch with no `upgrade-roblox-packages` branch → branch and PR created, CI runs without approval.
- Add a commit to the branch, then dispatch with a newer Studio version available → version bumped on top, the added commit intact, no second PR.
- Dispatch when the branch already holds the latest version → nothing pushed.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
