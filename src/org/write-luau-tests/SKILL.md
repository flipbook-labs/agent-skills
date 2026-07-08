---
name: write-luau-tests
description: "Test-quality discipline for Luau: how to write unit tests that specify intended behavior and can actually fail. Use when: writing or modifying unit tests/specs, adding coverage for new or existing code, deciding whether a test is good enough, or a test you wrote fails and you are tempted to change the test. This is the vendor-neutral doctrine; repo-specific mechanics (test runner commands, framework idioms, exemplar specs) live in that repo's own skill."
type: process
---

# Write Luau Tests

The discipline for writing tests worth keeping: what a test is *for*, the red-first gate every test must pass through, the moves that are forbidden, and what "good" looks like. **Scope:** test quality and authoring discipline only. This skill owns *whether a test is any good*, not how a specific repo's test infrastructure works.

## When not to use

For how to *run* tests in a given repo (the command, filtering, the API keys or services a suite needs), its framework idioms (Jest-Luau matchers, `act()`, fake timers), spec-file placement, and its reference exemplars, see that repo's own test skill (for example a `flipbook/write-tests`). This skill is the doctrine those build on; it names no runner and no framework.

## 1. The objective: what a test is for

A test specifies **intended behavior**. Its whole value is the ability to fail when the code is wrong. A suite that passes no matter what the code does is worse than no suite, because it manufactures false confidence and substitutes for looking.

When writing tests for existing code, the question is never "what does this code do?" Transcribing current behavior freezes its bugs in place. The question is "what is this code *supposed* to do?" Derive that from the public contract, the docs, and the call sites. If the intended behavior is genuinely ambiguous, say so in the PR instead of silently canonizing whatever the code happens to do today.

## 2. The red-first gate: every test must be seen failing

A test that has never failed is unproven. Before declaring any test done, put it through one of these two gates.

**New behavior (test-first):**

1. Write the test against the intended contract.
2. Run it and confirm it fails **for the expected reason**: the assertion you wrote, not a `require` error or a typo.
3. Implement, then confirm it goes green.

A test that passes the moment it is written is suspect. It is either testing nothing or testing something that already worked. (The latter is fine, but then the break-the-code gate below applies.)

**Existing code (break-the-code / hand-rolled mutation):**

1. Write the test; it will pass immediately.
2. Deliberately break the module under test: flip a comparison (`>=` to `>`), return early, nil out a field, swap a branch.
3. Run the test and confirm it goes **red**.
4. Revert the break and confirm green.

If no deliberate break makes the test fail, the test is decorative. Fix it or delete it; do not leave it in the suite.

