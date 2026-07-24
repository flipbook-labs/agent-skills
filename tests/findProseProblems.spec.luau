-- Specifies the opt-out marker: what mutes a rule, what does not, and how a
-- marker that has gone stale fails. A marker that silently widened, or that kept
-- muting a rule after the file stopped breaking it, would switch a rule off for
-- that file with nothing to notice it.

local test = require("@std/test")

local findProseProblems = require("./lib/findProseProblems")
local types = require("./lib/types")

type Skill = types.Skill

local SKILL: Skill = {
	scope = "org",
	name = "writing-style",
	id = "org/writing-style",
	directory = "src/org/writing-style",
	skillPath = "src/org/writing-style/SKILL.md",
}

local EM_DASH_PROSE = "A draft that reads like a diff — every hunk gets its own sentence.\n"
local MACHINE_PATH_PROSE = "Then run the build from /Users/you/git/flipbook.\n"

local function findProblems(contents: string): { string }
	return findProseProblems({
		skill = SKILL,
		filePath = `{SKILL.directory}/example.md`,
		directory = SKILL.directory,
		contents = contents,
	})
end

local function countMentioning(problems: { string }, needle: string): number
	local count = 0
	for _, problem in problems do
		if string.find(problem, needle, 1, true) then
			count += 1
		end
	end
	return count
end

test.suite("prose problems and their opt-out markers", function(suite)
	suite:case("reports a prose violation in a file that claims no exemption", function(assert)
		local problems = findProblems(EM_DASH_PROSE)

		assert.eq(#problems, 1, "the em dash is the one problem")
		assert.eq(countMentioning(problems, "em-dash"), 1, "and the report names the rule that fired")
	end)

	suite:case("a marker with a reason mutes the rule it names", function(assert)
		local exempted = '<!-- doctrine-exempt rules="em-dash" reason="Reproduced verbatim as the bad example." -->\n'
			.. EM_DASH_PROSE

		assert.eq(#findProblems(exempted), 0, "the file declares why it has to break the rule")
	end)

	suite:case("a marker leaves the rules it does not name checking the file", function(assert)
		local exempted = '<!-- doctrine-exempt rules="em-dash" reason="Reproduced verbatim as the bad example." -->\n'
			.. EM_DASH_PROSE
			.. MACHINE_PATH_PROSE

		local problems = findProblems(exempted)
		assert.eq(#problems, 1, "the unexempted rule still fires")
		assert.eq(countMentioning(problems, "machine-path"), 1, "and it is the one the marker left alone")
	end)

	suite:case("a marker exempting several rules mutes each of them", function(assert)
		local exempted = '<!-- doctrine-exempt rules="em-dash, machine-path" reason="A verbatim bad example." -->\n'
			.. EM_DASH_PROSE
			.. MACHINE_PATH_PROSE

		assert.eq(#findProblems(exempted), 0, "both named rules are muted")
	end)

	suite:case("a marker that states no reason exempts nothing and is reported", function(assert)
		local reasonless = '<!-- doctrine-exempt rules="em-dash" -->\n' .. EM_DASH_PROSE

		local problems = findProblems(reasonless)
		assert.eq(#problems, 2, "the unmuted violation and the marker that failed to mute it")
		assert.eq(countMentioning(problems, "states no reason"), 1, "the marker is called out")
		assert.eq(countMentioning(problems, "em-dash ("), 1, "and the violation is still reported")
	end)

	suite:case("an empty reason does not count as a reason", function(assert)
		local blank = '<!-- doctrine-exempt rules="em-dash" reason="   " -->\n' .. EM_DASH_PROSE

		assert.eq(countMentioning(findProblems(blank), "states no reason"), 1, "whitespace is not a stated reason")
	end)

	suite:case("a marker that names no rules is reported", function(assert)
		local unnamed = '<!-- doctrine-exempt reason="This file is a bad example." -->\n' .. EM_DASH_PROSE

		local problems = findProblems(unnamed)
		assert.eq(countMentioning(problems, "names no rules"), 1, "an exemption has to say what it exempts")
		assert.eq(countMentioning(problems, "em-dash ("), 1, "so the violation is still reported")
	end)

	suite:case("an exemption for a rule that does not exist fails", function(assert)
		local misspelled = '<!-- doctrine-exempt rules="em-dashes" reason="A verbatim bad example." -->\n'
			.. EM_DASH_PROSE

		local problems = findProblems(misspelled)
		assert.eq(countMentioning(problems, 'exempts "em-dashes", which is not a prose rule'), 1, "the id is unknown")
		assert.eq(countMentioning(problems, "em-dash ("), 1, "and the real rule still fires")
	end)

	suite:case("an exemption for a rule the file no longer breaks fails", function(assert)
		local stale = '<!-- doctrine-exempt rules="em-dash" reason="A verbatim bad example." -->\n'
			.. "A draft that reads like a diff, one sentence per hunk.\n"

		local problems = findProblems(stale)
		assert.eq(#problems, 1, "the stale marker is the one problem")
		assert.eq(countMentioning(problems, "no longer breaks it"), 1, "an exemption with nothing to excuse is dead")
	end)
end)
