---
name: test-dependencies
description: "Verify local Storyteller or ModuleLoader changes inside Flipbook by overlaying built binaries. Use when: you changed storyteller or module-loader and need to test the changes in Flipbook, or when the engineer explicitly asks to verify a dependency change through Flipbook."
type: process
---

# Test Dependencies

When a task changes `storyteller` or `module-loader`, verify the changes inside Flipbook by building the dependency and overlaying its `dist/` output into Flipbook's Wally-installed package directory. This circumvents Wally's registry-only resolution — it has no support for local path or git dependencies.

## When not to use

For tracking known upstream issues in these dependencies, see `failure-archaeology` (e.g., storyteller#100 on readonly-table mutation). For build system details and channel/target flags, see `build-and-toolchain`.

## Changed Storyteller

From the `storyteller` repo:

```bash
lute run try-in-flipbook
```

This invokes `.lute/try-in-flipbook.luau`, which:
1. Builds Storyteller's `dist/` output.
2. Locates Flipbook in the sibling `../flipbook` directory.
3. Overlays the build into `flipbook/Packages/_Index/flipbook-labs_storyteller@*/dist/`.

Then from the `flipbook` repo, rebuild the plugin:

```bash
lute run build plugin --channel dev --clean
```

## Changed ModuleLoader

Overlay ModuleLoader directly into Flipbook:

```bash
# from module-loader repo
lute run try-in-flipbook
```

If the task also requires testing ModuleLoader's integration with Storyteller (e.g., Storyteller vendors a copy), run the chain:

```bash
# from module-loader repo
lute run try-in-storyteller

# from storyteller repo
lute run try-in-flipbook
```

Then rebuild Flipbook:

```bash
# from flipbook repo
lute run build plugin --channel dev --clean
```

## Requirements

- Three sibling checkouts under the same parent: `flipbook/`, `storyteller/`, `module-loader/`.
- Each repo must have run `lute run install` so `Packages/_Index` exists with Wally-installed packages.
- The `try-in-*` scripts (in `storyteller/.lute/` and `module-loader/.lute/`) use `FlipbookBatteries` to locate sibling repos and overlay built binaries.

---

## Provenance and Maintenance

**Date stamped:** 2026-07-11. Migrated from Flipbook's `.agents/skills/test-dependencies-in-flipbook/`.

**Re-verify these claims when this skill next loads** (run from Flipbook checkout; sibling repos at `../storyteller/` and `../module-loader/`):
- `try-in-flipbook` scripts exist: `ls ../storyteller/.lute/try-in-flipbook.luau ../module-loader/.lute/try-in-flipbook.luau`
- `try-in-storyteller` script exists: `ls ../module-loader/.lute/try-in-storyteller.luau`
- Package directories exist: `ls Packages/_Index/ | grep -E "flipbook-labs_(storyteller|module-loader)"`
- Build command targets: `grep "roblox" .lute/build.luau`
