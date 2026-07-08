---
name: repo-conventions
description: "Repo setup and CI conventions for any flipbook-labs repo: pinning GitHub Actions by trust boundary, 5-minute job timeouts, strictness from .luaurc instead of --!strict headers, check logic in .lute/ scripts rather than workflow YAML, @std/* over @lute/*, and deterministic third-party downloads. Use when: creating a new repo, writing or reviewing a GitHub Actions workflow, adding a CI job, or writing a Lute script."
type: process
---

# Repo Conventions

The setup and CI conventions for flipbook-labs repos. Apply them from the first commit of a new repo, and hold new workflows and scripts in existing repos to the same bar. Older repos may predate some of these; when you touch their CI, bring it forward rather than copying the old pattern.

## Pin GitHub Actions by trust boundary

- Actions from implicitly trusted namespaces (`actions/*`, `flipbook-labs/*`) may use version tags.
- Every other action is pinned to a full commit SHA, with a trailing comment naming the version the SHA corresponds to.

```yaml
# Trusted namespace: a version tag is fine
- uses: actions/checkout@v4

# Anything else: full commit SHA, version in a trailing comment
- uses: some-org/some-action@0123456789abcdef0123456789abcdef01234567 # v1.4.2
```

Why: a tag is mutable, so a compromised third-party repo can silently repoint it at malicious code. A SHA fixes the exact code CI runs. Tags stay acceptable inside namespaces the org already has to trust (GitHub's own actions and this org's). The `# vX.Y.Z` comment keeps the pin readable and tells the next person what to compare against when bumping.

## CI jobs time out at about 5 minutes

Set `timeout-minutes` on every job, and reach for 5, not a reflexive 10. Raise it per job only when a job measurably needs longer.

Why: the timeout exists to cut off a hung job, and jobs in these repos finish in a minute or two. A padded ceiling doubles the wait and the billed runner minutes on every hang while protecting nothing.

## No `--!strict` file headers

Do not add `--!strict` headers to Luau source. Strictness is repo-wide state: `.luaurc` sets `"languageMode": "strict"`, and a luau-lsp analyze job in CI enforces it. `--!nocheck` on vendored files remains acceptable, because exempting code the repo does not own is a per-file decision by nature.

Why: one source of truth. Per-file headers drift (a new file forgets one and silently opts out), while the `.luaurc` setting plus an analyze job covers every file including the ones added tomorrow.

## Check logic lives in `.lute/` scripts, not workflow YAML

A workflow `run:` block should do no more than call `lute run <script>`. Shell pipelines, dist-hygiene checks, and any multi-step logic belong in a versioned script under `.lute/`.

Why: a `.lute/` script runs locally the same way it runs in CI, gets reviewed and analyzed as code, and can be shared between workflows. Logic inlined in YAML strings is none of these, and reproducing a CI failure means hand-copying shell out of a workflow file.

## Prefer `@std/*` over `@lute/*` in Lute code

Reach for `@std/*` first: it covers io, process, task, and fs. Drop to `@lute/*` only for a capability std does not expose.

Why: `@std/*` is the stable, portable surface, and keeping the `@lute/*` footprint small keeps scripts easier to move between runtimes and toolchain versions.

## Deterministic third-party downloads in CI

When a workflow downloads a third-party artifact (for example luau-lsp's globalTypes definitions), pin the URL to the release matching the tool's version in `rokit.toml`. Never fetch from `master` or `latest`.

Why: an unpinned URL changes underneath you, so the same commit can pass one week and fail the next. Matching the pinned tool version also prevents skew between the tool and its companion files, which fails in confusing ways.

## When not to use

This skill covers repo setup and CI mechanics. For test-writing discipline see [`org/write-luau-tests`](../write-luau-tests/SKILL.md), for changelog entry content see [`org/changelog-entries`](../changelog-entries/SKILL.md), and for the voice of any prose you write see [`org/writing-style`](../writing-style/SKILL.md).

---

## Provenance and Maintenance

**Date stamped:** 2026-07-07. Captured from the maintainer's review of the CI and release infrastructure PR for a new repo (flipbook-labs/archivist#4): action pinning by trust boundary, 5-minute timeouts, `.luaurc` over `--!strict` headers, workflow logic in `.lute/` scripts, `@std/*` over `@lute/*`, and pinned third-party downloads.

**Re-verify these claims when this skill next loads:** nothing mechanical. This `org/` skill is doctrine with no single-repo anchors. Its volatile edge is the named tooling (luau-lsp, rokit, Lute's `@std` library): if the repo you are working in has replaced one of these, follow that repo's setup and update this skill with a `.changes/` entry.
