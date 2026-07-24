-- Checks every SKILL.md against the authoring conventions in CONTRIBUTING.md,
-- which were previously prose an author had to remember: genre, load trigger,
-- body length, provenance, anchors over line numbers, portable paths, working
-- links, and drift detectors. Pre-existing violations are grandfathered in
-- tests/lib/doctrineBaseline.luau.

local fs = require("@std/fs")
local test = require("@std/test")

local discoverSkills = require("./lib/discoverSkills")
local doctrineBaseline = require("./lib/doctrineBaseline")
local doctrineRules = require("./lib/doctrineRules")

test.suite("skill authoring doctrine", function(suite)
	local skills = discoverSkills()

	for _, skill in skills do
		suite:case(`{skill.id} follows the authoring doctrine`, function(assert)
			local contents = fs.readFileToString(skill.skillPath)
			local allowedCounts = doctrineBaseline[skill.id] or {}
			local problems: { string } = {}

			for _, rule in doctrineRules do
				local violations = rule.findViolations(skill, contents)
				local allowedCount = allowedCounts[rule.id] or 0

				if #violations > allowedCount then
					table.insert(
						problems,
						`{rule.id} ({rule.summary}): found {#violations}, {allowedCount} grandfathered`
					)
					for _, violation in violations do
						table.insert(problems, `    {violation}`)
					end
				elseif #violations < allowedCount then
					table.insert(
						problems,
						`{rule.id}: down to {#violations} from {allowedCount}. Lower it in tests/lib/doctrineBaseline.luau`
					)
				end
			end

			assert.that(#problems == 0, `{skill.id}\n  {table.concat(problems, "\n  ")}`)
		end)
	end

	suite:case("the doctrine baseline names only live skills and rules", function(assert)
		local liveSkills: { [string]: boolean } = {}
		for _, skill in skills do
			liveSkills[skill.id] = true
		end

		local liveRules: { [string]: boolean } = {}
		for _, rule in doctrineRules do
			liveRules[rule.id] = true
		end

		for id, allowedCounts in doctrineBaseline do
			assert.that(liveSkills[id], `{id}: grandfathered in the baseline but no such skill exists`)
			for ruleId, count in allowedCounts do
				assert.that(liveRules[ruleId], `{id}: grandfathers "{ruleId}", which is not a rule`)
				assert.that(count > 0, `{id}: grandfathers "{ruleId}" with a count of {count}; delete the entry instead`)
			end
		end
	end)
end)
