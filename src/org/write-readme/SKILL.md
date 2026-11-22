---
name: write-readme
description: "How to write or edit the README of a flipbook-labs repo: pick the App, Package, or Tool template, fill it in, and keep it current. Covers the shared shape (PascalCase title, right-floated icon, short intro, Install, Use, topic sections, Contributing, License), what each template leads with, keeping install versions current with Changewrite mirrors, moving dev setup into CONTRIBUTING.md, centering the product rather than its implementation, the is-this-useful-to-an-end-user filter, and shipping a runnable example. Use when: writing, rewriting, or editing any repo README, or adding a CONTRIBUTING.md beside one. For prose voice see org/writing-style; for Flipbook's docs site see flipbook/write-docs."
type: process
---

# Write a README

Every flipbook-labs README follows one of three templates, so a reader who knows one repo can find their way around the rest. A README is for someone deciding whether to use the project and then using it. Maintainer setup lives in CONTRIBUTING.md.

## Pick the template

Each template is written for a different reader, so it leads with what that reader needs first.

| Template                        | For                                                                   | Reader                                           | Leads with                                                                       | Install                                        |
| ------------------------------- | --------------------------------------------------------------------- | ------------------------------------------------ | -------------------------------------------------------------------------------- | ---------------------------------------------- |
| [App](templates/app.md)         | Things people install and use rather than import, like Studio plugins | A Roblox developer deciding whether to try it    | A screenshot or GIF of the app doing its main job. Use may add one short snippet | Creator Store, with release builds as fallback |
| [Package](templates/package.md) | Libraries other code depends on                                       | A developer deciding whether to add a dependency | The smallest working example, in Use                                             | Wally and Lute only                            |
| [Tool](templates/tool.md)       | CLIs and GitHub Actions                                               | A developer wiring it into a project or CI       | A real run, or the workflow that uses it                                         | Rokit and GitHub Action                        |

An internal repo, one built for flipbook-labs rather than outside users, uses the Package template with a status note such as "Built for flipbook-labs repos." When a repo could fit two templates, pick the one that matches how most readers will first touch it.

Copy the template's block into the README, fill it in, and delete its guidance comments.

## The shared shape

All three templates share this shape, top to bottom:

- **Title.** The PascalCase name prose uses (Storyteller, ModuleLoader, FlipbookBatteries), never the repo slug. Keep it plain text, and link the docs site from the intro instead.
- **Icon.** A square image floated right beside the intro with `align="right"` at 128 by 128. Use an SVG, or a PNG of at least 256px, on its own filled background so it reads in light and dark mode. Apps need one. Packages and tools are encouraged to have one, and a README can ship without it and add it later.
- **Intro.** One to three short paragraphs: what it does and what sets it apart, what it supports, and where the docs live. No badges, slogan, or Features list.
- **Hero image.** Apps only, right after the intro.
- **Install, then Use.** Then one topic section per question the project raises, named in a word or two (Renderers, Configure, Migrate).
- **Contributing.** One line linking the repo's CONTRIBUTING.md.
- **License.** "MIT." first, then each bundled third-party license in its own paragraph, linked to its license file.

Two rules hold the shape together:

- **Say each point once.** A point lives in the intro or in a section, never both. When the intro says what the project supports, no section repeats it, and when a section covers it, the intro leaves it out.
- **Let the docs site carry depth.** With a docs site, each section is a few lines that end with a link into it. Without one, a section holds the full content, as long as the reader needs it.

## Keep install versions current

Install snippets show the real version, never `latest` or a placeholder. Changewrite keeps them current: add a `[version].mirror` entry to `changewrite.toml` for each version string in the README, with a Lua `pattern` whose one capture is the version without its `v`:

```toml
[version]
mirror = [
  { file = "README.md", pattern = "flipbook%-labs/storyteller@([%d%.]+)" },
  { file = "README.md", pattern = "rev = \"v([%d%.]+)\"" },
]
```

A mirror replaces only the first match of its pattern, and the release fails if the pattern matches nothing. So when the same version string appears twice, such as an Action's `uses:` line in Install and again in Use's workflow, give each copy a pattern that only it matches, for example by including its indentation.

## Move dev setup into CONTRIBUTING.md

Building from source, running checks, and cutting releases are for contributors, so they go in CONTRIBUTING.md. When a repo has no CONTRIBUTING.md, create one in the same change that moves the setup out of the README.

## Center the product, not its implementation

Write from the perspective of the product being the thing the reader wants. What it is built on is an implementation detail they should not have to care about by default. Marin, on an action that shells out to another tool: _"The use of flipbook-cli should be an implementation detail. Write the readme from the perspective of deploy-storybook being the primary product."_ Mention the internals only lightly, for the power user who needs the escape hatch, never as the main narrative.

## Apply the end-user utility filter

Before a section earns a place in the README, ask: **is this useful to someone using the project?** Marin: _"Ask yourself: Is this useful to an end-user? This section is a definite No."_ Internal development notes, "this repository is in early setup," and process docs fail the filter. They belong in CONTRIBUTING.md, `AGENTS.md`, or a skill.

## Ship a concrete, runnable example

Use needs at least one real example, and the example must actually work.

- **Real, not placeholder.** Use a real build command and realistic names (_"Let's use a real rojo build example"_; a display name like `Flipbook Stories`, not `my-input-here`). Readers copy and paste, so a made-up or wrong example breaks their first run.
- **Real API.** Check every function, field, and flag against the source before it goes in the example.
- **String requires.** Require packages by string, as in `require("@pkg/Storyteller")`, never by an instance path like `ReplicatedStorage.Packages.Storyteller`.
- **Watch for characters that break in practice.** Marin hit trouble using `#` in a Roblox place name and cut it from the example. When a value has environment constraints, keep the example inside them and note the constraint.

## Nudge setup toward the right primitives

When the README walks a reader through credentials or configuration, point them at the durable primitive rather than the quick one: for secrets in an action, a GitHub Environment holding the key and variables, not repo-level secrets. The README is where a good default gets established.

## When not to use

For the prose voice (banned patterns, no em dashes, the self-critic pass), follow [`org/writing-style`](../writing-style/SKILL.md). Flipbook's docs site has its own mechanics in [`flipbook/write-docs`](../../flipbook/write-docs/SKILL.md). For a changelog entry rather than a README, see [`org/changelog-entries`](../changelog-entries/SKILL.md).

---

## Provenance and Maintenance

**Date stamped:** 2026-11-21. The doctrine sections were distilled on 2026-07-07 from Marin's review comments on READMEs across deploy-storybook and agent-gateway. The templates and shared shape were workshopped with Marin on 2026-11-21, modeled on obsidianmd/pele's structure with Type Kana's right-floated icon, and tested by drafting Flipbook, Storyteller, and Changewrite READMEs. Quotes are frozen illustrations, not live pointers into any repo.

**Re-verify these claims when this skill next loads:**

- Mirror behavior: in Changewrite, `replaceCapturedVersion` replaces the first match of the pattern and asserts when nothing matches (grep `replaceCapturedVersion` in `src/release/`), and `parseVersionTarget` reads `file` and `pattern`.
