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
_form_ and _how they rot_, not where they live:

- **Process** (`type: process`) — imperative, "do this next": runbooks, campaigns,
  review discipline. Keep them short — commands, expected output, gates. When a
  process skill grows a background section beyond a few lines, that is the smell:
  extract the background into a knowledge skill and link it. Process links to
  knowledge for the _why_; it never inlines it.
- **Knowledge** (`type: knowledge`) — declarative, "how the system is and why":
  architecture contracts, domain reference, failure archaeology. The long reference layer.

They drift differently, so they re-verify differently. Process skills are nearly
self-testing — run the command and drift fails loudly; their re-verify blocks are
commands to run. Knowledge skills fail _silently_ — which is exactly why the anchor
convention and provenance footers below matter most there; their re-verify blocks are
greps and anchors to confirm.

Filing rule for new content: tells you _what to do next_ → process; tells you _how or
why the system is_ → knowledge; user-facing rather than agent-facing → it belongs on
the docs site, not in a skill (the library must not duplicate the docs of record).

## The two-altitude trust model

Every skill mixes two kinds of content, and they earn different amounts of trust:

- **Durable layer — authoritative.** Doctrine, invariants, mechanisms, architecture
  contracts, failure archaeology, the _why_ behind a decision. This ages slowly. It is
  the reason the library is worth having, and you can rely on it.
- **Volatile layer — convenience, re-verify before you lean on it.** Anything a routine
  code change can invalidate: exact versions, config values, place/universe IDs,
  "currently…" claims, command output, and any pointer into source. Treat these as a
  _snapshot with a timestamp_, never as ground truth. If a decision is high-stakes,
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
exception: line references _into a code or output block printed inside the skill itself_
are self-contained and fine.

**Paths are relative to the repo the skill is about, never absolute.** A skill in
`flipbook/` writes paths relative to the Flipbook repo root (`.lute/build.luau`); a
`family/` skill references sibling repos as `../storyteller/…`. Never hardcode a
machine-specific prefix (`/Users/you/…`) — it fails or silently misleads on every other
clone. In scripts, derive the root at runtime (e.g. `path.dirname(debug.info(1, "s"))`,
not a literal). If you paste real command output containing an absolute path, redact the
prefix to `<REPO_ROOT>`. Remember these skills are _installed into a package store_ on
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
- **You noticed the drift while working in a _consumer_ repo** (the common case for
  `flipbook/` skills, whose anchors point into another repo's source) — you can't fix it
  in that repo's PR across the package boundary. Instead propose the fix here immediately
  (don't let the observation evaporate) by opening a PR against agent-skills with a
  `.changes/` entry, and note in your consumer PR that a shared-skill fix is pending. It
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
- [ ] Frontmatter `description` says exactly _when to load_ (trigger-rich "Use when:") and
      `type:` declares the genre.
- [ ] Frontmatter `name` is kebab-case and within 64 characters, and `description` is within 1024 characters. Codex silently refuses to load a skill whose description runs past that, so it goes invisible rather than failing loudly.
- [ ] Body within 500 lines. Past that a skill gets skimmed rather than read, so move the
      detail into a sibling file and link to it from `SKILL.md`.
- [ ] Project Skills index in AGENTS.md updated if the skill is new, renamed, or retired.
- [ ] "When not to use" links sibling skills so the right one wins.
- [ ] Provenance footer with a date stamp and a runnable re-verify block; a `scripts/`
      drift detector for single-repo scopes where the fact is mechanically checkable.
- [ ] A `.changes/` entry (`bump:` + short description) so the change lands in the next release's changelog.

## Most of the checklist is enforced

`lute test` runs the mechanical half of the checklist over every skill, so it fails loudly instead of depending on an author to remember it. The rules live in `tests/lib/doctrineRules.luau`, split by what they judge:

- **Skill rules** run once, against `SKILL.md`, because they are about the skill as a unit: the frontmatter genre and load trigger, the `name` format and length, the `description` length, the provenance footer and its date stamp, and the body-length ceiling.
- **Prose rules** run against every markdown file in the skill's directory, `SKILL.md` and the reference files nested beneath it alike, because a reader who follows a link out of a skill reads what they land on the same way. They cover em dashes, line-number citations, machine-specific paths, and relative links that resolve. A relative link resolves against the folder holding the file that carries it, not the skill root.

Each rule is tested in `tests/doctrineRules.spec.luau` and file discovery in `tests/discoverMarkdownFiles.spec.luau`, so neither a rule that stops matching nor a discovery that stops finding files can pass the library silently. A rule reports every place it fires rather than the first, so one run gives you the whole worklist.

The library passes every check, with no grandfathered exceptions.

The body-length ceiling is the one number that is not the convention. It is set at 1150 lines, a little above the longest skill here today, while the convention is 500. It holds the line against new sprawl while the long `flipbook/` skills get split into sibling reference files, and it comes down as they are. A passing run means a skill has not grown. It does not mean the skill is within the convention.

The 1024-character `description` ceiling runs the other way: it is not ours to relax. Codex refuses to load a skill whose description passes it, and refuses silently, so the skill goes invisible instead of failing. Shorten the description rather than the number.

One checklist item has no check at all: the `scripts/` drift detector, which two of the twenty-one single-repo skills ship. That needs the content work before the check can go in, so it lands with it rather than as a backlog the suite tolerates.

The judgment half stays yours. Nothing here can tell you whether a claim is true,
whether an anchor points at the right symbol, or whether a skill has earned its length.

## Opting a file out of a prose rule

A file that exists to show bad writing has to be allowed to hold it. `src/org/durable-writing/examples/` reproduces real PR bodies verbatim, including the drafts the skill is teaching you to avoid, so correcting their punctuation would corrupt the exemplar. A file in that position declares an opt-out in an HTML comment, which renders as nothing:

```markdown
<!-- doctrine-exempt rules="em-dash" reason="Reproduced verbatim as the draft this example exists to criticize." -->
```

- `rules` names specific rule ids, comma-separated. An opt-out is never blanket, so every rule the marker does not name keeps checking the file.
- `reason` is required. A marker without one exempts nothing and is reported instead, so no file gets muted by a marker nobody had to justify.
- Grep `doctrine-exempt` to find every one in the library.

The marker is checked as hard as the rules it mutes. Naming a rule that does not exist fails, and so does exempting a rule the file no longer breaks, because a marker left behind after its violation is gone is a rule switched off with nothing to notice it. Fix the file and delete the marker in the same edit.
