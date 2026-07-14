---
name: writing-style
description: "The house voice for prose you generate: skills, docs, PR descriptions and titles, commit messages, changelog entries, comments. Use when: writing or editing any prose in a flipbook-labs repo, naming a commit or PR, or running a critic pass over your own draft for AI tells. Covers the voice, the no-conventional-commits rule for commit and PR titles, the banned patterns (antithesis framing, hype words, em dashes, semicolon overuse), and the self-critic pass."
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

## No em dashes

A hard rule. Recast the sentence with a period, comma, parentheses, or colon. It applies to prose and to list blurbs alike: write a label and its blurb with a colon (`Label: blurb`), never with an em dash between them.

The rule covers the em-dash character `—` and every substitute for it. A double hyphen (`--`) used as an em dash, an en dash, or any other sentence punctuation is banned the same way, in prose and in code comments. "The test runs fast -- most of the time" fails the rule. Recast it as "The test runs fast, most of the time." Luau comment syntax is a separate matter: a comment may open with `--`, but a `--` inside the comment text, standing in for a dash, is still a violation.

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

**Date stamped:** 2026-07-08. The voice, banned-patterns list, and critic pass generalized from Flipbook's `write-docs` skill. The commit-message and PR-title convention (no conventional-commit prefixes) was added from the maintainer's direction that this org does not use conventional commits. The em-dash ban was extended to spell out that a double hyphen (`--`) used as sentence punctuation counts as an em dash, after agents reached for `--` to slip past the `—` ban. Soft-wrapping, avoiding parentheticals, and capitalizing product names were added from recurring corrections across agent-gateway, Storyteller, and Changewrite reviews. The Flipbook and Obsidian docs-site mechanics stay in `flipbook/write-docs`, which defers here for voice.

**Re-verify these claims when this skill next loads:** this skill is pure doctrine and makes no claims about any repo's source, so it has no volatile layer to re-derive. When a repo's own writing or docs skill drifts from this voice, fix it there, and if the voice itself changes, update this skill and add a `.changes/` entry.
