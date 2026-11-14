-- Discover skills from the src/<scope>/<name>/ tree, so adding a scope needs no
-- edit to the specs that consume this.

local fs = require("@std/fs")
local path = require("@std/path")

local types = require("./types")

type Skill = types.Skill

local function discoverSkills(): { Skill }
	local skills: { Skill } = {}
	if not fs.exists("src") then
		return skills
	end
	for _, scopeEntry in fs.listDirectory("src") do
		if scopeEntry.type == "dir" then
			local scope = scopeEntry.name
			for _, skillEntry in fs.listDirectory(path.join("src", scope)) do
				if skillEntry.type == "dir" then
					local name = skillEntry.name
					local directory = path.join("src", scope, name)
					table.insert(skills, {
						scope = scope,
						name = name,
						id = `{scope}/{name}`,
						directory = path.format(directory),
						skillPath = path.format(path.join(directory, "SKILL.md")),
					})
				end
			end
		end
	end
	return skills
end

return discoverSkills
