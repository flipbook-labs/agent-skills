# Writing a PR description

[`SKILL.md`](SKILL.md) decides what a PR body captures: the durable why, with derivable and present-moment prose cut. This page covers how to write what's left so a maintainer can orient from it in a minute. For sentence-level craft, see [`org/writing-style`](../writing-style/SKILL.md).

A PR description has one job. It helps a maintainer decide whether the change is worth their time, and if it is, it gets them ready to read the diff. A good one reads like a colleague walking you through their work. It's short, it tells a story, and each sentence follows from the one before it.

## Who you're writing for

The reader maintains the project. They know the codebase well, but they don't know this change. They weren't there when you found the problem or picked the fix, so whatever you learned along the way stays invisible until you say it.

They're also busy. Pull requests are cheap to make, so a maintainer has more to review than time to review it. Your first few sentences should tell them why this one matters.

No pull request stands alone. Each one is a piece of something larger, and the reader wants to see where it fits.

## Whose voice it is

The description goes out under the name of the person who opened the pull request. The AI-authorship disclosure tells the reviewer an agent wrote the body, but every "I" still reads as that person. So when an agent writes "I ran the linter," the reader believes the person ran it.

Say what was done without claiming the person did it. Either make the check the subject, or name the agent as the one who acted. Keep the claim the size of the check, too. A result is what one run showed, not a settled fact about the code.

> **Before**
> I opened the story in Studio and confirmed the menu no longer clips.

> **After**
> An agent opened the story in Studio, and the menu no longer clipped at the bottom.

When the person did a check themselves, the "I" is theirs to write.

## Where the why comes from

The best source is the person who asked for the change. Before you write, reread what they said when they started the work. Their words usually hold the reason plainly, even when nothing else records it. "It's a conflict every time" is a whole Problem section waiting to be written. If other sessions picked the work up later, read what the person said in those as well.

Look for the choices they made, too. When they tried one approach and turned it down, that's the alternative Solution should mention. Then check the linked issue and the project's roadmap for the bigger picture.

Their words are for you, not the reader. Turn them into the description's own sentences, written for a maintainer. Don't quote the conversation or retell how the work came about.

## Shorter than you think

A description only has to answer three questions. Why does this matter? What's the idea? Where should I start? Once those are answered, stop.

That usually takes less than it seems. A small fix needs a sentence or two under each heading. A typical change fits in about 150 words, and even a large feature rarely needs more than 300. If yours runs longer, look for detail the diff already shows, or for a second idea that wants its own pull request.

