-- Checks every SKILL.md against the authoring conventions in CONTRIBUTING.md,
-- which were previously prose an author had to remember: genre, load trigger,
-- provenance, anchors over line numbers, portable paths, and working links.

local fs = require("@std/fs")
local test = require("@std/test")

local discoverSkills = require("./lib/discoverSkills")
local doctrineRules = require("./lib/doctrineRules")

test.suite("skill authoring doctrine", function(suite)
	for _, skill in discoverSkills() do
		suite:case(`{skill.id} follows the authoring doctrine`, function(assert)
			local contents = fs.readFileToString(skill.skillPath)
			local problems: { string } = {}

			for _, rule in doctrineRules do
				local violations = rule.findViolations(skill, contents)
				if #violations > 0 then
					table.insert(problems, `{rule.id} ({rule.summary}):`)
					for _, violation in violations do
						table.insert(problems, `    {violation}`)
					end
				end
			end

			assert.that(#problems == 0, `{skill.id}\n  {table.concat(problems, "\n  ")}`)
		end)
	end
end)
