-- The authoring conventions from CONTRIBUTING.md, as checks. Each rule reports
-- every occurrence it finds, so one run gives an author the whole worklist
-- instead of the first failure.
--
-- The rules are split by what they are about. A skill rule judges the skill as a
-- unit and runs against `SKILL.md`. A prose rule judges writing and runs against
-- every markdown file the skill ships, since a reader following a link into a
-- reference file expects the same conventions there.

local fs = require("@std/fs")
local path = require("@std/path")

local parseFrontmatter = require("./parseFrontmatter")
local stripInlineCode = require("./stripInlineCode")
local toProse = require("./toProse")
local types = require("./types")

type DoctrineRules = types.DoctrineRules
type ProseRule = types.ProseRule
type SkillRule = types.SkillRule

local Genre = table.freeze({
	Process = "process",
	Knowledge = "knowledge",
})

-- Codex refuses to load a skill whose description runs past this, and it refuses
-- silently, so tripping the limit makes a skill invisible rather than making it
-- fail. This is an external hard limit and not ours to round off or relax.
local DESCRIPTION_CHARACTER_LIMIT = 1024

local NAME_CHARACTER_LIMIT = 64

-- Lua patterns carry no alternation or group repetition, so `^[a-z0-9]+(-[a-z0-9]+)*$`
-- cannot be written as one pattern here. Kebab-case is checked as the constraints
-- that compose it, which also lets a failure name the character that broke it.
local NAME_FORMAT_CHECKS = table.freeze({
	{
		pattern = "[^%l%d%-]",
		problem = "holds a character outside lowercase letters, digits, and hyphens",
	},
	{
		pattern = "^%-",
		problem = "starts with a hyphen",
	},
	{
		pattern = "%-$",
		problem = "ends with a hyphen",
	},
	{
		pattern = "%-%-",
		problem = "holds a double hyphen",
	},
})

-- CONTRIBUTING.md's checklist sets the convention at 500 lines. This is not that
-- number. It sits a little above the library's longest skill, so it holds the line
-- against new sprawl while the long `flipbook/` skills are split into sibling
-- reference files, and it comes down as they are. Passing it is not evidence that
-- a skill is within the convention.
local BODY_LINE_CEILING = 650

local EXCERPT_RADIUS = 40

