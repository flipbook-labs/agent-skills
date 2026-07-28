-- Validates the skill library, discovered by Lute's built-in `lute test`:
--   * every src/<scope>/<name>/SKILL.md has well-formed frontmatter
--     (name matching its directory, a non-empty description, a type);
--   * the AGENTS.md Project Skills index and the on-disk skills agree exactly.
-- The authoring conventions from CONTRIBUTING.md are checked in doctrine.spec.luau.
-- Pure @std, so the AgentSkills package stays dependency-free.

local fs = require("@std/fs")
local test = require("@std/test")

local discoverSkills = require("./lib/discoverSkills")
local parseFrontmatter = require("./lib/parseFrontmatter")

test.suite("skill library", function(suite)
	local skills = discoverSkills()

	for _, skill in skills do
		suite:case(`{skill.id} has well-formed frontmatter`, function(assert)
			assert.that(fs.exists(skill.skillPath), `{skill.id}: skill directory has no SKILL.md`)

			local fields = parseFrontmatter(fs.readFileToString(skill.skillPath))
			assert.that(fields, `{skill.id}: missing or malformed frontmatter (needs a leading --- … --- block)`)
			if fields then
				assert.eq(fields.name, skill.name, `{skill.id}: frontmatter "name" must match the directory`)
				assert.that(
					fields.description ~= nil and fields.description ~= "",
					`{skill.id}: frontmatter is missing a non-empty "description"`
				)
				assert.that(fields.type ~= nil and fields.type ~= "", `{skill.id}: frontmatter is missing "type"`)
			end
		end)
	end

	suite:case("AGENTS.md index and the src/ tree agree", function(assert)
		local onDisk: { [string]: boolean } = {}
		local scopes: { [string]: boolean } = {}
		for _, skill in skills do
			onDisk[skill.id] = true
			scopes[skill.scope] = true
		end

		local indexed: { [string]: boolean } = {}
		if fs.exists("AGENTS.md") then
			local agents = fs.readFileToString("AGENTS.md")
			for id in string.gmatch(agents, "`([%w%-]+/[%w%-]+)`") do
				local scope = string.match(id, "^([%w%-]+)/")
				if scope and scopes[scope] then
					indexed[id] = true
				end
			end
		end

		for id in onDisk do
			assert.that(indexed[id], `{id}: skill exists on disk but is not listed in the AGENTS.md index`)
		end
		for id in indexed do
			assert.that(onDisk[id], `{id}: listed in the AGENTS.md index but no skill exists on disk`)
		end
	end)
end)
