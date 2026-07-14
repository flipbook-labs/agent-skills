# Worked example: slimming a PR body

Four drafts of the body for one real change — a GitHub Actions edit to Flipbook's
weekly "Upgrade Roblox Packages" job ([flipbook#611](https://github.com/flipbook-labs/flipbook/pull/611),
an illustration rather than a live anchor). The diff never changed between drafts;
only the prose did. Read them in order and watch what gets cut.

| Draft | File | What it shows |
| ----- | ---------------------------------------------------- | ----------------------------------------------------------------------------------- |
| 1     | [`1-default.md`](1-default.md)                       | The default: one sentence per diff hunk, transition narration, a CI-echoing test plan |
| 2     | [`2-durable-self-applied.md`](2-durable-self-applied.md) | This skill applied by the author to their own draft — better, but still padded      |
| 3     | [`3-adversarial-cut.md`](3-adversarial-cut.md)       | A fresh pass, not attached to the words, cutting to the non-derivable core           |
| 4     | [`4-template-fitted.md`](4-template-fitted.md)       | Draft 3 reflowed into the repo's PR template                                         |

## Draft 1 → 2: name the why

Draft 1 is the shape this skill exists to prevent. Every step of the diff has a
matching sentence, so the whole body is recoverable from the diff itself. It narrates
the transition — "the version bump is now…", "Replaces the `peter-evans` step… what
erased in-progress work before" — which is true only while the change is fresh. And it
closes with a test plan of checkboxes that echo what CI already runs.

Draft 2 leads with the why instead, which is most of the win. But it was edited by the
same agent that wrote draft 1, and self-editing is anchored: you defend your own
sentences. So it keeps a bullet that re-narrates the `sed` line, a second "Verifying"
section that re-encodes the branch logic a third time, and a cross-repo aside no
reviewer needs.

## Draft 2 → 3: the adversarial pass

The deep cut came from a pass that treated the draft as someone else's and applied the
tests literally:

- **Derivable → cut.** The `ROBLOX_PACKAGES_VERSION` bullet restated the `sed` line and
  its `git diff --quiet` guard; both are in the diff.
- **Derivable → cut.** "A PR is opened only when the branch is fresh" is just the `if:`
  condition on the open-PR step.
- **CI-echo → cut.** The entire "Verifying" section re-encoded the branch logic as test
  cases the pipeline covers.
- **Not load-bearing → cut.** "matching the other PR-based workflows (e.g. Storyteller)."
- **Kept.** The two non-derivable whys (app token, commit-on-top) and the secret
  dependency — the one thing a reviewer cannot see and might be missing.

The result is roughly a third of the length carrying more. The lesson is not "draft 3
is short"; it is that the hard cutting happened in a pass that was not attached to the
author's own words. Generate in one context, cut in another.

## Draft 3 → 4: fit the template

Draft 3 is tight but ignores the repo's PR template. Draft 4 reflows the same content
into Flipbook's `Problem` / `Solution` / `Testing` / `Notes for reviewers`. Nothing is
padded to fill a heading: the two whys land under `Solution`, the secret dependency is
a natural `Notes for reviewers`, and `Testing` gets one honest line ("No automated
coverage; exercised by dispatching the workflow") instead of a checklist. Same
discipline, fitted to the house structure so it reads next to human-written PRs.
