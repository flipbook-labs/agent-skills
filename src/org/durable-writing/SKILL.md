---
name: durable-writing
description: "Write PR bodies, commit bodies, code comments, and changelog entries for the reader who arrives later with the artifact but not your session: capture the durable why the diff cannot show, and cut prose that narrates the change itself. Use when: writing or editing a PR description, commit body, code comment, or changelog entry in any flipbook-labs repo, or reviewing a draft that reads like a play-by-play of the diff. Names the transition-versus-destination root that org/code-comments and org/changelog-entries each cover one slice of. Defers to org/writing-style for voice."
type: process
---

# Durable Writing

The recurring failure in prose an agent attaches to a change is describing the _transition_ instead of the _destination_: a PR body narrates the diff, a comment explains how the code used to be, a changelog says "previously." All three are the same move, writing about the act of changing the artifact rather than the artifact as it will exist. This skill names that root. The artifact-specific skills each own one surface of it.

Hold this frame: you are writing for the reader who arrives later with the artifact but not your session. They have the merged code, the diff, and the blame. They do not have your branch, your task history, or the bug you just chased. Write for them, not for the reviewer watching this one change land.

## Start from the template, not a blank page

The first move is not writing — it is fetching the template. Agents reach for a blank page and invent their own headings, but the house already has them, and a body that ignores them reads as off-pattern next to every human PR. So before you draft a PR body, find the template and fill _its_ sections. Look in order: the repo's own `.github/pull_request_template.md`, then the org fallback `flipbook-labs/.github/pull_request_template.md`. The repo template wins when both exist, but many repos carry none and rely on the org default — and that org-level file is the one agents habitually fail to look up a level to find. Then skim a few recent merged, human-authored PRs filled against that template, so what you write sits uniformly beside theirs and you can see how they use each section.

Everything below governs what goes _inside_ those sections. `Problem` and `Solution` hold the non-derivable why; `Notes for reviewers` holds blast radius and the calls you are unsure about. A `Testing` section is for verification a reader cannot get from CI — real manual steps — not a checklist that restates the pipeline (`- [x] ran the unit tests` is noise; CI already reports that). When the honest answer is "nothing beyond CI," say so in a line rather than padding the section to fill the heading. Close the filled body with the AI-authorship disclosure line (see [`org/writing-style`](../writing-style/SKILL.md)): it sits below the last section, and it is the one line you never trim.

## Two things rot, and you can catch both without foresight

You cannot predict what a future reader will need, and you do not have to. The two failure modes here are mechanical.

**Derivable prose.** The reader has the diff open, so anything they would learn by reading it is noise. A PR body that lists the files it touched, a comment that restates the line below it, a changelog that enumerates every renamed function: all recoverable from the change itself, all wasted words. This is the delete-and-rewrite test from [`org/code-comments`](../code-comments/SKILL.md) pointed at every artifact. If a competent reader with the diff would know it anyway, cut it.

**Present-moment prose.** Anything true only at the instant you write it rots on merge. "Stacked on #2," "review that first," "previously this used X," "new in this PR," "moved from Y," "fixes what the bot flagged." The artifact does not remember it used to be different, and the words attached to it should not either.

## The session-salience tell

This is the proxy for foresight that works in practice. The facts most present in your head as you finish a task are present because of how the session unfolded: what branch you are on, what you just changed, what a reviewer or bot said, what larger change this was split from. Session-provenance runs almost exactly opposite to durability. The fact that feels most worth mentioning is usually the one that rots first.

So before you write a line, ask: is this true about the code, or about how I got here? The first belongs. The second gets cut or reframed. Answering that needs no view of the future, only noticing why the fact is in your head.

## What survives: the non-derivable why

Subtraction is the mechanical half, and it is most of the win. The other half needs real understanding of the change and cannot be forced, so when you have it, this is what earns the space:

- The constraint from _outside_ the diff: another system's behavior, a platform limit, a downstream consumer, an ordering requirement.
- The alternative you rejected, and why, so a reviewer does not spend the review re-proposing it.
- The blast radius: what to scrutinize, what could break that the diff does not make obvious.
- The known gap: what this deliberately does not do, or a test you could not write.

