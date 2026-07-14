## Problem

Once an upgrade PR is open, the weekly RobloxPackages job stops making progress: it skips the run instead of advancing the in-flight PR. Its PRs also can't run CI on their own — a maintainer has to approve each run first.

## Solution

Run the job as the flipbook-backend GitHub App and commit the bump on top of the existing upgrade branch rather than rebuilding it from `main`. Two decisions the diff doesn't explain:

- **App token instead of `GITHUB_TOKEN`:** pushes and PRs authored by `GITHUB_TOKEN` don't trigger downstream workflows, which is why the job's PRs needed manual approval to run CI.
- **Commit on top instead of rebuilding from base:** these bumps stay open for weeks while we adapt Flipbook to the new packages, and rebuilding each run would discard that work.

## Testing

No automated coverage; exercised by dispatching the workflow.

## Notes for reviewers

Depends on `FLIPBOOK_BACKEND_APP_ID` / `FLIPBOOK_BACKEND_APP_PRIVATE_KEY` being granted to this repo (they're org secrets used by sibling repos).
