-- Validates the skill library:
--   1. Every src/<scope>/<name>/SKILL.md has well-formed frontmatter
--      (name matching its directory, a non-empty description, a type).
--   2. The AGENTS.md Project Skills index and the on-disk skills agree exactly
--      (no skill missing from the index, no index entry without a skill).
-- Scopes are discovered from the src/ tree, so adding a scope needs no edit here.
-- Pure @std so the AgentSkills package stays dependency-free. Run via `lute run test`.

local fs = require("@std/fs")
local path = require("@std/path")
local process = require("@std/process")

local errors: { string } = {}
local function fail(msg: string)
	table.insert(errors, msg)
end

-- Parse the leading `---` … `---` YAML frontmatter block into flat key/value
-- pairs. We only emit simple scalar keys (name/description/type), which is all
-- the doctrine requires; nested YAML is not used in SKILL.md frontmatter.
local function parseFrontmatter(contents: string): { [string]: string }?
	local normalized = string.gsub(contents, "\r\n", "\n")
	local block = string.match(normalized, "^%-%-%-\n(.-)\n%-%-%-")
	if not block then
		return nil
	end
	local fm: { [string]: string } = {}
	for _, line in string.split(block, "\n") do
		local key, value = string.match(line, "^([%w_%-]+):%s*(.*)$")
		if key and value then
			local unquoted = string.gsub(value, '^"(.*)"$', "%1")
			unquoted = string.gsub(unquoted, "^'(.*)'$", "%1")
			fm[key] = unquoted
		end
	end
	return fm
end

-- 1. Walk src/<scope>/<name>/SKILL.md, discovering scopes from the tree.
local onDisk: { [string]: boolean } = {}
local scopes: { [string]: boolean } = {}
local count = 0

if fs.exists("src") then
	for _, scopeEntry in fs.listDirectory("src") do
		if scopeEntry.type == "dir" then
			local scope = scopeEntry.name
			scopes[scope] = true

			for _, skillEntry in fs.listDirectory(path.join("src", scope)) do
				if skillEntry.type == "dir" then
					local name = skillEntry.name
					local id = `{scope}/{name}`
					local skillPath = path.join("src", scope, name, "SKILL.md")

					if not fs.exists(skillPath) then
						fail(`{id}: skill directory has no SKILL.md`)
						continue
					end

					count += 1
					onDisk[id] = true

					local fm = parseFrontmatter(fs.readFileToString(skillPath))
					if not fm then
						fail(`{id}: missing or malformed frontmatter (needs a leading --- … --- block)`)
					else
						if not fm.name or fm.name == "" then
							fail(`{id}: frontmatter is missing "name"`)
						elseif fm.name ~= name then
							fail(`{id}: frontmatter name "{fm.name}" does not match directory "{name}"`)
						end
						if not fm.description or fm.description == "" then
							fail(`{id}: frontmatter is missing a non-empty "description"`)
						end
						if not fm.type or fm.type == "" then
							fail(`{id}: frontmatter is missing "type"`)
						end
					end
				end
			end
		end
	end
end

-- 2. Cross-check against the AGENTS.md index (entries are `<scope>/<name>`).
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
	if not indexed[id] then
		fail(`{id}: skill exists on disk but is not listed in the AGENTS.md index`)
	end
end
for id in indexed do
	if not onDisk[id] then
		fail(`{id}: listed in the AGENTS.md index but no skill exists on disk`)
	end
end

-- Report.
if #errors > 0 then
	print(`skill validation FAILED ({#errors} problem(s)):`)
	for _, msg in errors do
		print(`  - {msg}`)
	end
	process.exit(1)
end

print(`skill validation OK ({count} skill(s))`)
