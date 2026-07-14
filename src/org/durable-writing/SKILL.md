---
name: durable-writing
description: "Write PR bodies, commit bodies, code comments, and changelog entries for the reader who arrives later with the artifact but not your session: capture the durable why the diff cannot show, and cut prose that narrates the change itself. Use when: writing or editing a PR description, commit body, code comment, or changelog entry in any flipbook-labs repo, or reviewing a draft that reads like a play-by-play of the diff. Names the transition-versus-destination root that org/code-comments and org/changelog-entries each cover one slice of. Defers to org/writing-style for voice."
type: process
---

# Durable Writing

The recurring failure in prose an agent attaches to a change is describing the _transition_ instead of the _destination_: a PR body narrates the diff, a comment explains how the code used to be, a changelog says "previously." All three are the same move, writing about the act of changing the artifact rather than the artifact as it will exist. This skill names that root. The artifact-specific skills each own one surface of it.

Hold this frame: you are writing for the reader who arrives later with the artifact but not your session. They have the merged code, the diff, and the blame. They do not have your branch, your task history, or the bug you just chased. Write for them, not for the reviewer watching this one change land.

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

## When not to use

This skill is the cross-cutting root. For the surface rules, read the matching skill: [`org/code-comments`](../code-comments/SKILL.md) for when a comment earns its place, [`org/changelog-entries`](../changelog-entries/SKILL.md) for release notes read in isolation, [`org/reviewable-changes`](../reviewable-changes/SKILL.md) for scoping the diff itself. For voice and banned patterns in any of them, [`org/writing-style`](../writing-style/SKILL.md). This skill governs what to capture and for whom. Those govern the surface and the sound.

---

## Provenance and Maintenance

**Date stamped:** 2026-07-13. Written from Marin's standing observation that agents narrate the changeset instead of capturing what a reviewer cannot derive from it, seen across PR bodies, commit messages, and code comments. It consolidates the transition-versus-destination root that [`org/code-comments`](../code-comments/SKILL.md) (the "change-log talk" ban), [`org/changelog-entries`](../changelog-entries/SKILL.md) (read it in isolation), and [`org/writing-style`](../writing-style/SKILL.md) each reached from their own angle, and those skills now point here.

**Re-verify these claims when this skill next loads:** nothing. This is `org/` doctrine with no single-repo anchors. If a sibling's cross-link here is renamed or retired, or the org's approach to durable writing shifts, update this skill and add a `.changes/` entry.
