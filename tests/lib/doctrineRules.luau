-- The authoring conventions from CONTRIBUTING.md, as checks. Each rule reports
-- every occurrence it finds; tests/doctrine.spec.luau compares those counts
-- against the grandfathered baseline.

local fs = require("@std/fs")
local path = require("@std/path")

local parseFrontmatter = require("./parseFrontmatter")
local toProse = require("./toProse")
local types = require("./types")

type Skill = types.Skill
type DoctrineRule = types.DoctrineRule

local Genre = table.freeze({
	Process = "process",
	Knowledge = "knowledge",
})

-- Scopes whose skills describe the org rather than one repo, so they carry no
-- anchors that can drift and nothing for a drift detector to check.
local SHARED_SCOPES = table.freeze({
	org = true,
	family = true,
})

-- A body past this gets skimmed rather than read, and it is the ceiling the
-- agent vendors' own skill-authoring guidance names. Detail beyond it goes in a
-- sibling file the skill links to.
local MAX_BODY_LINES = 500

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

local rules: { DoctrineRule } = {
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
			if description and string.find(description, "Use when", 1, true) then
				return {}
			end
			return { 'frontmatter "description" carries no "Use when" trigger' }
		end,
	},
	{
		id = "body-length",
		summary = `body stays within {MAX_BODY_LINES} lines`,
		findViolations = function(_skill, contents)
			local body = string.match(contents, "^%-%-%-\n.-\n%-%-%-\n(.*)$") or contents
			local lineCount = #string.split(body, "\n")
			if lineCount <= MAX_BODY_LINES then
				return {}
			end
			return { `body is {lineCount} lines, over the {MAX_BODY_LINES}-line ceiling` }
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
		id = "em-dash",
		summary = "no em dash or spaced double hyphen in prose",
		findViolations = function(_skill, contents)
			return findAnyMatch(toProse(contents), { "—", " %-%- " })
		end,
	},
	{
		id = "source-line-citation",
		summary = "locates source by grep-able anchor, never by line number",
		findViolations = function(_skill, contents)
			return findMatches(toProse(contents), "%f[%a]lines?%s+%d")
		end,
	},
	{
		id = "machine-path",
		summary = "no absolute or home-relative paths, including inside commands",
		findViolations = function(_skill, contents)
			return findAnyMatch(contents, { "/Users/", "~/git/" })
		end,
	},
	{
		id = "resolvable-links",
		summary = "every relative link resolves to a file in the library",
		findViolations = function(skill, contents)
			local violations = {}
			for target in string.gmatch(contents, "%]%(([^)]+)%)") do
				-- A leading `/` is a docs-site route rather than a path on disk, so
				-- it resolves against a site this rule knows nothing about.
				local isExternal = string.find(target, "^%a+:")
					or string.find(target, "^#")
					or string.find(target, "^/")
				local withoutAnchor = string.match(target, "^([^#]*)")
				if not isExternal and withoutAnchor and withoutAnchor ~= "" then
					local resolved = path.format(path.normalize(path.join(skill.directory, withoutAnchor)))
					if not fs.exists(resolved) then
						table.insert(violations, `link target does not exist: {target}`)
					end
				end
			end
			return violations
		end,
	},
	{
		id = "drift-script",
		summary = "a single-repo skill ships a `scripts/` drift detector",
		findViolations = function(skill, _contents)
			if SHARED_SCOPES[skill.scope] then
				return {}
			end
			if fs.exists(path.format(path.join(skill.directory, "scripts"))) then
				return {}
			end
			return { "no `scripts/` drift detector for a skill whose anchors point into another repo" }
		end,
	},
}

return table.freeze(rules)
