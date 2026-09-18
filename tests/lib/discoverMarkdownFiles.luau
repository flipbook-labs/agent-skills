-- Every markdown file a skill ships, `SKILL.md` and the reference files nested
-- beneath it alike, so the prose rules cover what a reader reaches by following a
-- link out of the skill.

local fs = require("@std/fs")
local path = require("@std/path")

local function collectMarkdown(directory: string, found: { string })
	for _, entry in fs.listDirectory(directory) do
		local entryPath = path.format(path.join(directory, entry.name))
		if entry.type == "dir" then
			collectMarkdown(entryPath, found)
		elseif string.match(entry.name, "%.md$") then
			table.insert(found, entryPath)
		end
	end
end

local function discoverMarkdownFiles(directory: string): { string }
	local found: { string } = {}
	if fs.exists(directory) then
		collectMarkdown(directory, found)
	end
	table.sort(found)
	return found
end

return discoverMarkdownFiles
