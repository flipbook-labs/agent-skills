# Worked example: slimming a docs PR body

Four drafts of the body for one real change, the PR that added `org/write-react-code` and `org/use-foundation` to this library ([agent-skills#30](https://github.com/flipbook-labs/agent-skills/pull/30), an illustration rather than a live anchor). The diff never changed between drafts, only the prose did. This is the case the workflow example does not cover: a docs-only change, where almost everything a reviewer would want is already in the diff, so the honest body turns out short.

| Draft | File                                                     | What it shows                                                                             |
| ----- | -------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| 1     | [`1-default.md`](1-default.md)                           | The default: a paragraph per skill restating its index entry, plus a rotted PR reference  |
| 2     | [`2-durable-self-applied.md`](2-durable-self-applied.md) | The skill applied by the author to their own draft, leading with the why but still padded |
| 3     | [`3-adversarial-cut.md`](3-adversarial-cut.md)           | A fresh pass cutting to the one thing a reviewer cannot derive from the diff              |
| 4     | [`4-template-fitted.md`](4-template-fitted.md)           | Draft 3 reflowed into the repo's PR template                                              |

## Draft 1 catches a note that already rotted

Draft 1 is the default agent draft, and it opens with the failure this skill exists to prevent: two paragraphs that restate each skill's AGENTS.md index entry almost verbatim, so a reviewer with the diff learns nothing from them. It also narrates how the skills were built ("spot-verified against source before anything was written down"), which is session-provenance, not something true about the merged skills.

The sharpest line is the last one: "AGENTS.md has a pre-existing formatting warning on an untouched line that #28's formatting pass already covers." That is the present-moment test made concrete. #28 was in flight when the draft was written and has since merged, so the note is now false, and a reader who follows it goes looking for a warning that no longer exists. The session-salience tell flags it before it can rot: the fact is in the draft only because #28 was salient that day, not because it is true about this change.

## Draft 1 → 2: name the why, drop the rot

Draft 2 leads with the one durable decision, that the skills are filed at `org/` even though every example comes from Flipbook, and drops both the stale #28 note and the tool footer. That is most of the win. But it was edited by the author of draft 1, and self-editing defends its own sentences: it keeps two bullets that re-narrate the index entries, a "frozen illustrations" line that restates each skill's own provenance section, and a "Checks" section that echoes what CI already runs.

## Draft 2 → 3: the adversarial pass

The deep cut came from a pass that treated the draft as someone else's and applied the tests literally. On a docs PR, that pass is brutal, because the artifact being changed is itself prose a reviewer will read:

- **Derivable, cut.** The two per-skill bullets restate the AGENTS.md index entries, which are in the diff.
- **Derivable, cut.** "Frozen illustrations edited down from real components" restates the Provenance section each SKILL.md already carries.
- **Derivable, cut.** Which files landed (AGENTS.md, the `.changes/` entry) is visible in the diff.
- **CI-echo, cut.** The "Checks" section restates the pipeline.
- **Kept.** The scope decision, `org/` rather than `flipbook/` on Flipbook-only evidence, which is the one judgment a reviewer would challenge and cannot read off the diff.

What survives is two sentences. That is the lesson this example adds to the workflow one: when the change is documentation, the diff already says almost everything, and a short true body beats a long body that recites it back. The instinct to fill a large PR body is what smuggles the derivable prose back in.

## Draft 3 → 4: fit the template

Draft 4 reflows draft 3 into the repo's `Problem` / `Solution` / `Testing` / `Notes for reviewers`. The scope why splits naturally: the gap it closes becomes `Problem`, the decision becomes `Solution`, and the reviewer's call to weigh becomes `Notes for reviewers`. `Testing` gets the honest "nothing beyond CI" line naming the one relevant check, not a checklist restating the pipeline. As in the workflow example, the template should have framed draft 1 rather than arriving at the end.
