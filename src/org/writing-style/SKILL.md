---
name: writing-style
description: "The house voice for prose you generate: skills, docs, PR descriptions and titles, commit messages, changelog entries, comments. Use when: writing or editing any prose in a flipbook-labs repo, naming a commit or PR, or running a critic pass over your own draft for AI tells. Covers the voice, sentence craft (characters as subjects, known before new, one idea per sentence, problems at their real size), the no-conventional-commits rule for commit and PR titles, the AI-authorship disclosure line on generated PR bodies, the banned patterns (antithesis framing, hype words, em dashes, semicolon overuse), and the self-critic pass."
type: process
---

# Writing Style

The house voice for anything you write or edit in this org. The point is to make agent output predictable so a human can steer it the rest of the way, not to police prose a person already wrote.

## Scope: this constrains what _you_ generate

It is not a linter to run against existing text. So:

- Do not produce these patterns in text you write or rewrite.
- Do not course-correct human prose. If a person wrote "simply," or any banned word, leave it. Only avoid generating it yourself. Editing a page near a human's "simply" is not a signal to go fix it.
- Do not open a PR or task to scrub existing text of these patterns unless the user explicitly asks.

## Voice

- Second person, addressed to the reader: "you can isolate…", "you need a Storybook."
- Warm and approachable. Friendly framing and encouraging closers ("you are now equipped to migrate your other stories") are part of the voice; keep them. Warmth is not hype (see the banlist).
- Plain declarative sentences. State what something does, not how impressive it is.
- Assume a competent reader. Do not over-explain the basics of the language or tools.

## Sentence craft

Voice is how the prose sounds. These habits decide whether a reader can follow it on the first pass. They matter most in prose a busy reader skims, like a PR body or a changelog entry, but they hold everywhere.

### Make people and parts of the system the subjects

Readers follow stories, and stories have characters doing things. Make the people and the parts of the system the subjects of your sentences, and make what they do the verbs. An abstract subject makes the reader work out who is doing what.

> **Before**
> Support for per-story themes requires a single source of truth for the active theme.

> **After**
> A story should be able to pick its own theme. For that, the active theme needs to live in one place that every story reads from.

The same goes for saying what something does. Name the thing, and let it act: "InputSlider clamps the result to the range," not "Clamping to the range is new."

### Start with what the reader knows

Open each sentence with something the reader already has, and end it with something new. The new part becomes the known part of the next sentence, so the reader never loses the thread.

> Three clients accept the current value as a string. The new producer emits a structured value, and two clients can't consume it without conversion. This page asks where conversion belongs and how clients move without a flag day.

It starts with what exists, says where that runs out, then says what that means for the reader. The same move links one section to the next. Read a PR body without its headings, and Solution should pick up where Problem left off.

### One idea per sentence

A short sentence lands whole. A long one makes the reader hold its start in mind while they work through the middle. When a sentence starts growing a list, ask whether the reader needs every item. Often one good example says more. Long sentences are fine when their ideas truly belong together, as long as the short ones carry the weight.

> **Before**
> The importer reads each row, validates it against the schema, which is loaded fresh from disk for every row, and writes it to the database, so a 10,000-row file opens the schema 10,000 times and takes about a minute.

> **After**
> The importer validates each row against the schema. It loads that schema from disk for every row. So a 10,000-row file opens it 10,000 times and takes about a minute.

### Say it at its real size

Describe a problem the way a calm colleague would mention it at their desk. Name what happens and who runs into it, and let the reader judge how serious it is. Save "never," "always," and "broken" for things that truly are that big.

> **Before**
> Pull requests that don't touch the CLI can never merge.

> **After**
> Pull requests that skip the CLI job get stuck waiting on a check that doesn't report, so they need a maintainer to merge them.

### Let numbers support the sentence

GitHub shows an issue's title when you hover its number, so a number needs no explanation after it. A sentence made mostly of numbers still asks the reader to hover each one. Say the relationship in words, and let one number carry it.

> **Before**
> This closes #508, part of #433. #509 and #510 queue and emit events from this catalog, and #507 links people to the page it publishes.

