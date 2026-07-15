---
name: run-checks
description: "Run validation checks in Flipbook, Storyteller, or ModuleLoader. Use when: running tests, lint, analyze, CI checks, quality checks, or verifying changes in the Flipbook repo family."
type: process
---

# Run Checks

Always use `lute run` tasks before lower-level commands. Runs Selene, StyLua, luau-lsp, Jest, and Rocale.

## When not to use

For dependency verification (testing local storyteller or module-loader changes), see `test-dependencies`. For evidence standards and test anatomy, see `validation-and-qa`. For build channel/target details, see `build-and-toolchain`. For test filtering and output parsing, see `diagnostics-and-tooling`.

## Quick Reference

```bash
lute run lint
lute run analyze
lute run test
```

All commands run from the repo root. No setup required beyond `lute run install` (see `setup-dev-env`).

## Lint

```bash
lute run lint
```

Runs checks in order:

- **Selene:** Luau static analysis (defined in project config).
- **StyLua `--check`:** Code formatting validation on all project folders.
- **Luau vs. Luau extension check:** Finds `.lua` files (error; should be `.luau`).

Passes when all checks succeed and no `.lua` files are found.

## Analyze

```bash
lute run analyze
```

Runs `luau-lsp` with two passes:

1. **Scripts path (standard platform):** Runs with `--platform=standard` and `--flag:LuauSolverV2=true` on the scripts directory.
2. **Source tree (with sourcemap):** Analyzes source and workspace with sourcemap guidance generated from Rojo project file.

If local setup is missing (sourcemap not generated), run `lute run install` first.

## Tests

```bash
lute run test
lute run test --filter "PartialFileName"
lute run test --apiKey "YOUR_KEY"
```

Builds plugin with `--channel dev --clean`, generates Rocale test place, and runs Jest via Rocale.

**Requires:** `ROBLOX_API_KEY` environment variable (from `.env`) or `--apiKey` flag. Place and universe IDs are read from `.env.template` (grep for `ROBLOX_UNIT_TESTING_`). If key is unavailable, tests cannot run; use `lute run lint` and `lute run analyze` instead.

**`--filter`** accepts a filename pattern to run only matching test files (e.g., `"Story"` to run `Story.test.luau`). Useful for focused test runs when changed area has a clear test pattern.

---

## Provenance and Maintenance

**Date stamped:** 2026-07-11. Migrated from Flipbook's `.agents/skills/run-flipbook-checks/`.

**Re-verify these claims when this skill next loads** (run from Flipbook checkout):

- Lint checks order and tools: `head -40 .lute/lint.luau`
- Analyze command details: `grep "platform=standard\|LuauSolverV2" .lute/analyze.luau`
- Test requirements and options: `grep -E "apiKey|filter" .lute/test.luau`
- ROBLOX_API_KEY requirement: `grep "ROBLOX_API_KEY" .lute/test.luau`
- Test place IDs: `grep "ROBLOX_UNIT_TESTING" .env.template`
