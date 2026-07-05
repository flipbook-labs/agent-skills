--!strict
-- Validates the skill library:
--   1. Every src/<scope>/<name>/SKILL.md has well-formed frontmatter
--      (name matching its directory, non-empty description, a valid type).
--   2. The AGENTS.md Project Skills index and the on-disk skills agree exactly
--      (no skill missing from the index, no index entry without a skill).
-- Pure @std so the AgentSkills package stays dependency-free. Run via `lute run test`.

local fs = require("@std/fs")
local path = require("@std/path")
local process = require("@std/process")

local SCOPES = { "org", "family", "flipbook", "agent-gateway" }
local VALID_TYPES = { process = true, knowledge = true }

local scopeSet: { [string]: boolean } = {}
for _, s in SCOPES do
	scopeSet[s] = true
end

local errors: { string } = {}
local function fail(msg: string)
	table.insert(errors, msg)
end

-- Strip a single trailing carriage return (tolerate CRLF checkouts).
local function chomp(s: string): string
	return (string.gsub(s, "\r$", ""))
end

-- Parse the leading `---` … `---` YAML frontmatter block into flat key/value
-- pairs. We only emit simple scalar keys (name/description/type), which is all
-- the doctrine requires; nested YAML is not used in SKILL.md frontmatter.
local function parseFrontmatter(contents: string): { [string]: string }?
	local block = string.match(contents, "^%-%-%-\n(.-)\n%-%-%-")
	if not block then
		return nil
	end
	local fm: { [string]: string } = {}
	for _, rawLine in string.split(block, "\n") do
		local line = chomp(rawLine)
		local key, value = string.match(line, "^([%w_%-]+):%s*(.*)$")
		if key then
			value = string.gsub(value, '^"(.*)"$', "%1")
			value = string.gsub(value, "^'(.*)'$", "%1")
			fm[key] = value
		end
	end
	return fm
end

-- 1. Iterate the one-level src/<scope>/<name>/SKILL.md layout, validating each.
local onDisk: { [string]: boolean } = {}
local count = 0

for _, scope in SCOPES do
	local scopeDir = path.join("src", scope)
	if fs.exists(scopeDir) then
		for _, entry in fs.listDirectory(scopeDir) do
			if entry.type == "dir" then
				local name = entry.name
				local id = `{scope}/{name}`
				local skillPath = path.join(scopeDir, name, "SKILL.md")

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
					if not fm.type then
						fail(`{id}: frontmatter is missing "type" (process | knowledge)`)
					elseif not VALID_TYPES[fm.type] then
						fail(`{id}: invalid type "{fm.type}" (expected process | knowledge)`)
					end
				end
			end
		end
	end
end

-- 2. Cross-check against the AGENTS.md index.
local indexed: { [string]: boolean } = {}
if fs.exists("AGENTS.md") then
	local agents = fs.readFileToString("AGENTS.md")
	for id in string.gmatch(agents, "`([%w%-]+/[%w%-]+)`") do
		local scope = string.match(id, "^([%w%-]+)/")
		if scope and scopeSet[scope] then
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
