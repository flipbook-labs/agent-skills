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

- `org/changelog-entries`: what goes in a changelog / `.changes` entry and who it is for. Reading in isolation (no PR or in-progress-work references), cutting length, matching the audience (developer-facing detail for a library, high-level summaries for a plugin), and choosing the category, kind, flags, highlight, and `release.md` summary. Defers to `org/writing-style` for voice. `type: process`.
- `org/code-comments`: when a code comment earns its place, which is when it states a constraint or rationale the code cannot show. The delete-and-rewrite test, the forbidden kinds (narration, change-log talk, self-justification), and an exemplar. Run it over any code you write or edit. `type: process`.
- `org/durable-writing`: write PR bodies, commit bodies, comments, and changelog entries for the future reader who has the artifact but not your session. The transition-versus-destination root, the derivability and present-moment tests, the session-salience tell (is this true about the code or about how I got here), reframing transient context durably, and choosing tense from the destination frame (present tense for a section that describes the artifact, past tense only for real completed events). Its `pr-descriptions.md` reference covers a PR body's craft: what each template section is for, whose voice an agent writes in, length, the one idea, readying the reviewer for the diff, recording assumptions, and a model description. The cross-cutting root that `org/code-comments` and `org/changelog-entries` each cover one slice of. Read before writing any prose attached to a change. `type: process`.
- `org/github-actions`: how to author workflows and actions well. Bash safety (`set -euo pipefail`, symmetric backup/restore), YAML minimalism, structuring jobs so a condition is written once instead of on every step, noun job names with no parentheticals, keeping broken platforms in the matrix, SCREAM_SNAKE env vars, bot-PR ergonomics, and `action.yml` metadata. The authoring companion to `org/repo-conventions`. `type: process`.
- `org/repo-conventions`: repo setup and CI conventions for any flipbook-labs repo. Pinning GitHub Actions by trust boundary, 5-minute job timeouts, strictness from `.luaurc` instead of `--!strict` headers, check logic in `.lute/` scripts rather than workflow YAML, `@std/*` over `@lute/*`, and fetching dev-tool artifacts from upstream `main`. Read before creating a repo, writing or reviewing a workflow, or writing a Lute script. `type: process`.
- `org/review-pass`: how to run a skills-driven pass over a change and close a task out. Map the diff to the skills that govern each file, re-open them at production time rather than trusting the session-start read, run the `org/writing-style` and `org/code-comments` critic passes over what you generated, and feed skill drift back with an agent-skills PR. Read when a maintainer says "take a pass with agent-skills", when reviewing a diff, or before calling a change done. `type: process`.
- `org/reviewable-changes`: how to scope a change so it is easy to review and safe to land. Keep the diff small and do not move code you do not have to, separate refactoring from features, make an unavoidable reorganization's diff tell its story, do not expose public API or add dependencies ahead of the feature that needs them, defer discovered rework to a follow-up, and remove temporary code before merge. Read when planning a PR or refactoring alongside a feature. `type: process`.
- `org/user-facing-docs`: writing a README or getting-started doc for a package. Center the product not its implementation, apply the is-this-useful-to-an-end-user filter, and ship at least one concrete runnable example. Defers to `org/writing-style` for voice and to `flipbook/write-docs` for the Flipbook docs site. `type: process`.
- `org/write-luau-code`: the house Luau style. Type discipline (`unknown` over `any`, named types), expanded tables, verb-and-`is` naming with one term per concept, stdlib-first idioms (colon notation, no redundant asserts, import aliases, require ordering), frozen-table enums, `err`/`problem` error fields, one-responsibility modules, and not abstracting ahead of need. Read before writing or editing Luau source anywhere, including `.lute/` scripts. `type: process`.
- `org/write-luau-tests`: writing unit tests that specify intended behavior and can actually fail. The red-first gate, forbidden moves (tautologies, mocking the subject, coverage theater), and the definition-of-good rubric. Vendor-neutral doctrine. Repo-specific runner and framework mechanics live in that repo's own test skill. `type: process`.
- `org/writing-style`: the house voice for prose you generate (skills, docs, PRs, commit messages, changelog entries). The no-conventional-commits rule for commit and PR titles, sentence craft (people and parts of the system as subjects, known before new, one idea per sentence, problems at their real size, issue numbers that support a sentence instead of carrying it), the banned patterns (antithesis framing, hype words, em dashes, semicolon overuse), and the self-critic pass. Run it over any prose you write or edit. `type: process`.

### Family: Flipbook / Storyteller / ModuleLoader (`family/`)

_none yet_

### Flipbook (`flipbook/`)

- `flipbook/architecture`: Flipbook's non-obvious design contracts. Pluginlike and embedding, the Flipbook to Storyteller to ModuleLoader layering, why state lives in Charm, reload behavior, plugin versus embedded limits, and the community-first policy for the internal build, telemetry, and claims about other tools. Use when: changing embedding or bootstrap code, story loading, stores, telemetry, or the internal build. `type: knowledge`.
- `flipbook/dev-env`: set up, repair, and validate the Flipbook, Storyteller, and ModuleLoader environment. Installs, `.env`, lint, analyze, cloud tests and their Open Cloud key, testing local Storyteller or ModuleLoader changes in Flipbook, StudioPlugins, and what counts as evidence for a fix. Use when: setting up, running checks, tests cannot run, or testing a dependency change in Flipbook. `type: process`.
- `flipbook/release`: how releases happen and what an agent must not do in them, channels and assets, CI environments and secrets, storybook previews, PostHog release reporting, and the rules for telemetry, community parity, and dependency bumps. Use when: a change touches releases, publishing, workflows, telemetry, or dependencies. `type: process`.
- `flipbook/troubleshooting`: non-obvious runtime and build failures, past incidents not to repeat, and measurement techniques. Use when: the plugin is stale, an injected global is wrong, tests wait on a fork PR, a Windows or Rotriever build breaks, or you need evidence for a build or re-render fix. `type: knowledge`.
- `flipbook/use-studio-mcp-for-flipbook`: build and validate Flipbook through Studio MCP and FlipbookAgentGateway. Use when: driving a local Flipbook build, changing gateway actions, or verifying Stories through semantic actions, embedded Play-mode input, and screenshots. `type: process`.
- `flipbook/write-docs`: authoring Flipbook's Docusaurus docs site. Where pages live, the sidebar, code samples, and grounding every claim in source. Defers to `org/writing-style` for voice. `type: process`.

### AgentGateway (`agent-gateway/`)

- `agent-gateway/use-agent-gateway`: driving Studio plugins that expose actions via an AgentGateway. Finding a gateway and speaking the `list`/`call` protocol through the Roblox Studio MCP server. `type: knowledge`.
