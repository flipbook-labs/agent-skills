---
name: repo-conventions
description: "Repo setup and CI conventions for any flipbook-labs repo: pinning GitHub Actions by trust boundary, 5-minute job timeouts, strictness from .luaurc instead of --!strict headers, check logic in .lute/ scripts rather than workflow YAML, @std/* over @lute/*, and fetching dev-tool artifacts from upstream main. Use when: creating a new repo, writing or reviewing a GitHub Actions workflow, adding a CI job, or writing a Lute script."
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

Why: the timeout exists to cut off a hung job, and jobs in these repos finish in a minute or two. Nothing is special about 5 itself. It is ample headroom for jobs that should never run that long, and a fatter ceiling only doubles the wait and the billed runner minutes on every hang.

## No `--!strict` file headers

Do not add `--!strict` headers to Luau source. Strictness is repo-wide state: `.luaurc` sets `"languageMode": "strict"`, and a luau-lsp analyze job in CI enforces it.

Treat `--!nocheck` with the same scrutiny as an `any` cast: occasionally necessary, never routine. For code the repo does not own (vendored dependencies, generated files), the org's pattern is an intentional typechecking boundary in tooling config, such as the ignore globs in the workspace's VSCode `settings.json`, not a header that opts the file out. Never add a `--!nocheck` yourself; it needs a person's explicit approval.

Why: one source of truth. Per-file headers drift (a new file forgets one and silently opts out), while the `.luaurc` setting plus an analyze job covers every file including the ones added tomorrow. A `--!nocheck` header punches a silent hole in that coverage, which is exactly why a human signs off on each one.

## Check logic lives in `.lute/` scripts, not workflow YAML

A workflow `run:` block should do no more than call `lute run <script>`. Shell pipelines, dist-hygiene checks, and any multi-step logic belong in a versioned script under `.lute/`.

Why: a `.lute/` script runs locally the same way it runs in CI, gets reviewed and analyzed as code, and can be shared between workflows. Logic inlined in YAML strings is none of these, and reproducing a CI failure means hand-copying shell out of a workflow file.

## Prefer `@std/*` over `@lute/*` in Lute code

Reach for `@std/*` first: it covers io, process, task, and fs. Drop to `@lute/*` only for a capability std does not expose.

Why: `@std/*` is the stable, portable surface, and keeping the `@lute/*` footprint small keeps scripts easier to move between runtimes and toolchain versions.

## Fetch dev-tool artifacts from upstream main, not a pinned version

When a workflow downloads a companion artifact for a dev tool (for example luau-lsp's `globalTypes` type definitions), fetch it from the tool's upstream `main` branch, not a version-pinned URL:

```
https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/main/scripts/globalTypes.d.lua
```

Why: this artifact only affects local development and CI analysis, never the shipped build, so tracking upstream costs nothing when it is stable and surfaces a real upstream change immediately as a loud CI failure rather than letting a stale pinned copy drift. Pinning it to match `rokit.toml` and bumping it by hand is maintenance burden with no payoff. Marin made this call explicitly on archivist#4, overriding a bot's pin-to-version suggestion: _"Let's just use the main branch."_

This is the opposite of the action-pinning rule above, and deliberately so. A third-party _action_ executes with repository permissions, so a mutable tag is a supply-chain risk worth a SHA pin. A type-definition file consumed only by an analyzer has no such blast radius, so the tradeoff flips toward staying current.

## When not to use

This skill covers repo setup and the CI _policies_ a repo is configured against. For the craft of authoring workflow YAML and actions well (bash safety, YAML minimalism, job structure, naming, bot-PR ergonomics), see [`org/github-actions`](../github-actions/SKILL.md). For Luau code style and the idioms of a `.lute/` script's body, see [`org/write-luau-code`](../write-luau-code/SKILL.md). For test-writing discipline see [`org/write-luau-tests`](../write-luau-tests/SKILL.md), for changelog entry content see [`org/changelog-entries`](../changelog-entries/SKILL.md), and for the voice of any prose you write see [`org/writing-style`](../writing-style/SKILL.md).

---

## Provenance and Maintenance

**Date stamped:** 2026-07-07. Captured from the maintainer's review of the CI and release infrastructure PR for a new repo (flipbook-labs/archivist#4), then corroborated against their review comments across storyteller, changewrite, flipbook-cli, agent-gateway, deploy-storybook, and module-loader: action pinning by trust boundary, 5-minute timeouts, `.luaurc` over `--!strict` headers, workflow logic in `.lute/` scripts, `@std/*` over `@lute/*`, and fetching dev-tool artifacts from upstream `main`. The downloads guidance is stated from Marin's explicit archivist#4 decision (_"Let's just use the main branch"_), which reversed an earlier pin-to-version draft. The `--!nocheck` stance (same scrutiny as an `any` cast, tooling-config boundaries for vendored code, human approval per header) is from their review of agent-skills#14, which corrected an earlier "acceptable on vendored files" draft.

**Re-verify these claims when this skill next loads:** nothing mechanical. This `org/` skill is doctrine with no single-repo anchors. Its volatile edge is the named tooling (luau-lsp, rokit, Lute's `@std` library) and the luau-lsp `globalTypes` URL: if the repo you are working in has replaced one of these, follow that repo's setup and update this skill with a `.changes/` entry.
