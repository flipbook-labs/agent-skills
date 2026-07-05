# agent-skills — authoring conventions

These skills exist to give an agent production-grade context on flipbook-labs work
without loading everything into always-on context. They are **living documents**, not
a frozen spec. This file governs how to trust them and how to keep them from drifting.
Read it before authoring or heavily editing a skill.

Skills live under `src/<scope>/<name>/SKILL.md` (a vendor-neutral home, usable by any
agent tool) and are distributed as a versioned Loom package. Routing is manual: the
**Project Skills index in [AGENTS.md](AGENTS.md)** maps triggers to skills, and agents
read the matching `SKILL.md` before working. That index is part of the library —
**adding, renaming, or retiring a skill requires updating the index in the same
commit**, or the skill silently stops being loaded.

## Scope: where a skill goes

Place each skill in the narrowest scope that fits, under `src/`:

- **`org/`** — applies to any flipbook-labs repo (doctrine, discipline, house style).
- **`family/`** — the Flipbook / Storyteller / ModuleLoader family specifically.
- **`flipbook/`**, **`agent-gateway/`**, … — one repo's own knowledge and runbooks.

Scope drives more than filing: broader-scope skills must avoid single-repo anchors,
while repo-scoped skills (`flipbook/`, etc.) carry the heaviest drift risk (see the
maintenance norm) and therefore the strictest re-verification requirements.

## Two genres: process and knowledge

Every skill declares `type: process` or `type: knowledge` in its frontmatter. Both
genres load the same way (trigger description → read on demand); the split governs
*form* and *how they rot*, not where they live:

- **Process** (`type: process`) — imperative, "do this next": runbooks, campaigns,
  review discipline. Keep them short — commands, expected output, gates. When a
  process skill grows a background section beyond a few lines, that is the smell:
  extract the background into a knowledge skill and link it. Process links to
  knowledge for the *why*; it never inlines it.
- **Knowledge** (`type: knowledge`) — declarative, "how the system is and why":
  architecture contracts, domain reference, failure archaeology. The long reference layer.

They drift differently, so they re-verify differently. Process skills are nearly
self-testing — run the command and drift fails loudly; their re-verify blocks are
commands to run. Knowledge skills fail *silently* — which is exactly why the anchor
convention and provenance footers below matter most there; their re-verify blocks are
greps and anchors to confirm.

Filing rule for new content: tells you *what to do next* → process; tells you *how or
why the system is* → knowledge; user-facing rather than agent-facing → it belongs on
the docs site, not in a skill (the library must not duplicate the docs of record).

## The two-altitude trust model

Every skill mixes two kinds of content, and they earn different amounts of trust:

- **Durable layer — authoritative.** Doctrine, invariants, mechanisms, architecture
  contracts, failure archaeology, the *why* behind a decision. This ages slowly. It is
  the reason the library is worth having, and you can rely on it.
- **Volatile layer — convenience, re-verify before you lean on it.** Anything a routine
  code change can invalidate: exact versions, config values, place/universe IDs,
  "currently…" claims, command output, and any pointer into source. Treat these as a
  *snapshot with a timestamp*, never as ground truth. If a decision is high-stakes,
  re-derive the fact from the repo first.

When the two disagree, the repo wins over the skill, and the durable layer wins over
the volatile layer. A skill that is confidently wrong is worse than no skill, because
it substitutes for looking — so the volatile layer is deliberately fenced off and dated.

## Locate source by anchor, never by line number

**Do not cite source by line number.** Line numbers rot on the next edit and there is
no cheap way to notice they've gone stale — an agent will confidently read the wrong
lines. Every pointer into source must be a **grep-able anchor**: a function name,
constant, type, setting key, or a short distinctive string or comment.

- Bad: ``the guard in `.lute/build.luau` (lines 100–105)``
- Good: ``the `if not process.env.BASE_URL` guard in `.lute/build.luau` (grep `not process.env.BASE_URL`)``