**When the gate cannot run** (the suite needs a service, key, or environment you don't have): the gate is *blocked, not waived*. State this explicitly in the PR ("tests written but not seen red/green in this environment") and never imply the gate passed. Whatever static checks *can* run offline (lint, analyze) still must.

## 3. Forbidden moves

These are the ways agents (and tired humans) game a test suite. All are prohibited:

- **Weakening to green.** A red test is a *finding*, never an obstacle. Do not delete a test, weaken an assertion, broaden a matcher, or add a skip to reach green until you have diagnosed whether the code or the test is wrong, and said which, out loud, in the PR or commit message.
- **Tautologies.** Never assert the implementation against itself (calling the function to compute the expected value, or re-deriving `expected` with the same logic as the code under test). Expected values are literals or independently derived.
- **Mocking the unit under test.** Mocks exist to sever a dependency, never to replace the thing you claim to be testing. If the assertion checks that a mock was called with what you told the mock to receive, you have tested the mock.
- **Vacuous assertions.** No "is defined" / "is not nil" where a concrete value is assertable. Assert the value, the shape, or the observable effect.
- **Behavior transcription.** Do not generate the expected value by running the code and pasting its output. That is a snapshot of current behavior, bugs included (see §1).
- **Coverage theater.** Do not add tests whose only purpose is touching lines. Every test encodes a claim about intended behavior that the break-the-code gate can validate.
- **Orphaned skips.** Do not leave a `skip`ped test in the suite without a reason. A skip is a disabled assertion, so either unskip it, or delete it, or leave a comment saying why it is off and when it comes back. Marin: *"Either unskip or remove this test."*

## 4. What good looks like: the rubric

- **Names are behavioral specs.** `"runs the callback immediately on the first call"`, `"throws when the id is unknown"`. A reviewer should reconstruct the contract from the test names alone, not from `"test callback"` or `"works correctly"`.
- **Test the public contract, not internals.** Assert what a caller observes: return values, thrown errors, callback invocations, emitted values, observable side effects. Never assert private state, internal call order, or intermediate representations.
- **Real objects first; mocks only to sever.** Prefer real data structures, real stores, real collaborators. Reach for a fake only when a dependency is slow, nondeterministic, or outside the unit's contract.
- **Error and edge paths are first-class.** Every happy-path group is accompanied by the boundary and failure cases: out-of-range, malformed input, empty, the error message a caller should see.
- **Shared fixtures over ad-hoc setup.** Use and extend existing test helpers rather than re-rolling setup per test; reset shared state between tests to prevent pollution.
- **Arrange, act, assert; one behavior per test.** Multiple assertions are fine when they verify a single cohesive behavior.
- **Assert across every analogous case, not just one.** When a family of constructors, factories, or branches share an invariant, assert it in all of them, not in a representative one. Marin, on a set of control constructors: *"If we're going to assert here, we should also assert in the other constructors where necessary,"* especially that the mappings actually map correctly. A test that checks one member of a family lets the others regress silently.
- **Prefer determinism over waiting.** Reach for a synchronization point rather than a timed wait, and remove every `task.wait` a test does not truly need. Sprinkled waits are slow and flaky; if a wait is load-bearing, it is usually hiding a seam you could drive directly instead.

## 5. Testing behavior with observable effects

Some code exists for a side effect rather than a return value: UI that renders, an event that fires, a store that notifies. Test it the way its real caller drives it (fire the event, apply the input, advance the clock), then assert on what an observer downstream would see, not on internal bookkeeping. A test that exercises the code the way it is actually used proves more than one that pokes at internals. Assert cleanup too when the unit owns a resource. Framework-specific mechanics for doing this live in the relevant repo's test skill.

## 6. Pre-done checklist

Before declaring test work complete, confirm every line:

- [ ] Every new or changed test has been seen **red** at least once, via a test-first failure or a deliberate break (§2). If the gate was blocked, the PR says so explicitly.
- [ ] Test names read as behavioral specs; a reviewer could reconstruct the contract from names alone.
- [ ] No forbidden moves (§3): no tautologies, no mocked subject, no vacuous assertions, no weakened-to-green tests, no transcribed behavior.
- [ ] Error and edge paths are covered, not only the happy path.
- [ ] Existing test helpers were used (or extended) instead of duplicating setup.
- [ ] If a pre-existing test was modified or deleted, the PR explains why the *test* was wrong, not only that it now passes.

---

## Provenance and Maintenance

**Date stamped:** 2026-07-07. Doctrine extracted and generalized from Flipbook's `write-flipbook-tests` skill; this is the vendor-neutral core, with runner, framework, and exemplar specifics left to each repo's own test skill. Updated 2026-07-07 with orphaned-skip discipline, asserting across every analogous case, and preferring determinism over waits, from Storyteller review comments.

**Re-verify these claims when this skill next loads:** this skill is pure doctrine and makes no claims about any repo's source, so it has no volatile layer to re-derive. When a consuming repo's test skill drifts from this doctrine (a forbidden move creeps into its exemplars, or its red-first wording weakens), fix it there, and if the *principle* changed, update this skill and add a `.changes/` entry.

**Cross-model eval (2026-07-05):** a Sonnet model, guided only by this skill, wrote tests for a function with a seeded boundary bug. It tested the *intended contract* rather than the current behavior, correctly predicted the contract tests would go red, and flagged the bug to the author rather than transcribing it, landing in the acceptance band with no refinement needed. Re-run this kind of check (a weaker or different model, a task with a latent bug, does the skill steer it to the contract?) when materially editing §1 through §3.
