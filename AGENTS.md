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

## Project Skills

> Scaffold: no skills seeded yet. Entries land here (in the same commit as each
> skill) as the library is populated. Format per line:
> `` - `<scope>/<name>`: <trigger-rich one-liner>. ``

### Cross-cutting (`org/`)

- `org/changelog-entries`: what goes in a changelog / `.changes` entry and who it is for. Reading in isolation (no PR or in-progress-work references), cutting length, and matching the audience (developer-facing detail for a library, high-level summaries for a plugin). Defers to `org/writing-style` for voice. `type: process`.
- `org/code-comments`: when a code comment earns its place, which is when it states a constraint or rationale the code cannot show. The delete-and-rewrite test, the forbidden kinds (narration, change-log talk, self-justification), and an exemplar. Run it over any code you write or edit. `type: process`.
- `org/github-actions`: how to author workflows and actions well. Bash safety (`set -euo pipefail`, symmetric backup/restore), YAML minimalism, structuring jobs so a condition is written once instead of on every step, noun job names with no parentheticals, keeping broken platforms in the matrix, SCREAM_SNAKE env vars, bot-PR ergonomics, and `action.yml` metadata. The authoring companion to `org/repo-conventions`. `type: process`.
- `org/repo-conventions`: repo setup and CI conventions for any flipbook-labs repo. Pinning GitHub Actions by trust boundary, 5-minute job timeouts, strictness from `.luaurc` instead of `--!strict` headers, check logic in `.lute/` scripts rather than workflow YAML, `@std/*` over `@lute/*`, and fetching dev-tool artifacts from upstream `main`. Read before creating a repo, writing or reviewing a workflow, or writing a Lute script. `type: process`.
- `org/review-pass`: how to run a skills-driven pass over a change and close a task out. Map the diff to the skills that govern each file, re-open them at production time rather than trusting the session-start read, run the `org/writing-style` and `org/code-comments` critic passes over what you generated, and feed skill drift back with an agent-skills PR. Read when a maintainer says "take a pass with agent-skills", when reviewing a diff, or before calling a change done. `type: process`.
- `org/reviewable-changes`: how to scope a change so it is easy to review and safe to land. Keep the diff small and do not move code you do not have to, separate refactoring from features, make an unavoidable reorganization's diff tell its story, do not expose public API or add dependencies ahead of the feature that needs them, defer discovered rework to a follow-up, and remove temporary code before merge. Read when planning a PR or refactoring alongside a feature. `type: process`.
- `org/use-foundation`: building UI with Roblox's Foundation design system in react-lua. FoundationProvider and theme resolution, styling with the `tag` utility system, design tokens via `useTokens`, component and enum idioms (`onActivated`, `stateLayer`, compound Dialog/Popover), `Foundation.CommonProps` passthrough, and when a raw Roblox instance is allowed. Read before writing or styling Foundation-based UI, or picking a color, spacing, or font. `type: process`.
- `org/user-facing-docs`: writing a README or getting-started doc for a package. Center the product not its implementation, apply the is-this-useful-to-an-end-user filter, and ship at least one concrete runnable example. Defers to `org/writing-style` for voice and to `flipbook/write-docs` for the Flipbook docs site. `type: process`.
- `org/write-luau-code`: the house Luau style. Type discipline (`unknown` over `any`, named types), expanded tables, verb-and-`is` naming with one term per concept, stdlib-first idioms (colon notation, no redundant asserts, import aliases, require ordering), frozen-table enums, `err`/`problem` error fields, one-responsibility modules, and not abstracting ahead of need. Read before writing or editing Luau source anywhere, including `.lute/` scripts. `type: process`.
- `org/write-luau-tests`: writing unit tests that specify intended behavior and can actually fail. The red-first gate, forbidden moves (tautologies, mocking the subject, coverage theater), and the definition-of-good rubric. Vendor-neutral doctrine. Repo-specific runner and framework mechanics live in that repo's own test skill. `type: process`.
- `org/write-react-code`: the house react-lua component style. Module anatomy and the `e` alias, exported `Props` types with defaults via Sift, named-children element trees, state placement (`useState` vs Charm signals and computeds), the context module shape (`Context`/`Provider`/`use*` hook), effect discipline, and colocated `.story.luau` and `.spec.luau` files. Read before writing or editing React components, hooks, stores, or contexts in any flipbook-labs repo. Defers to `org/use-foundation` for styling. `type: process`.
- `org/writing-style`: the house voice for prose you generate (skills, docs, PRs, commit messages, changelog entries). The no-conventional-commits rule for commit and PR titles, the banned patterns (antithesis framing, hype words, em dashes, semicolon overuse), and the self-critic pass. Run it over any prose you write or edit. `type: process`.

### Family: Flipbook / Storyteller / ModuleLoader (`family/`)

_none yet_

### Flipbook (`flipbook/`)

- `flipbook/write-docs`: authoring Flipbook's docs (the Obsidian vault and Docusaurus site). The workflow, the site mechanics (wikilinks, callouts, sidebar, code samples), and conventions. Defers to `org/writing-style` for voice. `type: process`.

### AgentGateway (`agent-gateway/`)

- `agent-gateway/use-agent-gateway`: driving Studio plugins that expose actions via an AgentGateway. Connecting to the Roblox Studio MCP server, discovering gateways by tag, and speaking the `list`/`call` protocol. `type: knowledge`.
