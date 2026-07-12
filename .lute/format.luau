-- Checks Markdown formatting with Prettier. Prettier is a Node tool fetched on
-- demand with npx (Node is present on CI runners and in local dev), so the repo
-- carries no package.json. The version is pinned here so a contributor and CI
-- format against the same rules. Pass --write to reformat in place; the default
-- --check is what CI runs. Run via `lute run format`.

local process = require("@std/process")

local PRETTIER = "prettier@3.9.5"

local write = table.find(process.args, "--write") ~= nil

local result = process.run({
	"npx",
	"--yes",
	PRETTIER,
	if write then "--write" else "--check",
	"**/*.md",
}, {
	stdio = "inherit",
})

if not result.ok then
	process.exit(result.exitcode)
end