local function excerptAround(line: string, matchStart: number): string
	local from = math.max(1, matchStart - EXCERPT_RADIUS)
	local to = math.min(#line, matchStart + EXCERPT_RADIUS)
	return `…{string.sub(line, from, to)}…`
end

-- Reports the first match on each line, quoted with its line number so the
-- failure is fixable without opening the file.
local function findMatches(text: string, pattern: string): { string }
	local matches = {}
	for lineNumber, line in string.split(text, "\n") do
		local matchStart = string.find(line, pattern)
		if matchStart then
			table.insert(matches, `line {lineNumber}: {excerptAround(line, matchStart)}`)
		end
	end
	return matches
end

local function findAnyMatch(text: string, patterns: { string }): { string }
	local matches = {}
	for _, pattern in patterns do
		for _, match in findMatches(text, pattern) do
			table.insert(matches, match)
		end
	end
	return matches
end

-- The checklist bounds the body, so the frontmatter block does not count against
-- the ceiling.
local function getBody(contents: string): string
	local normalized = string.gsub(contents, "\r\n", "\n")
	return string.match(normalized, "^%-%-%-\n.-\n%-%-%-\n(.*)$") or normalized
end

-- The frontmatter limits are stated in characters, and a description may carry a
-- multibyte character, so `#` would count bytes and fail a skill the tool loads
-- fine. `utf8.len` returns nil only on malformed UTF-8, where the byte count is
-- the safe fallback.
local function countCharacters(text: string): number
	return utf8.len(text) or #text
end

local function countLines(text: string): number
	local lines = string.split(text, "\n")
	-- A file ending in a newline splits to a trailing empty piece that is not a line.
	if lines[#lines] == "" then
		table.remove(lines)
	end
	return #lines
end

local skillRules: { SkillRule } = {
	{
		id = "frontmatter-genre",
		summary = "frontmatter `type` declares `process` or `knowledge`",
		findViolations = function(_skill, contents)
			local fields = parseFrontmatter(contents)
			local genre = fields and fields.type
			if genre == Genre.Process or genre == Genre.Knowledge then
				return {}
			end
			return { `frontmatter "type" is "{genre or "missing"}", expected "process" or "knowledge"` }
		end,
	},
	{
		id = "frontmatter-trigger",
		summary = "frontmatter `description` says when to load the skill",
		findViolations = function(_skill, contents)
			local fields = parseFrontmatter(contents)
			local description = fields and fields.description
			-- "Use when", and the narrowing forms "Use only when" and "Use this when".
			if description and string.find(description, "Use%s+[%l%s]*when") then
				return {}
			end
			return { 'frontmatter "description" carries no "Use when" trigger' }
		end,
	},
	{
		id = "name-format",
		summary = "frontmatter `name` is kebab-case",
		findViolations = function(_skill, contents)
			local fields = parseFrontmatter(contents)
			local name = fields and fields.name
			-- Every check below asks whether the name contains something bad, so an
			-- empty name would satisfy all of them. Reject it before they run.
			if not name or name == "" then
				return { 'frontmatter "name" is missing or empty' }
			end
			local violations = {}
			for _, check in NAME_FORMAT_CHECKS do
				if string.find(name, check.pattern) then
					table.insert(violations, `name "{name}" {check.problem}`)
				end
			end
			return violations
		end,
	},
	{
		id = "name-length",
		summary = `frontmatter \`name\` within {NAME_CHARACTER_LIMIT} characters`,
		findViolations = function(_skill, contents)
			local fields = parseFrontmatter(contents)
			local name = fields and fields.name
			if not name then
				return {}
			end
			local length = countCharacters(name)
			if length <= NAME_CHARACTER_LIMIT then
				return {}
			end
			return { `name is {length} characters, over the {NAME_CHARACTER_LIMIT}-character limit` }
		end,
	},
	{
		id = "description-length",
		summary = `frontmatter \`description\` within {DESCRIPTION_CHARACTER_LIMIT} characters, past which Codex will not load the skill`,
		findViolations = function(_skill, contents)
			local fields = parseFrontmatter(contents)
			local description = fields and fields.description
			-- A missing description is `frontmatter-trigger`'s finding, not this one.
			if not description then
				return {}
			end
			local length = countCharacters(description)
			if length <= DESCRIPTION_CHARACTER_LIMIT then
				return {}
			end
			return { `description is {length} characters, over the {DESCRIPTION_CHARACTER_LIMIT}-character limit` }
		end,
	},
	{
		id = "provenance-footer",
		summary = "carries a `## Provenance and Maintenance` footer",
		findViolations = function(_skill, contents)
			if string.find(contents, "\n## Provenance and Maintenance", 1, true) then
				return {}
			end
			return { "no `## Provenance and Maintenance` footer" }
		end,
	},
	{
		id = "date-stamp",
		summary = "the provenance footer carries an ISO date stamp",
		findViolations = function(_skill, contents)
			local isStamped = string.find(contents, "%*%*Date stamped:%*%* %d%d%d%d%-%d%d%-%d%d")
				or string.find(contents, "%*%*Last verified:%*%* %d%d%d%d%-%d%d%-%d%d")
			if isStamped then
				return {}
			end
			return { "no `**Date stamped:** YYYY-MM-DD` or `**Last verified:** YYYY-MM-DD`" }
		end,
	},
	{
		id = "body-length",
		summary = `body within {BODY_LINE_CEILING} lines, on the way down to the 500-line convention`,
		findViolations = function(_skill, contents)
			local length = countLines(getBody(contents))
			if length <= BODY_LINE_CEILING then
				return {}
			end
			return { `body is {length} lines, over the {BODY_LINE_CEILING}-line ceiling` }
		end,
	},
}

local proseRules: { ProseRule } = {
	{
		id = "em-dash",
		summary = "no em dash or spaced double hyphen in prose",
		findViolations = function(file)
			return findAnyMatch(toProse(file.contents), { "—", " %-%- " })
		end,
	},
	{
		id = "source-line-citation",
		summary = "locates source by grep-able anchor, never by line number",
		findViolations = function(file)
			return findMatches(toProse(file.contents), "%f[%a]lines?%s+%d")
		end,
	},
	{
		id = "machine-path",
		summary = "no absolute or home-relative paths, including inside commands",
		findViolations = function(file)
			-- Fences stay in scope, because a command a reader copies is exactly
			-- where a machine-specific prefix does its damage.
			return findAnyMatch(stripInlineCode(file.contents), { "/Users/", "~/git/" })
		end,
	},
	{
		id = "resolvable-links",
		summary = "every relative link resolves to a file in the library",
		findViolations = function(file)
			local violations = {}
			-- Code is dropped, because a link inside a fence or an inline span is
			-- markdown syntax being demonstrated, not a link the reader can follow.
			-- A real link keeps its target outside any span even when its label is
			-- code, so `[`org/x`](../x/SKILL.md)` is still checked.
			for target in string.gmatch(toProse(file.contents), "%]%(([^)]+)%)") do
				-- A leading `/` is a docs-site route rather than a path on disk, so
				-- it resolves against a site this rule knows nothing about.
				local isExternal = string.find(target, "^%a+:")
					or string.find(target, "^#")
					or string.find(target, "^/")
				local withoutAnchor = string.match(target, "^([^#]*)")
				if not isExternal and withoutAnchor and withoutAnchor ~= "" then
					local resolved = path.format(path.normalize(path.join(file.directory, withoutAnchor)))
					if not fs.exists(resolved) then
						table.insert(violations, `link target does not exist: {target}`)
					end
				end
			end
			return violations
		end,
	},
}

local doctrineRules: DoctrineRules = {
	skill = skillRules,
	prose = proseRules,
}

return table.freeze(doctrineRules)
