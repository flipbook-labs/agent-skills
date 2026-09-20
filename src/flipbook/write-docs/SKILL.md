---
name: write-docs
description: "Write or edit Flipbook's documentation (the Obsidian vault and the Docusaurus site) so it matches the house voice and the site's mechanics. Use when: writing, drafting, updating, or revising docs, a docs page, a guide, the docs site, or anything under `docs/`. For voice and banned patterns, follow org/writing-style."
type: process
---

# Write Docs

Flipbook's documentation is authored in the **Obsidian vault at `docs/obsidian-vault/`** as Obsidian-flavored Markdown (`.md`) so the team can edit and cross-link pages quickly in Obsidian. A build step processes the vault into the **Docusaurus site at `docs/site/`**, which is published to GitHub Pages. Author your pages in the vault: use the Obsidian conventions below, and keep pages valid Markdown that Docusaurus can render. Read this skill fully before writing or editing a page.

The hard rule: **never describe behavior you have not confirmed in the source.** Generic, plausible-sounding docs that don't match the code are worse than no docs.

**Pages have different editorial bars.** `usage/`, `api/`, `concepts/`, and `contributing/` are high-rigor reference pages; apply the full house style and accuracy bar to them. `engineering/` (including `engineering/proposals/`), `product/`, and `product/ideas/` are public living documents, tech specs, and RFCs: freeform, lower bar, often half-finished thoughts. They publish intentionally so contributors and community members can learn from Flipbook's development. Keep the voice there, but don't polish or "correct" someone's working notes. Match the surrounding informality and only change what you were asked to. Treat the `exclude` list in `docs/site/docusaurus.config.ts` as the publication boundary. Do not exclude a whole section because it contains internal context; omit content only for a concrete privacy or security reason, and ask when the boundary is unclear.

