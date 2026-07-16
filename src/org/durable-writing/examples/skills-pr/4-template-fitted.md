## Problem

The org's react-lua conventions, both component structure and Foundation usage, live only in Flipbook's code. An agent starting UI work in any repo re-derives them from that source each time, and a second repo growing a react-lua UI has no shared reference to follow.

## Solution

Two org-scope skills: `org/write-react-code` for component structure and `org/use-foundation` for Foundation styling. Both are distilled from Flipbook's codebase, the org's largest react-lua corpus, but filed at `org/` rather than `flipbook/` because the patterns are library-level, not Flipbook's house style.

## Testing

Docs only, so nothing to exercise beyond CI, which runs the index-agreement test that fails if a skill is added without its AGENTS.md entry.

## Notes for reviewers

The scope is the call to weigh. Every example comes from Flipbook, yet both skills sit at `org/`. If they read as Flipbook-specific rather than general react-lua doctrine, the fix is to move them to `flipbook/`, not to rewrite them.
