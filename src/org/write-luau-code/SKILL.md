---
name: write-luau-code
description: "Luau code style and idioms for flipbook-labs: type discipline, table formatting, naming, stdlib-first idioms, enums, error shape, module organization, and when not to abstract. Use when: writing or editing any Luau source in a flipbook-labs repo (library, plugin, CLI, or a .lute/ script), or reviewing a diff for style. This is the vendor-neutral house style; a repo's own skill owns its framework idioms and exemplars."
type: process
---

# Write Luau Code

The house style for Luau you write or edit anywhere in the org. These are the corrections Marin makes most often in review, collected so you make the change before being asked. Match the surrounding file when it already establishes a local convention. This skill owns *how the code reads*, not what it does or whether it is tested (see the cross-links at the end).

## Types

- **Prefer `unknown` over `any`.** Reach for `unknown` by default at boundaries (untrusted input, cross-module generics). `any` disables the checker and needs an explicit reason. Marin: *"Use `unknown` before `any`. Explicit approval is needed for using `any`."*
- **Type the public contract.** Give function signatures and exported data structures explicit types rather than leaning on inference. A missing type is a review comment waiting to happen.
- **Name a reusable type instead of repeating an inline union.** `export type BumpKind = "major" | "minor" | "patch"` once, then annotate with it (`local kind: BumpKind = ...`), rather than writing the union at each site.
- **Keep generics sound for every instantiation.** Do not assume a generic `T` has a property just because it is not some other type. Marin: *"we can't assume that any generic value `T` will be a StoryControlValue only because it's not a StoryControl."*
- **Luau function types carry no argument names.** Write `setActive: (boolean) -> ()`, not `setActive: (active: boolean) -> ()`.

## Table formatting

**Expand tables by default, one field per line.** Only a trivial one- or two-field table belongs on a single line. Wide inline tables hurt readability and produce noisy diffs. This one recurs constantly in review, so do it up front: multi-key tables and multi-key `return` statements each get a line per entry.

## Naming

- **Functions read as verb phrases; variables as nouns.** A function that reads or computes state is named with a verb prefix: `getRepoSlug`, `fetchManifest`, `resolvePath`, `hasUnreleasedChanges`. Do not name a function the way you would name the value it returns (`manifest` for a getter).
- **Booleans take an `is`/`has` prefix:** `isActive`, `hasChanges`, not `active` or `changed`.
- **Pick one term for a concept and apply it everywhere.** When you rename, sweep the whole change so the vocabulary stays consistent across modules. Consistency beats a marginally better name used in only one place.
- **Do not pluralize gratuitously**, and prefer a descriptive name over a generic one (`entry`, `data`, `value`) wherever the specific meaning is not obvious from context.

## Idioms: reach for the standard library first

- **Use stdlib utilities instead of hand-rolling.** `string.split`, `path.join`, `fs.readFileToString`, `fs.writeStringToFile` exist so you do not open/read/close by hand or reinvent a path join. In a `.lute/` script, parse arguments with the CLI battery, not by pulling apart `...`.
- **Trust the language and stdlib to throw.** Drop redundant `assert()` around a call that already errors on failure (file reads, a parser with a required argument), and drop casts the language already implies. Marin: *"Error is implicit for file reading, remove the asserts."*
- **Colon notation for methods:** `content:gsub(pattern, next)`, `message:find("409 ", 1, true)`, not the `string.` free-function form.
- **Backtick strings call `tostring` for you:** write `` `got {value}` ``, not `` `got {tostring(value)}` ``.
- **Index directly rather than binding an eager intermediate** you use once (`request.method`), but *do* introduce a local to capture a multiple-return value rather than wrapping the call in parentheses to discard the rest.
- **Alias a hot import once at the top of the file** (`local run = FlipbookBatteries.run`) and use the alias throughout instead of re-indexing it at every call site.
- **Order requires: packages first, then local modules.** Keep third-party imports (`@std`, `@pkg`, batteries) grouped as the vendor block, local modules after. Put all requires at the top; a mid-file require is only for a deliberate dynamic-loading case.

## Enums

Model a closed set of values as a frozen table of named constants, not a bare string-union type:

```luau
local Surface = table.freeze({
	Agent = "agent",
	Plugin = "plugin",
})
```

Callers then reference `Surface.Agent`, which is greppable and typo-proof, instead of repeating the raw string. Follow the pattern already used elsewhere in the org rather than inventing a new enum shape.

## Errors

Name an error field `err` or `problem`, not `error` (which shadows the global and reads as generic). Keep error handling light: let a clear base error surface rather than wrapping it in bespoke handling. Marin: *"The base error is pretty clear, and if anyone ever hits this they'll either find the escape hatch themselves or ask about it."*

## Module organization

- **One responsibility per module.** Do not bundle several unrelated exports behind one function. When a set of small helpers each earns its keep, give each its own file in a folder and import as needed; when a helper is a couple of trivial lines used once, inline it instead of giving it a module.
- **Hoist shared types to a `types.luau`** rather than re-declaring them across the files that use them.
- **Extract an inline helper into its own module** once it is reused or non-trivial, instead of leaving it defined in the middle of an unrelated file.

## Do not abstract ahead of need

- **Build the direct thing until it actually fails.** Do not add a cross-platform wrapper, a config knob, or an indirection for a problem you have only imagined. Marin: *"Did spawning a `cp` process actually fail or were you overeager to create this? We'll use `cp` until we actually hit an issue."*
- **Do not add validation the system already guarantees elsewhere.** A downgrade guard is redundant when the PR review is the real gate; a required CLI argument does not need a runtime nil-check on top of the parser.
- **Reuse the org's battle-tested logic** before writing your own for a solved problem (path resolution, type narrowing). Check Flipbook and sibling repos first.

## When not to use

This skill is code style only. For whether a test is any good, see [`org/write-luau-tests`](../write-luau-tests/SKILL.md). For when a comment earns its place, see [`org/code-comments`](../code-comments/SKILL.md). For repo setup, `.luaurc` strictness, and the `@std`-over-`@lute` policy, see [`org/repo-conventions`](../repo-conventions/SKILL.md). For deciding a change is too large or exposes too much, see [`org/reviewable-changes`](../reviewable-changes/SKILL.md).

---

## Provenance and Maintenance

**Date stamped:** 2026-07-07. Distilled from Marin's inline review comments across storyteller, agent-gateway, changewrite, flipbook, and flipbook-cli, where the same Luau-style corrections recur (type discipline, expanded tables, verb-and-`is` naming, colon notation, stdlib-first, frozen-table enums, one-thing-per-module, no premature abstraction). Quotes are frozen illustrations, not live pointers into any repo's source.

**Re-verify these claims when this skill next loads:** nothing mechanical. This is `org/` doctrine with no single-repo anchors. The quotes above are frozen snapshots quoted for illustration. If the org's Luau conventions shift (a new formatter changes table style, a stdlib rename), update the relevant section and add a `.changes/` entry.