> **A small one**
>
> ## Problem
>
> Some types-only modules end in `return {}` and others in `return nil`, so a new module has no clear pattern to follow. The `{}` versions also build an empty table on every require, which nothing reads.
>
> ## Solution
>
> To settle on one pattern, every types-only module now returns `nil`, as seven already did.
>
> 🤖 Generated with [Claude Code](https://claude.com/claude-code)

That's the whole description, down to the disclosure line that closes every generated body. The diff shows which files changed, and the reader needs nothing more to judge it.

## What each section does

Fill the template's sections, as [`SKILL.md`](SKILL.md) says. This is what each one is for.

**Problem** carries the most weight. It says what's wrong and why it matters, starting from what a person or caller runs into. To find that, ask what would go wrong for someone if this never merged. Sometimes the honest answer is small, like a tidier codebase or one fewer thing to remember. Say so plainly. A small reason stated clearly beats a large one stretched to fit. Then place the change in the work around it, in a sentence or two: what prompted it now, and what the bigger effort gains once it lands. One screenshot or error log can show the problem faster than a paragraph can.

**Solution** picks up where Problem left off. Its first sentence bridges back to the problem, then names the one idea the change is built around. The rest explains how the main pieces serve that idea, why this approach beat the obvious alternative, and where the reader should start in the diff. Before-and-after media for a visible change goes here.

**Testing** says what CI can't: a manual run, like a check in Studio, and what it showed, or a risk the specs don't reach. Tell the reader what hasn't been checked, so they know where to look harder. When CI covers everything worth saying, say so in a line.

**Notes for reviewers** holds what the reviewer has to act on: setup that has to happen before merge, a call you're unsure about, and the assumptions described below.

End with `Closes #n` on its own line for each issue the change finishes.

The top of the description belongs to the story. GitHub already shows which pull request a stacked one builds on, so a "Stacked on #n" line only repeats it. Leave that out, along with any block of related links. When a link tells the reader something the page doesn't, like a pull request that has to merge first but isn't the base, put it at the bottom above `Closes`, phrased so it stays true after merge ("Builds on #n"). A reference that explains the change can still sit inside a sentence.

## Say the one idea

Most pull requests exist for one reason. Find it and say it plainly, near the start of Solution. Everything after serves that idea.

The diff already lists every change. The description says which changes matter and how they connect. If a change doesn't serve the idea, it probably wants its own pull request.

> **Before**
>
> - **App token:** the job authenticates as the flipbook-backend GitHub App.
> - **Branch handling:** the job checks out the existing upgrade branch.
> - **Commit:** the bump is committed on top of that branch.

> **After**
> To keep an open upgrade PR moving, the weekly job now adds each bump as a new commit on the existing upgrade branch. Rebuilding the branch from `main` every week would throw away the work of adapting Flipbook to the new packages, which can take weeks.

## Get them ready for the diff

Before opening the diff, a reader wants three things. Where should they start? What's risky? Is there an idea they'll need that they might not have? A sentence or two on each is plenty.

> A good place to start is `.lute/lib/posthog/sendAsync.luau`. Every request to PostHog goes through it, and its dry-run branch is what keeps a pull request's CI run from sending real events.

## Tuck side findings away

Some findings matter to a few readers but would pull everyone else off the main story. A platform quirk or the research behind a choice are good examples. Put each one in a collapsed note at the end of the section it belongs to. Its summary says the finding in one full sentence, so a skimmer gets the point without opening it.

```markdown
> [!NOTE]
>
> <details>
> <summary>PostHog's capture endpoint answers 200 even for an invalid project token.</summary>
>
> So a report that only checked the capture response would look healthy with a revoked key…
>
> </details>
```

Anything the reader needs to act on stays in the open. Most descriptions need no side notes at all, and even a large one rarely needs more than two.

## Write down your assumptions

Every change rests on a few guesses. The person asked for something, and you filled in what they didn't say. Maybe you guessed which callers matter, what a setting should default to, or that a format won't change. A reviewer can only correct an assumption they can see.

List them under an "Assumptions" label in Notes for reviewers, so reviewers always know where to look. When the template has no such section, put them in a collapsed note titled "Assumptions" at the end of Solution. Each bullet says what you assumed and what would change if it's wrong. Leave out anything the code or the person already settled.

```markdown
**Assumptions**

- Studio keeps firing `Changed` for every source edit. If it batches them, a story reloads once per batch instead of once per save.
- A storybook rarely holds more than a few hundred stories. Far more would make the full rescan on startup the cost to watch.
```

The list grows with the pull request. When you pick up one that another session opened, read the current list first. Add what you assumed, and remove anything the person or a reviewer has since confirmed or corrected.

## A model description

This is flipbook-labs/flipbook#658, rewritten to show everything above working together. The facts come from the original. Notes on what it's doing follow.

> ## Problem
>
> A maintainer deciding whether to cut a release has no view of what's waiting on it, or of when the last builds went out. PostHog already holds Flipbook's product telemetry, so it's the natural home for that view.
>
> ## Solution
>
> To build that view, the release pipeline now reports its own events to PostHog through `lute run posthog <event>`. They use the `ci_` prefix and a fixed `github-actions` distinct ID, so they stay apart from product telemetry in the same project.
>
> Three events cover the pipeline. Every push to `main` sends the number of pending `.changes/` entries, which is all the release-health dashboard's backlog chart needs. A beta publish sends its version, build hash, and commit. A prod release adds the Storyteller and ModuleLoader versions and a matching project annotation. The build hash is the one `lute run build` bakes into the plugin, so CI events line up with product events from the same build.
>
> Reporting never gets in a release's way. Each event uses its commit SHA as its UUID and the commit time as its timestamp, so a rerun doesn't double-count. Report jobs use `continue-on-error`, so a PostHog or 1Password problem can't fail a release run.
>
> A good place to start is `.lute/posthog.luau`. PostHog's capture endpoint answers 200 even for an invalid project token, so each report first confirms the token against the flags endpoint. The weekly PostHog Check workflow runs the same check, so a revoked key surfaces before a release does.
>
> ## Testing
>
> Each event and the check were run with `--dry-run`, and the payloads were checked by hand. Against bogus credentials, each one failed with PostHog's response. Neither run sent data to the live project, so the first push to `main` is the first real report.
>
> ## Notes for reviewers
>
> Before merging, set up:
>
> 1. A 1Password item `flipbook-posthog-ci` in the Flipbook Edge vault with `project-token`, `personal-api-key`, and `project-id` fields.
> 2. A `posthog` environment holding `OP_SERVICE_ACCOUNT_TOKEN` for a service account that can read that item, limited to `main` and release tags.
>
> 🤖 Generated with [Claude Code](https://claude.com/claude-code)

**What to notice**

- The first sentence names who runs into the problem and what they can't see.
- Solution's first sentence picks up "that view" from the end of Problem. Read it without the heading and it still flows.
- Each Solution paragraph makes one move: what reports, what each event carries, why reporting is safe, where to start.
- The three events are sentences rather than bullets, because each one adds to the last.
- Testing ends on what hasn't run, so the reviewer knows where the risk is.
- Notes for reviewers holds only what someone has to do before merge, and it's the one place a numbered list fits.
- The disclosure line closes the body, below the last section.

## What we've learned

These came from rewriting real descriptions and seeing what helped.

- **Read it without the headings.** If it still flows as one piece, the structure is working.
- **The why usually lives in the linked issue.** Start there before writing Problem.
- **Every name is a small interruption.** Each file or function you mention asks the reader to go remember it. Name the few that help them find their way, and describe the rest in plain words.
- **Rewrites tend to grow.** When a description comes out longer than the one it replaced, it's usually repeating the diff.
- **A mechanical consequence isn't news.** If a change only follows from the main one, like a function losing an argument it no longer needs, the diff can say it.
- **Bullets are for things that are truly parallel,** like a set of flags or setup steps. A list of changes belongs to the diff.
- **A hard-to-find idea is a signal.** If you can't name the one idea, the pull request may be doing two things.
