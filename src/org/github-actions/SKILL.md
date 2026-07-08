---
name: github-actions
description: "How to author GitHub Actions workflows and actions well in flipbook-labs: bash safety, YAML minimalism, job structure over repeated step conditions, noun job names, full-platform matrices, SCREAM_SNAKE env vars, bot-PR ergonomics, and action.yml metadata. Use when: writing or reviewing a .github/workflows/*.yml file, an action.yml, or a release/CI automation. For the policies a repo is configured against (action pinning, timeouts, .luaurc strictness) see org/repo-conventions."
type: process
---

# GitHub Actions

The craft of writing workflows and actions the way they get reviewed into shape. This skill is the *authoring* companion to [`org/repo-conventions`](../repo-conventions/SKILL.md): that one sets the policies a repo is configured against (pin actions by trust boundary, ~5-minute timeouts, keep check logic in `.lute/` scripts). This one is how the YAML itself should read.

## Bash steps are strict and symmetric

- **Start every bash `run:` block with `set -euo pipefail`.** Without it a failed command in the middle of a step is silently ignored and the step marches on into a worse state. Marin flagged this repeatedly: a save step needs `set -euo pipefail` so a failed `cp` aborts before a later `--remove` runs.
- **Back up and restore symmetrically.** If a step stashes a file (say `auth.toml`) to mutate it, restore it in an `if: always()` step with the opposite operation, so a mid-job failure cannot leave the workspace dirty.
- **Hoist a repeated literal to a top-level `env:`.** When the same binary path or value appears across steps, define it once in `env:` rather than repeating it.

## Keep the YAML minimal

Remove anything the workflow does not actually use. Unused inputs, a `workflow_dispatch` trigger nobody triggers, a job `name:` on a non-matrix job, a variable that is now inlined, a second workflow file that could fold into the first. Marin's reviews trim these constantly. A workflow should show only what is load-bearing, because every extra knob reads as meaningful and costs the next reader attention.

## Structure jobs so a condition is written once

Do not tack the same `if:` onto step after step. When a whole section runs only under a condition, lift it into its own job with one job-level `if:`, so downstream jobs can `needs:` it and skip cleanly. Marin: *"I really don't like that we have to tack a condition onto practically every step... Can we restructure things so that we do not need to keep repeating the same condition?"* A dedicated `detect-changes` job that gates the rest is the usual shape. While you are there, make `concurrency` deliberate: a group on its own serializes overlapping runs by queueing them, which is what a deploy wants. Add `cancel-in-progress: true` only where a newer run should supersede one already in flight (preview builds on a busy PR), never on a job mid-deploy.

## Name jobs and steps for a reader scanning logs

- **Job names are nouns for what they produce:** `detect-changes`, not `detect-releasable`.
- **Use an unambiguous verb** where a verb is right: `Publish`, not `Release` (which is also a noun).
- **Title Case step names, and no parentheticals.** Write `Build`, not `build` and not `Build (verifies dist hygiene)`. If a step needs explaining, the explanation goes in the script it calls, not in its name.

## Environment variables are SCREAM_SNAKE_CASE

Workflow `env:` names are all-caps snake case (`VERSION`, `RELEASE_URL`), which sets them apart from step outputs and expressions at a glance.

## Keep every platform in the matrix, even a broken one

Do not drop a platform from the build matrix because it currently fails. Keep the job and mark the failure as tolerated with `continue-on-error` (or a scoped `if`), so the breakage stays visible and gets re-enabled deliberately. Marin: *"Stop excluding windows. The job is broken right now but that doesn't mean we omit it."* Pair the toleration with a comment that says why the failure is accepted and what still must pass.

## Bot-authored PRs announce themselves

When a workflow opens a PR:

- **Prefix the title** so a human spots the automation: `[bot] Publish v1.2.3`.
- **Write a body that explains the cascade.** Say what merging will actually do (create and push a tag, cut a release) so no one is surprised. Drop the generic "Summary" and "Test plan" scaffolding: an auto-generated body that repeats the same boilerplate on every run trains reviewers to ignore it. See [`org/changelog-entries`](../changelog-entries/SKILL.md) for the release-note wording itself.

## Authoring an action (`action.yml`)

- **Attribute to the org:** `author: flipbook-labs`, not an individual.
- **Omit optional metadata until it earns its place.** Leave out `branding:` early rather than filling it in speculatively.
- **Order the inputs table name, required, description, default.** Put the default last so a reader scans purpose before value.
- **Nudge users toward GitHub Environments** for credentials in the README (a `production` environment holding the API key and universe id), rather than repo-level secrets.
- **Keep related action versions aligned.** If a workflow uses both `upload-artifact` and `download-artifact`, pin them to the same major version so they cannot drift apart.

## When not to use

For the policies this authoring builds on (which actions may use a tag versus a SHA, job timeouts, why check logic belongs in `.lute/` scripts), see [`org/repo-conventions`](../repo-conventions/SKILL.md). For the Luau inside a `.lute/` script a workflow calls, see [`org/write-luau-code`](../write-luau-code/SKILL.md). For the body text of a release changelog, see [`org/changelog-entries`](../changelog-entries/SKILL.md).

---

## Provenance and Maintenance

**Date stamped:** 2026-07-07. Distilled from Marin's review comments on release and CI automation across flipbook-cli, changewrite, deploy-storybook, and module-loader (bash `set -euo pipefail`, YAML minimalism, hoisting conditions to jobs, noun job names, full-platform matrices, SCREAM_SNAKE env vars, bot-PR ergonomics, action.yml metadata). Quotes are frozen illustrations, not live pointers into any repo's workflows.

**Re-verify these claims when this skill next loads:** nothing mechanical. This is `org/` doctrine with no single-repo anchors. If a GitHub Actions feature changes (a new syntax for matrix toleration, a change to environments) or the org adopts a different CI runner, update the affected section and add a `.changes/` entry.
