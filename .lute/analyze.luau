-- Type-checks the repo's Luau (the lute tasks and any skill drift-detector
-- scripts) with luau-lsp, in the strict mode declared by .luaurc. The lute
-- typedefs are excluded via .vscode/settings.json's ignoreGlobs so only our own
-- code is reported. Run via `lute run analyze`.

local process = require("@std/process")

local result = process.run({
	"luau-lsp",
	"analyze",
	"--platform=standard",
	"--settings=.vscode/settings.json",
	"--base-luaurc=.luaurc",
	".lute",
	"src",
}, {
	stdio = "inherit",
})

if not result.ok then
	process.exit(result.exitcode)
end
