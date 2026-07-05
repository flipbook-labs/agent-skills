-- Validates the skill library, discovered by Lute's built-in `lute test`:
--   * every src/<scope>/<name>/SKILL.md has well-formed frontmatter
--     (name matching its directory, a non-empty description, a type);
--   * the AGENTS.md Project Skills index and the on-disk skills agree exactly.
-- Scopes are discovered from the src/ tree, so adding a scope needs no edit here.
-- Pure @std, so the AgentSkills package stays dependency-free.

local test = require("@std/test")
local fs = require("@std/fs")
local path = require("@std/path")

type Skill = { scope: string, name: string, id: string, skillPath: string }

-- Parse the leading `---` … `---` frontmatter block into flat key/value pairs.
-- Only simple scalar keys (name/description/type) are emitted, which is all the
-- doctrine requires; nested YAML is not used in SKILL.md frontmatter.
local function parseFrontmatter(contents: string): { [string]: string }?
	local normalized = string.gsub(contents, "\r\n", "\n")
	local block = string.match(normalized, "^%-%-%-\n(.-)\n%-%-%-")
	if not block then
		return nil
	end
	local fields: { [string]: string } = {}
	for _, line in string.split(block, "\n") do
		local key, value = string.match(line, "^([%w_%-]+):%s*(.*)$")
		if key and value then
			local unquoted = string.gsub(value, '^"(.*)"$', "%1")
			unquoted = string.gsub(unquoted, "^'(.*)'$", "%1")
			fields[key] = unquoted
		end
	end
	return fields
end

-- Discover skills from the src/<scope>/<name>/ tree and the set of scopes.
local function discover(): ({ Skill }, { [string]: boolean })
	local skills: { Skill } = {}
	local scopes: { [string]: boolean } = {}
	if not fs.exists("src") then
		return skills, scopes
	end
	for _, scopeEntry in fs.listDirectory("src") do
		if scopeEntry.type == "dir" then
			local scope = scopeEntry.name
			scopes[scope] = true
			for _, skillEntry in fs.listDirectory(path.join("src", scope)) do
				if skillEntry.type == "dir" then
					local name = skillEntry.name
					table.insert(skills, {
						scope = scope,
						name = name,
						id = `{scope}/{name}`,
						skillPath = path.format(path.join("src", scope, name, "SKILL.md")),
					})
				end
			end
		end
	end
	return skills, scopes
end

test.suite("skill library", function(suite)
	local skills, scopes = discover()

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
		for _, skill in skills do
			onDisk[skill.id] = true
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
