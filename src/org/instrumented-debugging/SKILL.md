---
name: instrumented-debugging
description: "Discipline for debugging with probes and controls when static reasoning stalls: assert every patch, verify probes shipped, run the control before assigning blame, and know when to stop deriving. Use when: chasing a bug across builds or environments, adding print/trace instrumentation, interpreting probe output, or when two consecutive theories have died."
type: process
---

# Instrumented Debugging

The discipline for investigations where reading the code stops producing answers. Its core claim: **silence is not evidence, and derivation has a budget.** These rules exist because every one of them was violated in a real multi-hour hunt, and each violation produced a confident, wrong conclusion.

## When not to use

For the first hour of a bug: read the code, check the obvious. This skill governs what happens after reading stops converging — probes, controls, and A/B builds. Repo-specific mechanics (how to build, where artifacts land, what environments exist) live in that repo's skills.

## 1. Derivation has a budget

Static reasoning is cheap and often right — until it isn't. The rule: **when two consecutive theories die on contact with evidence, stop deriving and instrument.** Each additional derivation after that point tends to be as confident and as wrong as the last, because the mental model itself is broken. The purpose of instrumentation is to replace the model, not to confirm it.

The complementary rule: **lean on the human for load-bearing topology claims.** The engineer knows which copies of what run where, which files are stripped from which builds, and what "should not be doing any work." Minutes of asking beat hours of archaeology; state your current model in one paragraph so it can be corrected cheaply.

## 2. Every probe is code: assert it, then verify it shipped

Two failure modes turn instrumentation into disinformation:

- **Silent no-op patches.** A scripted edit whose anchor doesn't match does nothing, quietly. Every automated replacement must `assert` the anchor exists before replacing and fail loudly otherwise. A probe you believe exists but doesn't converts "the code didn't run" and "the probe didn't ship" into the same observation.
- **Probes that never reach the artifact.** After building, grep the *shipped artifact* (bundle, overlay, dist) for the probe markers before interpreting any output. Absence of output from a probe you haven't verified shipped is not evidence of anything.

The real incident: two of three probe patches silently no-op'd; the missing output was read as "this pipeline never executes," redirecting the investigation down an entirely false branch.

## 3. Silence is not evidence; presence barely is

- A missing log line means the probe didn't fire **or** didn't exist **or** the output was truncated. Confirm which before concluding.
- When a human relays logs, ask whether the paste is complete — a paste that starts at the first interesting line may have cut the decisive earlier ones.
- Attribute every log line to its source environment before reasoning from it. If the same code can run in multiple copies (native/sandboxed/bundled), an unattributed line supports nothing. Fingerprint with identities (`tostring(table)` hashes), not names — names are shared across copies.

## 4. Run the control before assigning blame

Before attributing a failure to a branch, a change, or a layer: run the **same scenario on the baseline** (main, the previous release, the untouched environment). Half of "regressions" reproduce on the baseline, and each one caught early saves an archaeology session. Corollaries:

- One variable at a time. A build that changes branch *and* environment *and* configuration attributes nothing.
- Know exactly what you built: assert the branch, grep the artifact for a change marker, record the timestamp. Handing over a mislabeled build poisons every conclusion drawn from it.
- Keep a written ledger of experiments (build → environment → result). Memory rewrites itself under a long hunt; the ledger doesn't.

## 5. Probes escalate; make the last one surgical

Order instrumentation from broad to sharp, and prefer probes that fire **only in the failure case**:

1. Identity fingerprints at module/world boundaries (who exists?)
2. Lifecycle events with identities (who created/destroyed what, when?)
3. A guard at the exact failure point that prints a traceback only when the invariant is already broken (whose stack is this?)

A conditional guard at the failure site is worth ten unconditional logs: zero noise, and its firing is itself the proof.

## 6. Exit criteria

Instrumentation ends when the causal chain is stated in one paragraph and every link is backed by an observed line — not by inference. Then: strip every probe from every repo before committing, land the fix with a regression test where the environment permits, and record the incident (symptom → dead theories → discriminating evidence → verdict) in the repo's failure log so the next hunt starts warm.

## Provenance and Maintenance

Distilled from the July 2026 sandboxed-Storyteller React crash hunt (four dead theories, three probe generations, two repos). Vendor-neutral by design; pair with the repo's own debugging and build skills.
