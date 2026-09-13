local fs = require("@std/fs")
local path = require("@std/path")
local process = require("@std/process")

local function findRepoRoot(): string
	local dir = path.format(process.cwd())
	for _ = 1, 12 do
		if fs.exists(path.join(dir, "workspace/flipbook-core")) and fs.exists(path.join(dir, ".lute/build.luau")) then
			return dir
		end
		local parent = path.dirname(dir)
		if parent == dir then
			break
		end
		dir = parent
	end
	error("could not locate the Flipbook repo root")
end

local function checkAnchors(repoRoot: string, relativePath: string, anchors: { string })
	local filePath = path.join(repoRoot, relativePath)
	if not fs.exists(filePath) then
		error(`missing {relativePath}`)
	end
	local content = fs.readFileToString(filePath)
	for _, anchor in anchors do
		if not content:find(anchor, 1, true) then
			error(`missing anchor "{anchor}" in {relativePath}`)
		end
	end
end

local repoRoot = findRepoRoot()

checkAnchors(repoRoot, ".mcp.json", {
	'"Roblox_Studio"',
	"StudioMCP",
})
checkAnchors(repoRoot, "workspace/flipbook-agents/src/createAgentGateway.luau", {
	'name = "FlipbookAgentGateway"',
})
for _, actionName in {
	"openWidget",
	"embedFlipbook",
	"listStorybooks",
	"listStories",
	"openStory",
	"getCurrentStory",
	"getControls",
	"setControls",
} do
	checkAnchors(repoRoot, `workspace/flipbook-agents/src/actions/{actionName}.luau`, {
		`name = "{actionName}"`,
	})
end
checkAnchors(repoRoot, ".lute/build.luau", {
	'subcommand == "plugin"',
	'subcommand == "storybook"',
})

print("Flipbook Studio MCP skill anchors are current")
