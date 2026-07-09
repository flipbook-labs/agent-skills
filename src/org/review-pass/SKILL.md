---
name: review-pass
description: "How to run a skills-driven pass over a change and close a task out: map the diff to the skills that govern each file, re-open those skills at the moment you touch the work, run the writing-style and code-comments critic passes over what you generated, and feed drift back with an agent-skills PR. Use when: a maintainer says 'take a pass with agent-skills' or 'apply the skills', you are reviewing your own or someone else's diff, or you are about to call a change done. Turns the routing index from a one-time startup read into a discipline you apply at production time."
type: process
---

# Review Pass

Reading a skill once at the start of a session does not make you apply it three hundred tool calls later when you write the thing it governs. This is the pass that closes that gap. Run it when you take a review pass over a change, and again as the last step before you call a task done. It routes you back into the specific skills at the point of production, after the session-start read has faded.

## Route at production time

The routing index (the library's `AGENTS.md`) is an entry point, not the whole read. Re-open the specific `SKILL.md` at the moment you do the work it covers. When you start writing a workflow, open `org/github-actions`. When you draft a changelog entry, open `org/changelog-entries`. A skill you read an hour ago is context you have half-forgotten, so re-reading the clause you are about to lean on is cheaper than the review round that catches you skipping it.

## Map the diff to the skills

Take the files the change touches and pull each into the skills that govern it. Run each skill over its files before you finish.

| A change that touches… | Runs through… |
| --- | --- |
| Luau source (`*.luau`) | `org/write-luau-code`, `org/code-comments` |
| Luau tests (`*.spec.luau`) | `org/write-luau-tests` |
| Workflows and actions (`.github/workflows/*.yml`, `action.yml`) | `org/github-actions`, `org/repo-conventions` |
| Repo setup, CI policy, `.lute/` scripts | `org/repo-conventions` |
| A `.changes/` entry or `CHANGELOG.md` | `org/changelog-entries` |
| A README or getting-started doc | `org/user-facing-docs` |
| Any prose you generate (PR body, commit message, comments, docs) | `org/writing-style` |
| The shape and scope of the change itself | `org/reviewable-changes` |

Treat the map as a floor. If a change touches something no row names, find the skill in the index that fits and run it too.

## Run the critic passes over what you wrote

Two passes catch the most, and both apply only to text and code you generated, never to what a human already wrote:

- **`org/writing-style` self-critic** over every piece of prose in the change. Re-read for the banned patterns and for any claim you did not verify.
- **`org/code-comments`** over every comment you added. Delete the ones that only narrate, keep the ones that state a constraint the code cannot show.

## Feed drift back the same session

The pass is also where you honor the library's maintenance norm. Ask whether anything you just did contradicted or strained a skill you loaded: a rule that read as permission when it should have caught you, an anchor that points at a renamed symbol, a "known bug" you just fixed. If so, fix the skill and add a `.changes/` entry in the same effort. Open an agent-skills PR when you are working in this repo, or run `lute run contribute-skills` (it opens a draft PR) when you noticed the drift from a consumer repo. Do not let the observation evaporate because the immediate task is done.

## When not to use

This skill is the procedure for applying the others, not a replacement for them. Read each governing skill for its own rules: `org/writing-style` for voice, `org/code-comments` for the comment bar, `org/write-luau-code` for Luau style, `org/github-actions` for workflow craft, `org/changelog-entries` for entry content, `org/reviewable-changes` for scope. For how the library is laid out and how routing works, see the library's `AGENTS.md` and `CONTRIBUTING.md`.

---

## Provenance and Maintenance

**Date stamped:** 2026-07-09. Written after a changewrite review where an agent read the relevant skills at the start of the session but still shipped a bundled module and missed the maintenance-feedback callout, because nothing re-fired the skills at production time or at task close. The file-type map is derived from the current `org/` skill set. Examples are illustrations, not pointers into any repo's source.

**Re-verify these claims when this skill next loads:** confirm the file-type map still names live skills. Run `ls src/org` and check that every skill referenced in the table and in "When not to use" still exists under `src/org/<name>/SKILL.md`. If one was renamed or retired, update the row. The routing discipline itself is durable doctrine with no volatile layer.
