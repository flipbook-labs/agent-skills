# Incident files

Long-form investigation write-ups, one file per incident. The base `SKILL.md` carries the older inline entries and the how-to-use doctrine; new incidents land here as standalone files so each can be read (or skipped) whole.

Each file follows the same arc: **symptom → dead theories (and what killed each) → root cause → fix → verdicts.** The dead theories are the point — they are what a future agent would otherwise re-derive.

| Incident | One-line summary |
| --- | --- |
| [`2026-07-19-sandboxed-storyteller-react-crash.md`](2026-07-19-sandboxed-storyteller-react-crash.md) | React stories crashed with nil-dispatcher in dev places; four plausible diagnoses died before instrumentation revealed sandboxed Storyteller copies running discovery. Fixed by making sandboxed copies inert. |
