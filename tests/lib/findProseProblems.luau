-- Runs the prose rules over one markdown file, honoring the opt-out markers the
-- file declares.
--
-- An opt-out is checked as hard as the rules it mutes. A marker naming a rule that
-- does not exist, or excusing a violation the file no longer has, fails here: a
-- marker that outlives its violation is a rule switched off for that file with
-- nothing left to notice it.

local doctrineRules = require("./doctrineRules")
local parseExemptions = require("./parseExemptions")
local types = require("./types")

type MarkdownFile = types.MarkdownFile

local function findProseProblems(file: MarkdownFile): { string }
	local exemptions = parseExemptions(file.contents)
	local problems: { string } = table.clone(exemptions.problems)
	local unmatchedRuleIds = table.clone(exemptions.ruleIds)

	for _, rule in doctrineRules.prose do
		local violations = rule.findViolations(file)
		local exemptedAt = table.find(unmatchedRuleIds, rule.id)

		if exemptedAt then
			table.remove(unmatchedRuleIds, exemptedAt)
			if #violations == 0 then
				table.insert(problems, `exempts "{rule.id}" but no longer breaks it, so drop the marker`)
			end
			continue
		end

		for _, violation in violations do
			table.insert(problems, `{rule.id} ({rule.summary}): {violation}`)
		end
	end

	for _, ruleId in unmatchedRuleIds do
		table.insert(problems, `exempts "{ruleId}", which is not a prose rule`)
	end

	return problems
end

return findProseProblems
