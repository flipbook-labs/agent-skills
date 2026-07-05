---
name: writing-style
description: "The house voice for prose you generate: skills, docs, PR descriptions, changelog entries, comments. Use when: writing or editing any prose in a flipbook-labs repo, or running a critic pass over your own draft for AI tells. Covers the voice, the banned patterns (antithesis framing, hype words, em dashes), and the self-critic pass."
type: process
---

# Writing Style

The house voice for anything you write or edit in this org. The point is to make agent output predictable so a human can steer it the rest of the way, not to police prose a person already wrote.

## Scope: this constrains what *you* generate

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

Before declaring any prose done, re-read the text *you* wrote or edited with one job: find (a) any claim not backed by something you verified, and (b) any phrase matching the banned patterns above. Fix those. Running this as a separate pass catches far more than self-checking while you draft. It applies only to text you generated (see the scope note).

---

## Provenance and Maintenance

**Date stamped:** 2026-07-05. The voice, banned-patterns list, and critic pass generalized from Flipbook's `write-docs` skill; the Flipbook and Obsidian docs-site mechanics stay in `flipbook/write-docs`, which defers here for voice.

**Re-verify these claims when this skill next loads:** this skill is pure doctrine and makes no claims about any repo's source, so it has no volatile layer to re-derive. When a repo's own writing or docs skill drifts from this voice, fix it there, and if the voice itself changes, update this skill and add a `.changes/` entry.