When you have none of it, a short true body beats a long derivable one. "Add the FileSink" with nothing to add is a complete PR body. Do not pad it by restating the diff in sentences.

## Reframe, do not just delete

Some transient facts are genuinely useful. A change split from a larger one is worth noting. The move is to phrase it so it survives, not to lead with it. "Stacked on #2, review that first" is session-state and dies on merge. "Builds on #2" is the same fact in artifact-state and stays true afterward. Give legitimately transient context its most durable phrasing, or an explicit expiry, rather than letting it read as permanent and quietly go stale.

## Tense follows the frame, not the section

Tense is not a per-section rule to memorize. It falls out of the destination frame, so you do not have to track "which tense does a `Solution` take" against "which does a `Problem` take". Write each sentence about a state that is true of the merged artifact rather than about the act of changing it, and the tense picks itself. A `Problem` reads in present tense because the thing it names is wrong right now: "the sink drops events under backpressure," not "the sink was dropping events." A `Solution` reads in present tense for the same reason, because you are describing how the code now works: "the sink buffers to disk and replays on reconnect."

The pull toward past tense in a `Solution` is the transition-narration this skill already warns about, wearing a verb. "Added a buffer," "changed the retry logic," "moved the parser" all describe what you did against code the reader does not have. Recast each as the state it produced and it returns to present tense on its own. This is why the guidance generalizes past a tidy `Problem`/`Solution` pair: any section, heading, or loose paragraph that describes the artifact wants the present tense, because the artifact is what it is.

Past tense earns its place only for a real event that happened once and left no state to point at: what you verified ("checked the vertical layout in Studio against the spec"), or an alternative you tried and rejected ("a single shared drag detector let the two thumbs fight over focus"). Those are events, not descriptions of the thing that shipped. Everywhere else, when a line reaches for past tense, check whether it is narrating the change instead of describing the result.

## Worked examples

[`examples/`](examples/README.md) walks two real PR bodies from an agent's default draft down to a slim, template-fitted final, with each cut mapped to the test that catches it. The [workflow PR](examples/workflow-pr/README.md) carries technical whys, and shows why the deepest cut comes from a pass that is not attached to the words it is cutting. The [skills PR](examples/skills-pr/README.md) is a docs-only change where almost everything is derivable from the diff, so the honest body is short and one scope judgment is all that survives. It also catches a line that had already rotted: a reference to another PR as still in flight, written after that PR merged.

## When not to use

This skill is the cross-cutting root. For the surface rules, read the matching skill: [`org/code-comments`](../code-comments/SKILL.md) for when a comment earns its place, [`org/changelog-entries`](../changelog-entries/SKILL.md) for release notes read in isolation, [`org/reviewable-changes`](../reviewable-changes/SKILL.md) for scoping the diff itself. For voice and banned patterns in any of them, [`org/writing-style`](../writing-style/SKILL.md). This skill governs what to capture and for whom. Those govern the surface and the sound.

---

## Provenance and Maintenance

**Date stamped:** 2026-07-13. Written from Marin's standing observation that agents narrate the changeset instead of capturing what a reviewer cannot derive from it, seen across PR bodies, commit messages, and code comments. It consolidates the transition-versus-destination root that [`org/code-comments`](../code-comments/SKILL.md) (the "change-log talk" ban), [`org/changelog-entries`](../changelog-entries/SKILL.md) (read it in isolation), and [`org/writing-style`](../writing-style/SKILL.md) each reached from their own angle, and those skills now point here. The tense guidance ("Tense follows the frame, not the section") was added 2026-07-21 from a maintainer's observation that a `Problem` wants present tense while `Solution` prose keeps drifting to past-tense change-narration. It is framed as a surface of the transition-versus-destination root rather than a mechanical per-section lookup, so it holds for any section that describes the artifact.

**Re-verify these claims when this skill next loads:** nothing. This is `org/` doctrine with no single-repo anchors. If a sibling's cross-link here is renamed or retired, or the org's approach to durable writing shifts, update this skill and add a `.changes/` entry.