> [!note]
> Author in Obsidian syntax. The build's remark plugin (`docs/site/src/remark/obsidian.mjs`) resolves wikilinks, image embeds, and `> [!callouts]`, so don't convert them to Docusaurus `:::` syntax to silence a warning; flag a genuinely unrenderable case instead. Note transclusion (embedding one note's body into another with `![[note]]`) is **not** supported: the plugin only embeds images, and a `![[note]]` falls back to a plain link. Don't author Obsidian Bases (`.base`): they don't render on the site (see Conventions).

## Voice and banned patterns

Follow **`org/writing-style`** for the house voice, the banned patterns (antithesis framing, hype and filler words, rule-of-three padding, meta-openers, semicolon overuse), the hard no-em-dash rule, and the self-critic pass. This skill layers the Flipbook and Obsidian docs-site mechanics on top of that.

## Workflow

1. **Read before you write.** Open the relevant source under `src/` (and existing tests) for anything you intend to document. Open the existing docs page if you are editing one. Do not write from general knowledge of how storybook tools "usually" work.

2. **Ground every claim.** Every behavior, property, default, and signature you state must be traceable to a specific line of source or an existing test. If you can't point to it, don't write it. When unsure, say so to the user instead of inventing.

3. **Cite while drafting.** As you draft, tag non-obvious claims with a source marker, e.g. `<!-- src: src/Storybook/init.luau:42 -->`. These make review trivial. Strip them before the page is final, but keep them in any draft you hand back for review.

4. **Match the house voice** in `org/writing-style` and the conventions below.

5. **Run the self-critic pass** from `org/writing-style` before declaring a page done, with the docs-specific addition of checking that every claim is backed by a cited source.

6. **Use the `obsidian` CLI for vault operations:** reading files, checking backlinks before deleting, moving notes, verifying unresolved links. The CLI connects to the currently active Obsidian window. Two vaults share the name `obsidian-vault` (the personal vault and this one), so first confirm the CLI is pointed at the right one:

   ```sh
   open "obsidian://open?vault=obsidian-vault&path=README.md"
   obsidian vault info=path   # must print .../flipbook/docs/obsidian-vault
   ```

   Key commands (all paths are vault-relative):
   - `obsidian read path=<path>` reads a note
   - `obsidian append path=<path> content=<text>` appends to a note (use `\n` for newlines)
   - `obsidian create path=<path> content=<text>` creates a note
   - `obsidian delete path=<path>` moves to trash (recoverable)
   - `obsidian move path=<path> to=<dest-folder>` moves or renames
   - `obsidian unresolved` lists broken wikilinks vault-wide
   - `obsidian backlinks path=<path>` checks before deleting a note
   - `obsidian orphans` lists notes with no incoming links

7. **Verify it builds** after structural changes: `cd docs/site && npm run build` (or have the user run it). Watch for broken wikilink and embed targets and unresolved references. If an Obsidian-ism surfaces as a build warning, flag it rather than rewriting it into Docusaurus syntax unprompted. Docs are also Prettier-formatted (`proseWrap: preserve`, so your line breaks are kept, which matters because joining a callout's lines would fold its body into the title). Run `npm run format` in `docs/site`, or let format-on-save handle it. CI runs `prettier --check`.

## Conventions

- Capitalize Flipbook product nouns: Story, Storybook, Controls, Storyteller. Lowercase generic uses.
- **Title Case for headings** ("Writing Stories", "Using Frameworks"). The page `# H1` is the feature or page name.
- Reference data goes in **static Markdown tables**: `| **Property** | **Type** | **Description** |`. Use `string?` / `{ Instance }` style Luau types in the Type column. **Never use Obsidian Bases (`.base`)**: they're excluded from the build and render as nothing on the site, so hand-write the table instead.
- **Callouts use Obsidian syntax, not Docusaurus `:::` admonitions:** `> [!note]`, `> [!tip]`, `> [!warning]`, `> [!seealso]`. Use `> [!warning]` for deprecations and breaking-change notices, and `> [!seealso]` (with wikilinks) for cross-reference blocks. **Put `> [!seealso]` blocks at the bottom of the page**, after the last content section.
- **Internal links are Obsidian wikilinks, not absolute paths:** `[[usage/frameworks/react|React]]`, a vault-relative path with an optional `|Label`. Link to a heading with `#`: `[[api/storybook-format#Legacy Support]]`. Verify the target page and heading exist.
- **Map of Content and `> [!seealso]` entries use a colon, not an em dash:** `[[link|Label]]: blurb`.
- **Reuse content by linking to a single source of truth, not by transcluding it.** Note transclusion (`![[note]]` / `![[note#section]]`) is no longer supported, so keep each fact on one canonical page and link to it (e.g. `concepts/story` links to `api/story-format` for the full module API). If a page genuinely needs another's content inline, write a short purpose-built summary there and link out for the detail. Don't copy-paste the whole section.
- **Sidebar order comes from `index.md` link lists, not frontmatter.** The sidebar generator (`docs/site/src/sidebar/obsidian.mjs`) labels each item from its `# H1` and orders each folder by the wikilink order in that folder's `index.md` (the root order comes from `README.md`). To place or reorder a page, edit the relevant index note's link list, and **don't add `sidebar_position`**.
- **Every folder owns an `index.md`** that is its Map of Content: a one-line intro plus a bulleted list of `[[wikilinks]]` to the folder's pages, each followed by a colon and a short blurb (see `usage/index.md`, `concepts/index.md`). New page in a folder gets added to that index.
- **Frontmatter is Obsidian-managed YAML.** Pages carry `aliases` and `linter-yaml-title-alias`, which the Obsidian Linter keeps in sync with the `# H1`, so don't hand-edit `linter-yaml-title-alias` (and commit the linter config so this stays shared). **Strip `notion-id`** when you touch a page. It's dead Notion-migration residue. Don't add a `base:` key (that's Obsidian Bases membership). Preserve other existing keys you didn't add (`tags`, `id`).
- Images embed Obsidian-style with an optional size: `![[assets/flipbook-icon.png|32]]`. When you use standard `![alt](path)` syntax instead, write real, descriptive alt text.

## Code samples

- Store substantive examples under `workspace/code-samples/src/` so Luau analysis and the docs site read the same source.
- Embed a sample with a `code-sample` fenced block whose body is its repo-root-relative path. Append `#L4-L13` for an inclusive range or `#L7` for one line. The shared extractor in `docs/code-samples/extract.mjs` powers both the Docusaurus remark plugin and the Obsidian reading-view plugin.
- **Examples must be real, not invented.** Use working modules from `workspace/code-samples/src/` or actual source, and keep them in sync. Don't hand-write a snippet you haven't confirmed compiles. This is the same accuracy bar as prose: an example that doesn't run is a wrong claim.
- Use ` ```diff ` fences to show migration or before/after steps (see the migration guides).
- Read `docs/code-samples/README.md` before changing the extractor, either adapter, or the fenced-block contract. Run `node --test docs/code-samples/extract.test.mjs` after those changes.

## Pull Request Descriptions

A PR body exists to orient the human who has to review an ever-growing diff. Its job is to inform and orient (explain what the change does and why it exists), not to catalog every line. The file-change view already owns the granular detail; the body should let a reviewer feel informed before they open a single file.

**Follow the repo template.** `.github/pull_request_template.md` defines the sections: Problem (why the change is needed), Solution (what it does and any non-obvious decisions), Testing (how it was verified), and Notes for reviewers (tradeoffs, risks, follow-ups). Fill each in; don't invent a custom structure.

**Lead with prose, keep code sparse.** Name things in sentences rather than wrapping every identifier in backticks. A body where half the nouns are inline code is unscannable, and the reader's eye snags on each one. Reserve inline code for things that genuinely read as code: a file path, an alias, a command, a version string. If a paragraph carries more backticks than commas, rewrite it as prose plus a table.

**Push granular detail into tables and lists.** A "what changed" table grouped by area (not one row per file) and a verification table mapping each check to its result carry dense facts far better than a paragraph studded with identifiers. Group and summarize; the reviewer drops into the diff when they want the per-file specifics.

**Keep the altitude high.** Explain intent and the decisions a reviewer couldn't infer from the diff; let the mechanical parts speak for themselves. A reader should finish the body knowing why the PR exists, what it changes at a high level, and what to watch for, then reach for the files for anything finer.

## Key Files and Paths

| File                                   | Purpose                                                         |
| -------------------------------------- | --------------------------------------------------------------- |
| `docs/obsidian-vault/`                 | Authoring source and Docusaurus content root                    |
| `docs/site/docusaurus.config.ts`       | Docusaurus config, publication exclusions, plugins, and nav     |
| `docs/site/sidebars.ts`                | Autogenerated sidebar entrypoint                                |
| `docs/site/src/sidebar/obsidian.mjs`   | Obsidian-aware labels and index-note ordering                   |
| `docs/site/src/remark/obsidian.mjs`    | Wikilink, image embed, and callout translation                  |
| `docs/site/src/remark/code-sample.mjs` | Docusaurus adapter for `code-sample` fenced blocks              |
| `docs/site/package.json`               | Docusaurus dependencies and docs checks                         |
| `docs/code-samples/`                   | Shared code-sample extractor, tests, and Obsidian adapter       |
| `workspace/code-samples/src/`          | Type-checked Luau examples embedded in docs                     |
| `.github/workflows/docs.yml`           | CI workflow: build on PR, deploy on release                     |
| `.lute/serve-docs.luau`                | Task runner for the local Docusaurus server                     |
| `.github/pull_request_template.md`     | PR template with Problem, Solution, Testing, and reviewer notes |

## Common Patterns

### Linking Between Pages

Use wikilinks in vault pages:

```markdown
See [[usage/writing-stories|Writing Stories]] for the full guide.
```

### Embedding Code Samples

Reference real Luau through the shared `code-sample` syntax:

````
```code-sample
workspace/code-samples/src/React/ReactButton.luau#L4-L13
```
````

### Callout Boxes

Callout syntax for both Obsidian and Docusaurus:

```markdown
> [!note]
> Information or note

> [!tip]
> Helpful information

> [!warning]
> Something to be careful about

> [!seealso]
> Related links (use for cross-reference blocks at page bottom)
```

### Sidebars and Navigation

The sidebar is autogenerated from the vault. Each folder's `index.md` controls its item order, and the root order comes from `docs/obsidian-vault/README.md`. Add a page by:

1. Create `.md` file under appropriate section in `docs/obsidian-vault/`.
2. Add it to that folder's `index.md` wikilink list with a short blurb.
3. Move the wikilink in the list to set its sidebar order. Do not add Docusaurus sidebar metadata to the note.

## When not to use

Use `org/user-facing-docs` for a package README or getting-started guide outside Flipbook. Use `flipbook/change-control` for PR and merge gates that do not concern docs authoring.

---

## Provenance and Maintenance

**Last verified:** 2026-09-20 against Flipbook's `flipbook-docs` branch at `1afbee13`. Consolidated with Flipbook's former local docs-writing skills. Voice and banned-pattern guidance lives in `org/writing-style`.

**Re-verify these claims when this skill next loads** (run from a `flipbook` checkout):

- Run `lute run <skills>/write-docs/scripts/check-docs-layout.luau`, where `<skills>` is this installed skill directory.
- Confirm the `exclude` list in `docs/site/docusaurus.config.ts` still matches the intended public boundary.
- Run `cd docs/site && npm run format:check && npm run typecheck && npm run build` after changing site mechanics or vault structure.
- Run `node --test docs/code-samples/extract.test.mjs` after changing code-sample extraction or either adapter.
