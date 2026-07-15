---
name: write-docs
description: "Write or edit Flipbook's documentation (the Obsidian vault and the Docusaurus site) so it matches the house voice and the site's mechanics. Use when: writing, drafting, updating, or revising docs, a docs page, a guide, the docs site, or anything under `docs/`. For voice and banned patterns, follow org/writing-style."
type: process
---

# Write Docs

Flipbook's documentation is authored in the **Obsidian vault at `docs/obsidian-vault/`** as Obsidian-flavored Markdown (`.md`) so the team can edit and cross-link pages quickly in Obsidian. A build step processes the vault into the **Docusaurus site at `docs/site/`**, which is published to GitHub Pages. Author your pages in the vault: use the Obsidian conventions below, and keep pages valid Markdown that Docusaurus can render. Read this skill fully before writing or editing a page.

The hard rule: **never describe behavior you have not confirmed in the source.** Generic, plausible-sounding docs that don't match the code are worse than no docs.

**Not every page is public docs.** `usage/`, `api/`, `concepts/`, and `contributing/` are the high-rigor reference pages; apply the full house style and accuracy bar to them. `engineering/` (including `engineering/proposals/`), `product/`, and `product/ideas/` are living documents, tech specs, and RFCs: freeform, lower bar, often half-finished thoughts. Keep the voice there, but don't polish or "correct" someone's working notes. Match the surrounding informality and only change what you were asked to. (Everything publishes except a short sensitivity list excluded in `docs/site/docusaurus.config.ts`.)

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

- Vault pages are `.md`, so examples are **inline fenced code blocks** (` ```lua `), not raw-loader imports.
- **Examples must be real, not invented.** Lift them from working modules (`workspace/code-samples/src/...` or actual `src/`) and keep them in sync with the source. Don't hand-write a snippet you haven't confirmed compiles. This is the same accuracy bar as prose: an example that doesn't run is a wrong claim.
- Use ` ```diff ` fences to show migration or before/after steps (see the migration guides).
- The raw-loader `<CodeBlock>` import pattern (importing from `workspace/code-samples/` and rendering with `<CodeBlock>` / `<Tabs>`) **only works in `.mdx` pages.** The Obsidian vault pages are `.md` and can't use JS imports, so don't reach for it here. If a page is genuinely `.mdx`, that pattern is available.

## Pull Request Descriptions

A PR body exists to orient the human who has to review an ever-growing diff. Its job is to inform and orient — explain what the change does and why it exists — not to catalog every line. The file-change view already owns the granular detail; the body should let a reviewer feel informed before they open a single file.

**Follow the repo template.** `.github/pull_request_template.md` defines the sections: Problem (why the change is needed), Solution (what it does and any non-obvious decisions), Testing (how it was verified), and Notes for reviewers (tradeoffs, risks, follow-ups). Fill each in; don't invent a custom structure.

**Lead with prose, keep code sparse.** Name things in sentences rather than wrapping every identifier in backticks — a body where half the nouns are inline code is unscannable, and the reader's eye snags on each one. Reserve inline code for things that genuinely read as code: a file path, an alias, a command, a version string. If a paragraph carries more backticks than commas, rewrite it as prose plus a table.

**Push granular detail into tables and lists.** A "what changed" table grouped by area (not one row per file) and a verification table mapping each check to its result carry dense facts far better than a paragraph studded with identifiers. Group and summarize; the reviewer drops into the diff when they want the per-file specifics.

**Keep the altitude high.** Explain intent and the decisions a reviewer couldn't infer from the diff; let the mechanical parts speak for themselves. A reader should finish the body knowing why the PR exists, what it changes at a high level, and what to watch for — then reach for the files for anything finer.

## Key Files and Paths

| File                               | Purpose                                            |
| ---------------------------------- | -------------------------------------------------- |
| `docs/docusaurus.config.ts`        | Docusaurus config (site title, URLs, plugins, nav) |
| `docs/sidebars.ts`                 | Sidebar structure and section organization         |
| `docs/package.json`                | Node dependencies for Docusaurus                   |
| `docs/docs/`                       | Markdown/MDX content root                          |
| `.github/workflows/docs.yml`       | CI workflow: build on PR, deploy on release        |
| `.lute/serve-docs.luau`            | Task runner for local dev server                   |
| `docs/obsidian-vault/`             | Institutional knowledge vault                      |
| `workspace/code-samples/`          | Real example code embedded in docs                 |
| `.github/pull_request_template.md` | PR template (docs sections in Problem/Solution)    |

## Common Patterns

### Linking Between Pages

**In Obsidian vault:** Use wikilinks:

```markdown
See [[creating-stories/writing-stories]] for the full guide.
```

**In Docusaurus site:** Use root-relative paths with `/docs/` prefix:

```markdown
See [Writing Stories](/docs/creating-stories/writing-stories) for the full guide.
```

### Embedding Code Samples

**When the sample is short (< 10 lines):** Inline the code in a fenced block.

**When the sample is long or lives in the repo:** Reference via code-sample syntax (Obsidian) or raw-loader (Docusaurus) so it auto-updates if source changes.

**Obsidian code-sample syntax:**

````
```code-sample
workspace/code-samples/src/React/ReactButton.luau#L4-L13
````

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
````

### Sidebars and Navigation

Sidebar structure is in `docs/sidebars.ts` for Docusaurus. Obsidian sidebar comes from `index.md` link lists in each folder. Add new pages by:

1. Create `.md` file under appropriate section in `docs/obsidian-vault/`.
2. Add to that folder's `index.md` link list (or update `docs/sidebars.ts` for Docusaurus).
3. Set `sidebar_position` in frontmatter to control sort order (Docusaurus only).

---

## Provenance and Maintenance

**Date stamped:** 2026-07-11. Consolidated with Flipbook's `flipbook-docs-and-writing` skill from `.agents/skills/flipbook-docs-and-writing/`. Voice and banned-patterns sections are lifted into `org/writing-style`.

**Re-verify these claims when this skill next loads** (run from a `flipbook` checkout):

- The remark plugin and sidebar generator still exist: `git show origin/main:docs/site/src/remark/obsidian.mjs | head` and `git show origin/main:docs/site/src/sidebar/obsidian.mjs | head`
- The vault root is still `docs/obsidian-vault/`: `git ls-tree origin/main -- docs/obsidian-vault`
- Docusaurus is still the build system: `grep "docusaurus\|@docusaurus" docs/package.json`
- PR template exists: `head -5 .github/pull_request_template.md`
