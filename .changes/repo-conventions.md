---
bump: minor
category: Changes
---

Add `org/repo-conventions`, the repo setup and CI conventions for flipbook-labs repos: pinning GitHub Actions by trust boundary, 5-minute job timeouts, strictness from `.luaurc` instead of `--!strict` headers, check logic in `.lute/` scripts rather than workflow YAML, `@std/*` over `@lute/*`, and fetching dev-tool artifacts (such as luau-lsp `globalTypes`) from upstream `main` rather than a pinned version.
