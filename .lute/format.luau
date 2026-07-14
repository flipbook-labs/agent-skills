-- Checks Markdown formatting with Prettier. Prettier is a Node tool pinned in
-- package.json and installed with `npm ci`, so a contributor and CI format
-- against the same version. Run `npm ci` once before using this locally. Pass
-- --write to reformat in place; the default --check is what CI runs. Run via
-- `lute run format`.

local process = require("@std/process")

local write = table.find(process.args, "--write") ~= nil

local result = process.run({
	"npx",
	"prettier",
	if write then "--write" else "--check",
	"**/*.md",
}, {
	stdio = "inherit",
})

if not result.ok then
	process.exit(result.exitcode)
end
