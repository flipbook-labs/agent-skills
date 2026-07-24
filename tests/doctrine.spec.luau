-- Checks every skill against the authoring conventions in CONTRIBUTING.md, which
-- an author would otherwise have to remember: genre, load trigger, provenance, body
-- length, anchors over line numbers, portable paths, and working links. The prose
-- half runs over every markdown file a skill ships, not only `SKILL.md`, since a
-- reader follows a link into a reference file and reads it the same way.

local fs = require("@std/fs")
local path = require("@std/path")
local test = require("@std/test")

local discoverMarkdownFiles = require("./lib/discoverMarkdownFiles")
local discoverSkills = require("./lib/discoverSkills")
local doctrineRules = require("./lib/doctrineRules")
local findProseProblems = require("./lib/findProseProblems")
local types = require("./lib/types")

type MarkdownFile = types.MarkdownFile
type Skill = types.Skill

local function findSkillProblems(skill: Skill): { string }
	local problems: { string } = {}
	local contents = fs.readFileToString(skill.skillPath)

	for _, rule in doctrineRules.skill do
		for _, violation in rule.findViolations(skill, contents) do
			table.insert(problems, `{skill.skillPath}: {rule.id} ({rule.summary}): {violation}`)
		end
	end

	for _, filePath in discoverMarkdownFiles(skill.directory) do
		local file: MarkdownFile = {
			skill = skill,
			filePath = filePath,
			directory = path.format(path.dirname(filePath)),
			contents = fs.readFileToString(filePath),
		}
		for _, problem in findProseProblems(file) do
			table.insert(problems, `{filePath}: {problem}`)
		end
	end

	return problems
end

test.suite("skill authoring doctrine", function(suite)
	for _, skill in discoverSkills() do
		suite:case(`{skill.id} follows the authoring doctrine`, function(assert)
			local problems = findSkillProblems(skill)
			assert.that(#problems == 0, `{skill.id}\n  {table.concat(problems, "\n  ")}`)
		end)
	end
end)
