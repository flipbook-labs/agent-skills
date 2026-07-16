Add two org-scope skills distilling the house react-lua patterns, using Flipbook's component codebase as the evidence base (roughly 80 components and 44 Foundation-consuming modules across flipbook-core and flipbook-next, spot-verified against source before anything was written down).

**`org/write-react-code`** covers the structure of React code: component module anatomy and the `e` alias, exported `Props` types with defaults via Sift, named-children element trees, state placement (`useState` vs Charm signals and computeds), the `Context`/`Provider`/`use*` context module shape, effect discipline, and colocated `.story.luau` / `.spec.luau` files.

**`org/use-foundation`** covers styling with the Foundation design system: FoundationProvider and theme resolution, the `tag` utility system, design tokens via `useTokens`, component and enum idioms, `CommonProps` passthrough, and when dropping to a raw Roblox instance is allowed. Its volatile layer (tag vocabulary, deprecated enums) is dated and carries a re-verify block that greps the installed Foundation package.

Both are filed at `org/` scope with frozen inline exemplars and no single-repo anchors, since the patterns should hold for any flipbook-labs repo that grows a react-lua UI. The AGENTS.md index and a `.changes/` entry (minor bump) land in the same commit per CONTRIBUTING.md.

Checks: `lute test` passes (15/15, including the index-agreement case), and the changed files are Prettier-clean. AGENTS.md has a pre-existing formatting warning on an untouched line that #28's formatting pass already covers, so this PR leaves it alone.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
