## Summary

Add `org/write-react-code` and `org/use-foundation`, two org-scope skills for react-lua UI work. They are distilled from Flipbook's component codebase, the org's largest body of react-lua UI, but filed at `org/` rather than `flipbook/` because the patterns are library-level, not Flipbook's house style: any flipbook-labs repo that grows a react-lua UI should follow them.

- **`org/write-react-code`** owns component structure: module anatomy and the `e` alias, `Props` and defaults via Sift, named-children element trees, state placement across `useState` and Charm, the context module shape, effect discipline, and colocated stories and specs.
- **`org/use-foundation`** owns styling: FoundationProvider and theme resolution, the `tag` system, tokens via `useTokens`, component and enum idioms, and `CommonProps` passthrough. Its volatile tag and enum vocabulary carries a re-verify block that greps the installed Foundation package, so a reader can re-derive it against the release their repo pins.

The code excerpts are frozen illustrations edited down from real components, not live pointers into any repo.

## Checks

`lute test` passes, including the index-agreement case that fails if a skill lacks its AGENTS.md entry, and the changed files are Prettier-clean.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
