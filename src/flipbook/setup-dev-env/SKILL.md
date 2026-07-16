---
name: setup-dev-env
description: "Set up or repair the Flipbook, Storyteller, or ModuleLoader development environment. Use when: first-time setup, installing dependencies, managing .env files, troubleshooting rokit/wally/lute, or repairing stale tooling in the Flipbook repo family."
type: process
---

# Setup Dev Environment

First-time setup or when package/tooling state looks stale. Rokit installs tools; Wally installs packages; Lute runs builds and tests.

## When not to use

For testing local dependency changes (storyteller or module-loader), see `test-dependencies`. For running lint/analyze/test tasks, see `run-checks`. For toolchain details, see `build-and-toolchain`.

## Repo Family Layout

`flipbook`, `storyteller`, and `module-loader` are expected to be sibling checkouts:

```bash
~/git/flipbook
~/git/storyteller
~/git/module-loader
```

The install script detects and works with any repo in this family.

## Standard Setup

Run these commands from the repo root:

```bash
rokit install
lute run install
```

For `flipbook` only, ensure a `.env` file exists:

```bash
cp .env.template .env
```

**Required:** `BASE_URL` in `.env` must be set to `https://apis.flipbooklabs.com` (the default in `.env.template`). The build task checks for this value (verified: `grep "if not process.env.BASE_URL" .lute/build.luau`).

## What `lute run install` Does

- Installs Wally runtime packages into `Packages/`.
- Installs Lute tooling packages and moves them to `LuauPackages/`.
- Generates Rojo sourcemaps.
- Applies package patches needed by Flipbook.

## Common Troubleshooting

**"Cannot resolve packages"** — `lute run` tasks failing with unresolved imports: run `lute run install` again.

**Stale build output after dependency changes** — Use `lute run build --clean` for a full rebuild from scratch.

**"ERROR No such file or directory (os error 2)"** — Rokit is trying to invoke a tool it has not installed. Run `rokit install` to recover.

**Do not edit `Packages/` or `LuauPackages/` directly** — these are generated. Regenerate with `lute run install` if needed.

---

## Provenance and Maintenance

**Date stamped:** 2026-07-11. Migrated from Flipbook's `.agents/skills/setup-flipbook-dev-env/`.

**Re-verify these claims when this skill next loads** (run from Flipbook checkout):

- `rokit.toml` presence and tool list: `grep "^\[" rokit.toml | head`
- `.env.template` contents: `grep BASE_URL .env.template`
- BASE_URL guard in build: `grep "if not process.env.BASE_URL" .lute/build.luau`
- `lute run install` availability: `lute run install --help`
