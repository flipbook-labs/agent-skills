# agent-skills

The shared, vendor-neutral home for **every agent skill in the flipbook-labs org**:
cross-cutting doctrine, the Flipbook↔Storyteller↔ModuleLoader family contract, and
repo-specific knowledge. Distributed as a versioned Loom package (`AgentSkills`) so
any repo can depend on it and pin a known-good version. See [README.md](README.md)
for how to consume it and [CONTRIBUTING.md](CONTRIBUTING.md) for how to author skills.

## How routing works

Skills live under `src/<scope>/<name>/SKILL.md` and are **loaded on demand**, not
kept in always-on context. Routing is manual: **scan the Project Skills index below;
when a task matches a trigger, read that `SKILL.md` first.** The index is part of the
library. **Adding, renaming, or retiring a skill requires updating this index in the
same commit**, or the skill silently stops being found.

Scopes:

- **`org/`**: cross-cutting doctrine that applies to any flipbook-labs repo.
- **`family/`**: the Flipbook / Storyteller / ModuleLoader repo family.
- **`flipbook/`**: Flipbook-specific knowledge and runbooks.
- **`agent-gateway/`**: AgentGateway protocol and workflows.

Each entry declares a genre. `type: process` is a runbook (what to do next) and
`type: knowledge` is reference (how the system is and why). See CONTRIBUTING.md.

## Using these skills while you work here

This repo runs on its own library. An agent editing a skill, doc, or script here
is governed by the same skills it ships, so route to them the way a consumer repo
does. Because the skills are the source files under `src/`, there is no install or
resolve step: read them directly.

Before you write any skill, doc, code, or PR prose:

1. Read the **Project Skills** index below in full, so you know what exists. This
   read is unconditional.
2. When your task matches a trigger, open that `src/<scope>/<name>/SKILL.md` and
   read it before doing the work it covers.

Several skills govern the work itself: `org/writing-style` and `org/code-comments`
for prose, `org/write-luau-code` and `org/write-luau-tests` for Luau,
`org/reviewable-changes` and `org/review-pass` for scoping and reviewing the change,
and `org/changelog-entries` for the `.changes/` entry. Read the ones your task
touches before you start.

### Forward this to subagents

The Task tool spawns subagents in a fresh context that does not include this guide,
so they never see the gate unless you hand it to them. Whenever you delegate,
include in the subagent's prompt (1) the read-the-index gate above and (2) the
concrete `src/<scope>/<name>/SKILL.md` path(s) relevant to its task. Never assume a
subagent will find the skills on its own.

## Project Skills

> Scaffold: no skills seeded yet. Entries land here (in the same commit as each
> skill) as the library is populated. Format per line:
> ``- `<scope>/<name>`: <trigger-rich one-liner>.``

### Cross-cutting (`org/`)

- `org/changelog-entries`: what goes in a changelog / `.changes` entry and who it is for. Reading in isolation (no PR or in-progress-work references), cutting length, and matching the audience (developer-facing detail for a library, high-level summaries for a plugin). Defers to `org/writing-style` for voice. `type: process`.
- `org/code-comments`: when a code comment earns its place, which is when it states a constraint or rationale the code cannot show. The delete-and-rewrite test, the forbidden kinds (narration, change-log talk, self-justification), and an exemplar. Run it over any code you write or edit. `type: process`.
- `org/github-actions`: how to author workflows and actions well. Bash safety (`set -euo pipefail`, symmetric backup/restore), YAML minimalism, structuring jobs so a condition is written once instead of on every step, noun job names with no parentheticals, keeping broken platforms in the matrix, SCREAM_SNAKE env vars, bot-PR ergonomics, and `action.yml` metadata. The authoring companion to `org/repo-conventions`. `type: process`.
- `org/repo-conventions`: repo setup and CI conventions for any flipbook-labs repo. Pinning GitHub Actions by trust boundary, 5-minute job timeouts, strictness from `.luaurc` instead of `--!strict` headers, check logic in `.lute/` scripts rather than workflow YAML, `@std/*` over `@lute/*`, and fetching dev-tool artifacts from upstream `main`. Read before creating a repo, writing or reviewing a workflow, or writing a Lute script. `type: process`.
- `org/review-pass`: how to run a skills-driven pass over a change and close a task out. Map the diff to the skills that govern each file, re-open them at production time rather than trusting the session-start read, run the `org/writing-style` and `org/code-comments` critic passes over what you generated, and feed skill drift back with an agent-skills PR. Read when a maintainer says "take a pass with agent-skills", when reviewing a diff, or before calling a change done. `type: process`.
- `org/reviewable-changes`: how to scope a change so it is easy to review and safe to land. Keep the diff small and do not move code you do not have to, separate refactoring from features, make an unavoidable reorganization's diff tell its story, do not expose public API or add dependencies ahead of the feature that needs them, defer discovered rework to a follow-up, and remove temporary code before merge. Read when planning a PR or refactoring alongside a feature. `type: process`.
- `org/user-facing-docs`: writing a README or getting-started doc for a package. Center the product not its implementation, apply the is-this-useful-to-an-end-user filter, and ship at least one concrete runnable example. Defers to `org/writing-style` for voice and to `flipbook/write-docs` for the Flipbook docs site. `type: process`.
- `org/write-luau-code`: the house Luau style. Type discipline (`unknown` over `any`, named types), expanded tables, verb-and-`is` naming with one term per concept, stdlib-first idioms (colon notation, no redundant asserts, import aliases, require ordering), frozen-table enums, `err`/`problem` error fields, one-responsibility modules, and not abstracting ahead of need. Read before writing or editing Luau source anywhere, including `.lute/` scripts. `type: process`.
- `org/write-luau-tests`: writing unit tests that specify intended behavior and can actually fail. The red-first gate, forbidden moves (tautologies, mocking the subject, coverage theater), and the definition-of-good rubric. Vendor-neutral doctrine. Repo-specific runner and framework mechanics live in that repo's own test skill. `type: process`.
- `org/writing-style`: the house voice for prose you generate (skills, docs, PRs, commit messages, changelog entries). The no-conventional-commits rule for commit and PR titles, the banned patterns (antithesis framing, hype words, em dashes, semicolon overuse), and the self-critic pass. Run it over any prose you write or edit. `type: process`.

