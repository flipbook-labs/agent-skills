-- The authoring conventions from CONTRIBUTING.md, as checks. Each rule reports
-- every occurrence it finds, so one run gives an author the whole worklist
-- instead of the first failure.
--
-- The library passes all of these today. Two further conventions, the 500-line
-- body ceiling and the `scripts/` drift detector, are not checked yet because
-- most `flipbook/` skills still violate them; they land with the work that
-- makes them pass.

local fs = require("@std/fs")
local path = require("@std/path")

local parseFrontmatter = require("./parseFrontmatter")
local stripInlineCode = require("./stripInlineCode")
local toProse = require("./toProse")
local types = require("./types")

type DoctrineRule = types.DoctrineRule

local Genre = table.freeze({
	Process = "process",
	Knowledge = "knowledge",
})

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
			-- "Use when", and the narrowing forms "Use only when" and "Use this when".
			if description and string.find(description, "Use%s+[%l%s]*when") then
				return {}
			end
			return { 'frontmatter "description" carries no "Use when" trigger' }
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
			-- Fences stay in scope, because a command a reader copies is exactly
			-- where a machine-specific prefix does its damage.
			return findAnyMatch(stripInlineCode(contents), { "/Users/", "~/git/" })
		end,
	},
	{
		id = "resolvable-links",
		summary = "every relative link resolves to a file in the library",
		findViolations = function(skill, contents)
			local violations = {}
			-- Code is dropped, because a link inside a fence or an inline span is
			-- markdown syntax being demonstrated, not a link the reader can follow.
			-- A real link keeps its target outside any span even when its label is
			-- code, so `[`org/x`](../x/SKILL.md)` is still checked.
			for target in string.gmatch(toProse(contents), "%]%(([^)]+)%)") do
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
}

return table.freeze(rules)
