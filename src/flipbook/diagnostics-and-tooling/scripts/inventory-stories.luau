-- Inventory all stories and specs in the workspace.
-- Run from the Flipbook repo: lute run ~/.loom/store/AgentSkills@*/src/flipbook/diagnostics-and-tooling/scripts/inventory-stories.luau
-- Outputs a summary of story/spec counts per workspace member.

local fs = require("@std/fs")
local path = require("@std/path")
local process = require("@std/process")

-- The script lives in the installed AgentSkills package, so its own path is not
-- the repo root. Resolve from the working directory instead, walking up to the
-- rokit.toml marker, so this runs from anywhere inside the Flipbook checkout.
local function findRepoRoot(): string
	local dir = path.format(process.cwd())
	for _ = 1, 12 do
		if fs.exists(path.join(dir, "rokit.toml")) then
			return dir
		end
		local parent = path.dirname(dir)
		if parent == dir then
			break
		end
		dir = parent
	end
	error("could not locate repo root (no rokit.toml found above the current directory)")
end

local WORKSPACE_ROOT = path.join(findRepoRoot(), "workspace")

local function countMatching(dir: string, pattern: string): number
	if not fs.exists(dir) then
		return 0
	end

	local count = 0
	for _, entry in fs.listDirectory(dir) do
		local entryPath = path.join(dir, entry.name)
		if entry.type == "file" then
			if string.match(entry.name, pattern) then
				count += 1
			end
		elseif entry.type == "dir" then
			count += countMatching(entryPath, pattern)
		end
	end
	return count
end

local members = {}

if fs.exists(WORKSPACE_ROOT) then
	for _, entry in fs.listDirectory(WORKSPACE_ROOT) do
		if entry.type == "dir" and not string.match(entry.name, "^%.") then
			local memberPath = path.join(WORKSPACE_ROOT, entry.name)
			table.insert(members, {
				name = entry.name,
				stories = countMatching(memberPath, "%.story%.luau$"),
				specs = countMatching(memberPath, "%.spec%.luau$"),
			})
		end
	end
end

table.sort(members, function(a, b)
	return a.name < b.name
end)

print("\n=== Flipbook Story & Spec Inventory ===\n")
print(string.format("%-30s %10s %10s", "Workspace Member", "Stories", "Specs"))
print(string.rep("-", 52))

local totalStories = 0
local totalSpecs = 0

for _, member in ipairs(members) do
	print(string.format("%-30s %10d %10d", member.name, member.stories, member.specs))
	totalStories += member.stories
	totalSpecs += member.specs
end

print(string.rep("-", 52))
print(string.format("%-30s %10d %10d\n", "TOTAL", totalStories, totalSpecs))