Before you write an anchor, open the file and confirm the token exists and is
distinctive enough to locate. Never invent one. If nothing stable marks the spot, name
the file and the symbol/section and say what to look for — still no line number. The one
exception: line references *into a code or output block printed inside the skill itself*
are self-contained and fine.

**Paths are relative to the repo the skill is about, never absolute.** A skill in
`flipbook/` writes paths relative to the Flipbook repo root (`.lute/build.luau`); a
`family/` skill references sibling repos as `../storyteller/…`. Never hardcode a
machine-specific prefix (`/Users/you/…`) — it fails or silently misleads on every other
clone. In scripts, derive the root at runtime (e.g. `path.dirname(debug.info(1, "s"))`,
not a literal). If you paste real command output containing an absolute path, redact the
prefix to `<REPO_ROOT>`. Remember these skills are *installed into a package store* on
the consumer's machine — never write a path relative to this repo's own layout; write it
relative to the repo the reader is working in.

## The maintenance norm — this is the forcing function

Skills do not heal themselves. An agent only updates a skill if it is told to, so this is
the standing rule:

> **When work contradicts a skill you loaded, fix the skill — and add a `.changes/`
> entry — as part of the same effort.** Renamed the symbol an anchor points at? Re-point
> it. Changed the config a table documents? Update the row and its date stamp. Proved a
> "known bug" is fixed? Move it to resolved in the failure archaeology.

Two cases, because this is a versioned package:

- **You are editing this repo directly** — fix the skill in the same PR as your other
  work here, with a changelog entry. Reviewers treat the skill edit as part of the
  change, the same way a public API change expects a doc change.
- **You noticed the drift while working in a *consumer* repo** (the common case for
  `flipbook/` skills, whose anchors point into another repo's source) — you can't fix it
  in that repo's PR across the package boundary. Instead propose the fix here immediately
  (don't let the observation evaporate; `lute run contribute-skills` opens a draft PR with
  a `.changes/` entry) and note in your consumer PR that a shared-skill fix is pending. It
  reaches consumers when they bump the pinned version.

This keeps drift local and cheap. A skill touched every time its subject changes never
drifts far. Skipping it exports a bigger, colder debugging cost to whoever trusts the
skill next.

## Every skill carries its own re-verification kit

Each skill ends with a **Provenance and Maintenance** footer. It is load-bearing:

- **`Date stamped:` / `Last verified:`** — when the volatile layer was last checked
  against the repo.
- **`Re-verify these claims when this skill next loads:`** — a short list of exact
  commands or greps that re-derive the perishable facts. This is what turns "self-healing
  in principle" into "self-healing in fact." When you rely on the volatile layer, run this
  block first; when you edit the skill, refresh the date.

Where drift can be checked mechanically, prefer a script over prose — ship it under the
skill's `scripts/` dir. A script that compares a skill's claim to live repo state is the
strongest form of self-healing we have; add one whenever a fact is both important and
mechanically checkable. **This is mandatory, not optional, for `src/flipbook/**` and other
single-repo scopes**, whose anchors point into a separately-released repo and therefore
drift fastest and heal slowest.

## Authoring checklist

- [ ] Skill placed in the narrowest fitting scope under `src/`; broader scopes carry no
      single-repo anchors.
- [ ] Durable claims stated plainly; volatile claims fenced into tables/footers and dated.
- [ ] Zero line-number pointers into source — anchors only, each verified present in the repo.
- [ ] Zero absolute/machine-specific paths — relative to the repo the skill is about,
      `../sibling` for sibling repos, runtime-derived in scripts.
- [ ] Frontmatter `description` says exactly *when to load* (trigger-rich "Use when:") and
      `type:` declares the genre.
- [ ] Project Skills index in AGENTS.md updated if the skill is new, renamed, or retired.
- [ ] "When not to use" links sibling skills so the right one wins.
- [ ] Provenance footer with a date stamp and a runnable re-verify block; a `scripts/`
      drift detector for single-repo scopes where the fact is mechanically checkable.
- [ ] A `.changes/` entry (`bump:` + short description) so the change lands in the next release's changelog.