> **After**
> This is the first piece of opt-in telemetry (#433). The rest of that work sends events from this catalog, and the consent dialog links to the page it publishes.

## No em dashes

A hard rule. Recast the sentence with a period, comma, parentheses, or colon. It applies to prose and to list blurbs alike: write a label and its blurb with a colon (`Label: blurb`), never with an em dash between them.

The rule covers the em-dash character `—` and every substitute for it. A double hyphen (`--`) used as an em dash, an en dash, or any other sentence punctuation is banned the same way, in prose and in code comments. `The test runs fast -- most of the time` fails the rule. Recast it as `The test runs fast, most of the time.` Luau comment syntax is a separate matter: a comment may open with `--`, but a `--` inside the comment text, standing in for a dash, is still a violation.

Concrete check for the critic pass: flag any `--` that sits between spaces, or glues two words or clauses together in place of a dash, and recast it the way you would an em dash.

## Limit semicolons

Where you would reach for a semicolon, default to a period and a new sentence. A rare, deliberate semicolon is fine (for example, separating list items that contain commas), but joining two independent clauses with one is almost always two sentences in disguise. If a paragraph has more than one, recast it.

## Soft-wrap prose, never hard-wrap

Let prose reflow. Do not insert manual line breaks to wrap a paragraph at some column in Markdown, a README, a doc, or a PR body. One sentence or paragraph is one line; the renderer wraps it. Hard breaks fossilize a width and produce ragged diffs when the text is later edited. Marin: _"Don't hard wrap lines, rely on soft wrapping. Apply this generally, and apply to the PR body too."_ This governs the prose you emit; leave a human's existing hard wraps alone, per the scope note above.

## Avoid parenthetical asides

Prefer a direct sentence to a thought tucked in parentheses. When you catch yourself adding a parenthetical, either promote it to its own sentence because it matters, or cut it because it does not. Marin trims these in review: _"We can skip the parenthetical."_ A short clarifying parenthetical is not a crime, but a paragraph carrying several is a sign the sentences want restructuring.

## Capitalize our product names

Our tools are proper nouns: Flipbook, Storyteller, Changewrite, ModuleLoader. Capitalize them in prose even when the package id or repo is lowercase (`changewrite`, `module-loader`). Lowercase only a literal code identifier: a command, a path, an import.

## Commit messages and PR titles

Write them as a plain imperative summary. Do not use conventional-commit prefixes (`feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, and the rest) or a parenthesized scope. The prefix is ceremony that tells a reader less than the summary already does, and nothing in this org's release flow reads it (Changewrite decides version bumps from `.changes/` entries, not commit subjects).

- Open with a capitalized verb in the imperative: "Add the SLOP ALERT disclaimer", "Standardize the changelog voice", "Rename the render helper".
- Keep the subject to one line with no trailing period. Detail belongs in the body or the PR description.
- State what the change does. Which bucket it falls into is not information the reader needs.

## Disclose AI authorship

The account opening a pull request is the user's, so a reviewer assumes a person wrote the body unless you tell them otherwise. Tell them. Every PR body you generate ends with a disclosure line naming the tool that wrote it, so the reviewer reads it with the right expectations:

> 🤖 Generated with [Claude Code](https://claude.com/claude-code)

Swap in the marker for whatever agent authored the change (Cursor, Fable, and the rest). This holds even when you fill a repo's PR template: the disclosure is the body's closing line, below the last section. It is also the one line you never cut when slimming a body (see [`org/durable-writing`](../durable-writing/SKILL.md)). Trim derivable and rotted prose, never the disclosure.

## Banned patterns

**Antithesis / negation framing** (the most important one to catch):

- "It's not just X, it's Y."
- "This isn't about X, it's about Y."
- "Think of it less as X and more as Y."
- Any "not merely / not simply … but rather" construction.

**Hype and filler adjectives and verbs:** powerful, seamless, robust, elegant, effortless, blazing, lightning-fast, game-changing, supercharge, unlock, leverage, delve, crucial, essential, simply, just, simple, easy, easily.

**Rule-of-three padding:** "fast, reliable, and scalable" style triads that add adjectives without adding information.

**Meta-commentary and filler openers:** "In this section we'll explore…", "It's worth noting that…", "At its core…", "Let's dive in", "Without further ado."

**Vague benefit-speak:** sentences that sell a feeling instead of conveying a fact the reader can act on. Every sentence should leave the reader knowing something they can do or rely on.

When you catch yourself reaching for one of these, the fix is almost always to state the concrete behavior plainly instead.

## The self-critic pass

Before declaring any prose done, re-read the text _you_ wrote or edited with one job: find (a) any claim not backed by something you verified, and (b) any phrase matching the banned patterns above. Fix those. Running this as a separate pass catches far more than self-checking while you draft. It applies only to text you generated (see the scope note).

---

## Provenance and Maintenance

**Date stamped:** 2026-07-08. The voice, banned-patterns list, and critic pass generalized from Flipbook's `write-docs` skill. The commit-message and PR-title convention (no conventional-commit prefixes) was added from the maintainer's direction that this org does not use conventional commits. The em-dash ban was extended to spell out that a double hyphen (`--`) used as sentence punctuation counts as an em dash, after agents reached for `--` to slip past the `—` ban. Soft-wrapping, avoiding parentheticals, and capitalizing product names were added from recurring corrections across agent-gateway, Storyteller, and Changewrite reviews. The AI-authorship disclosure rule was promoted to org doctrine on 2026-07-16 from the maintainer's direction that an agent opens PRs as the user's account, so the body must set reviewer expectations. It consolidates the per-repo "disclose AI assistance" conventions the `flipbook/` skills already carried. The sentence-craft section was added 2026-11-14 from the maintainer's own PR-writing guide, generalized to all prose, with the PR-specific half living in [`org/durable-writing`](../durable-writing/pr-descriptions.md). The Flipbook and Obsidian docs-site mechanics stay in `flipbook/write-docs`, which defers here for voice.

**Re-verify these claims when this skill next loads:** this skill is pure doctrine and makes no claims about any repo's source, so it has no volatile layer to re-derive. When a repo's own writing or docs skill drifts from this voice, fix it there, and if the voice itself changes, update this skill and add a `.changes/` entry.
