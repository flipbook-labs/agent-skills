Runs the weekly RobloxPackages bump as the flipbook-backend GitHub App, and commits the bump on top of the existing upgrade branch rather than rebuilding it from `main`.

Two decisions the diff doesn't explain:

- **App token instead of `GITHUB_TOKEN`:** pushes and PRs authored by `GITHUB_TOKEN` don't trigger CI, so the upgrade PR's checks would sit unrun until someone manually approved the run.
- **Commit on top instead of rebuilding from base:** these bumps stay open for weeks while we adapt Flipbook to the new packages, and rebuilding each run would discard that work.

Requires `FLIPBOOK_BACKEND_APP_ID` / `FLIPBOOK_BACKEND_APP_PRIVATE_KEY` to be granted to this repo.