### Family: Flipbook / Storyteller / ModuleLoader (`family/`)

_none yet_

### Flipbook (`flipbook/`)

- `flipbook/write-docs`: authoring Flipbook's docs (the Obsidian vault and Docusaurus site). The workflow, the site mechanics (wikilinks, callouts, sidebar, code samples), and conventions. Defers to `org/writing-style` for voice. `type: process`.
- `flipbook/setup-dev-env`: set up or repair the Flipbook, Storyteller, or ModuleLoader development environment. Use when: first-time setup, installing dependencies, managing .env files, troubleshooting rokit/wally/lute, or repairing stale tooling. `type: process`.
- `flipbook/run-checks`: run validation checks (lint, analyze, test) in Flipbook, Storyteller, or ModuleLoader. Use when: running tests, lint, analyze, CI checks, quality checks, or verifying changes. `type: process`.
- `flipbook/test-dependencies`: verify local Storyteller or ModuleLoader changes inside Flipbook by overlaying built binaries. Use when: you changed storyteller or module-loader and need to test in Flipbook, or verifying a dependency change. `type: process`.
- `flipbook/develop-through-studioplugins`: special workflow for testing FlipbookCore changes through the StudioPlugins Flipbook plugin. Use only when: the engineer explicitly asks to verify changes through StudioPlugins. `type: process`.
- `flipbook/change-control`: PR workflow, version gating, CI gates, review discipline, and non-negotiables for Flipbook. Use when: preparing a PR, navigating release gates, or understanding the PR merge workflow. `type: process`.
- `flipbook/debugging-playbook`: symptom→solution runbook for runtime issues in Flipbook (stale plugin, hot-reload, re-renders, crashes, test failures). Use when: troubleshooting Flipbook runtime behavior. `type: process`.
- `flipbook/release-and-operations`: release runbooks, deployment orchestration, CI/CD operations, and the public release workflow for Flipbook. Use when: preparing a release, deploying Flipbook, or managing CI/CD. `type: process`.
- `flipbook/research-methodology`: hypothesis/evidence protocol for experiments, PR readiness, documenting dead ends, and proving claims via mechanism. Use when: designing an investigation, validating a fix, or documenting research. `type: process`.
- `flipbook/architecture-contract`: load-bearing design decisions, architectural invariants, and known weak points of Flipbook's architecture. Use when: understanding or extending system design, debugging architectural mismatches, or validating deep changes. `type: knowledge`.
- `flipbook/build-and-toolchain`: source→rbxm pipeline, Darklua transforms, env-global injection, build channels/targets, dead-code elimination, and the complete toolchain for building Flipbook. Use when: understanding the build process or modifying build output. `type: knowledge`.
- `flipbook/config-and-flags`: environment variables, injected globals, build channels/targets, and user settings in Flipbook. Use when: configuring build behavior, understanding global state, or setting user options. `type: knowledge`.
- `flipbook/community-and-positioning`: community-first doctrine, telemetry/privacy posture, and ecosystem claims for Flipbook. Use when: understanding Flipbook's positioning or community commitments. `type: knowledge`.
- `flipbook/domain-reference`: story/storybook contracts, Storyteller, module reload, control types, React-in-Roblox, and domain concepts. Use when: understanding Flipbook's conceptual model or story format. `type: knowledge`.
- `flipbook/diagnostics-and-tooling`: measurement, logging, test output parsing, build-cache inspection, and rerender accounting in Flipbook. Use when: debugging test failures, analyzing performance, or inspecting build state. `type: knowledge`.
- `flipbook/failure-archaeology`: past investigations, dead ends, reverted features, and unresolved bugs in Flipbook. Use when: investigating a behavior, checking if a "new" fix has been attempted before. `type: knowledge`.
- `flipbook/validation-and-qa`: evidence bar for proving a fix, test anatomy, spec writing, and QA standards for Flipbook. Use when: writing tests, proving a fix is correct, or understanding what evidence is required. `type: knowledge`.
- `flipbook/proof-and-analysis-toolkit`: prove claims via mechanism: require-graph, reload isolation, build determinism, and type-level proof. Use when: proving correctness, validating build behavior, or analyzing system properties. `type: knowledge`.
- `flipbook/story-controls-campaign`: story-controls work: reproducing gaps, ranked solutions, validation gates, and controls-related changes. Use when: implementing controls features or understanding the controls design. `type: knowledge`.
- `flipbook/research-frontier`: open research problems, blockers, milestones, and the future direction of Flipbook. Use when: exploring new capabilities or understanding long-term direction. `type: knowledge`.

### AgentGateway (`agent-gateway/`)

- `agent-gateway/use-agent-gateway`: driving Studio plugins that expose actions via an AgentGateway. Connecting to the Roblox Studio MCP server, discovering gateways by tag, and speaking the `list`/`call` protocol. `type: knowledge`.
