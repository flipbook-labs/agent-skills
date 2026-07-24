---
bump: patch
category: Changes
---

`lute test` now checks every skill against the mechanical half of the authoring checklist: the frontmatter genre and load trigger, the provenance footer and its date stamp, em dashes and line-number citations in prose, machine-specific paths, and relative links that resolve. Each rule reports every place it fires, so one run hands you the whole worklist. Every skill in the library passes, which took recasting the em-dash punctuation across most of `flipbook/` and filling in the frontmatter triggers and date stamps that were missing.
