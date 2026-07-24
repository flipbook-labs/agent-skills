-- Exercises each doctrine rule against text that breaks it and text that does
-- not. Without this, a rule that stopped matching would report zero violations
-- for every skill and doctrine.spec.luau would go green on a library it is no
-- longer checking.

local path = require("@std/path")
local test = require("@std/test")

local doctrineRules = require("./lib/doctrineRules")
local types = require("./lib/types")

type Skill = types.Skill

local FRONTMATTER = table.concat({
	"---",
	"name: example",
	'description: "Does a thing. Use when: you need the thing."',
	"type: process",
	"---",
	"",
}, "\n")

local PROVENANCE = "\n## Provenance and Maintenance\n\n**Date stamped:** 2026-07-24. Written from a review.\n"

-- Both directories are real, because `resolvable-links` resolves targets against
-- the folder holding the file it is checking.
local SKILL_DIRECTORY = "src/org/writing-style"
local NESTED_DIRECTORY = "src/org/durable-writing/examples/workflow-pr"

local SHARED_SKILL: Skill = {
	scope = "org",
	name = "writing-style",
	id = "org/writing-style",
	directory = SKILL_DIRECTORY,
	skillPath = `{SKILL_DIRECTORY}/SKILL.md`,
}

local function withFrontmatter(name: string, description: string): string
	return table.concat({
		"---",
		`name: {name}`,
		`description: "{description}"`,
		"type: process",
		"---",
		"",
	}, "\n")
end

local function withName(name: string): string
	return withFrontmatter(name, "Does a thing. Use when: you need the thing.")
end

local function withDescription(description: string): string
	return withFrontmatter("example", description)
end

local function countSkillViolations(ruleId: string, contents: string): number
	for _, rule in doctrineRules.skill do
		if rule.id == ruleId then
			return #rule.findViolations(SHARED_SKILL, contents)
		end
	end
	error(`no skill rule named "{ruleId}"`)
end

local function countProseViolations(ruleId: string, directory: string, contents: string): number
	for _, rule in doctrineRules.prose do
		if rule.id == ruleId then
			return #rule.findViolations({
				skill = SHARED_SKILL,
				filePath = path.format(path.join(directory, "example.md")),
				directory = directory,
				contents = contents,
			})
		end
	end
	error(`no prose rule named "{ruleId}"`)
end

test.suite("doctrine rules", function(suite)
	local clean = FRONTMATTER .. "\n# Example\n\nA skill body.\n" .. PROVENANCE

	suite:case("frontmatter-genre rejects a type outside the two genres", function(assert)
		assert.eq(countSkillViolations("frontmatter-genre", clean), 0, "the fixture declares process")

		local runbook = string.gsub(clean, "type: process", "type: runbook")
		assert.eq(countSkillViolations("frontmatter-genre", runbook), 1, "runbook is not a genre")

		local missing = string.gsub(clean, "type: process\n", "")
		assert.eq(countSkillViolations("frontmatter-genre", missing), 1, "a missing type is a violation")
	end)

	suite:case("frontmatter-trigger rejects a description with no load trigger", function(assert)
		assert.eq(countSkillViolations("frontmatter-trigger", clean), 0, 'the fixture says "Use when"')

		local noTrigger = string.gsub(clean, "Use when: you need the thing.", "It is about things.")
		assert.eq(countSkillViolations("frontmatter-trigger", noTrigger), 1, "a topic summary is not a trigger")

		local narrowed = string.gsub(clean, "Use when:", "Use only when:")
		assert.eq(countSkillViolations("frontmatter-trigger", narrowed), 0, "a narrowing form still triggers")
	end)

	suite:case("name-format accepts kebab-case and names the constraint that broke", function(assert)
		assert.eq(countSkillViolations("name-format", clean), 0, '"example" is kebab-case')
		assert.eq(countSkillViolations("name-format", withName("write-luau-code")), 0, "so are hyphenated segments")
		assert.eq(countSkillViolations("name-format", withName("use-udim2-v3")), 0, "digits inside a segment are fine")

		assert.eq(countSkillViolations("name-format", withName("Write-Luau-Code")), 1, "an uppercase letter is not")
		assert.eq(countSkillViolations("name-format", withName("write_luau_code")), 1, "an underscore is not")
		assert.eq(countSkillViolations("name-format", withName("write luau code")), 1, "a space is not")
		assert.eq(countSkillViolations("name-format", withName("-leading-hyphen")), 1, "a leading hyphen is not")
		assert.eq(countSkillViolations("name-format", withName("trailing-hyphen-")), 1, "a trailing hyphen is not")
		assert.eq(countSkillViolations("name-format", withName("double--hyphen")), 1, "a double hyphen is not")
		assert.eq(countSkillViolations("name-format", withName("")), 1, "and an empty name is not a name")

		assert.eq(countSkillViolations("name-format", withName("-Bad-")), 3, "each broken constraint is reported")
	end)

	suite:case("name-length holds the 64-character limit exactly", function(assert)
		assert.eq(countSkillViolations("name-length", clean), 0, "the fixture name is short")

		local atLimit = withName(string.rep("a", 64))
		assert.eq(countSkillViolations("name-length", atLimit), 0, "exactly 64 characters fits")

		local overLimit = withName(string.rep("a", 65))
		assert.eq(countSkillViolations("name-length", overLimit), 1, "65 does not")
	end)

	suite:case("description-length holds the 1024-character limit exactly", function(assert)
		assert.eq(countSkillViolations("description-length", clean), 0, "the fixture is one short sentence")

		local atLimit = withDescription(string.rep("a", 1024))
		assert.eq(countSkillViolations("description-length", atLimit), 0, "exactly 1024 characters loads")

		local overLimit = withDescription(string.rep("a", 1025))
		assert.eq(countSkillViolations("description-length", overLimit), 1, "1025 does not")

		local multibyte = withDescription(string.rep("→", 1024))
		assert.eq(countSkillViolations("description-length", multibyte), 0, "the limit counts characters, not bytes")

		local missing = string.gsub(clean, 'description: "[^"]*"\n', "")
		assert.eq(
			countSkillViolations("description-length", missing),
			0,
			"a missing description is another rule's finding"
		)
	end)

	suite:case("provenance-footer rejects a skill that ends without one", function(assert)
		assert.eq(countSkillViolations("provenance-footer", clean), 0, "the fixture carries a footer")

		local footerless = FRONTMATTER .. "\n# Example\n\nA skill body.\n"
		assert.eq(countSkillViolations("provenance-footer", footerless), 1, "no footer heading")
	end)

	suite:case("date-stamp accepts either footer label and rejects a bare date", function(assert)
		assert.eq(countSkillViolations("date-stamp", clean), 0, "**Date stamped:** with an ISO date")

		local verified = string.gsub(clean, "%*%*Date stamped:%*%*", "**Last verified:**")
		assert.eq(countSkillViolations("date-stamp", verified), 0, "**Last verified:** is the other label")

		local bare = string.gsub(clean, "%*%*Date stamped:%*%* ", "Date: ")
		assert.eq(countSkillViolations("date-stamp", bare), 1, "an unlabelled date does not count")
	end)

	suite:case("body-length counts the body and leaves the frontmatter out of it", function(assert)
		assert.eq(countSkillViolations("body-length", clean), 0, "the fixture is a handful of lines")

		local atCeiling = FRONTMATTER .. string.rep("A line of body.\n", 1150)
		assert.eq(countSkillViolations("body-length", atCeiling), 0, "1150 body lines plus frontmatter fits")

		local overCeiling = FRONTMATTER .. string.rep("A line of body.\n", 1151)
		assert.eq(countSkillViolations("body-length", overCeiling), 1, "one line past the ceiling fails")

		local unfenced = string.rep("A line of body.\n", 1151)
		assert.eq(countSkillViolations("body-length", unfenced), 1, "a skill with no frontmatter is all body")
	end)

	suite:case("em-dash catches both spellings and spares a quoted sample", function(assert)
		assert.eq(countProseViolations("em-dash", SKILL_DIRECTORY, clean), 0, "the fixture has neither")

		local dashed = clean .. "\nThe sink buffers to disk — then replays on reconnect.\n"
		assert.eq(countProseViolations("em-dash", SKILL_DIRECTORY, dashed), 1, "an em dash in prose")

		local hyphenated = clean .. "\nThe test runs fast -- most of the time.\n"
		assert.eq(
			countProseViolations("em-dash", SKILL_DIRECTORY, hyphenated),
			1,
			"a spaced double hyphen stands in for one"
		)

		local quoted = clean .. "\nThe rule covers the `—` character and the `--` substitute.\n"
		assert.eq(countProseViolations("em-dash", SKILL_DIRECTORY, quoted), 0, "an inline code span names the char")

		local fenced = clean .. "\n```luau\nlocal x = 1 -- a comment\n```\n"
		assert.eq(countProseViolations("em-dash", SKILL_DIRECTORY, fenced), 0, "Luau comment syntax is not punctuation")
	end)

	suite:case("source-line-citation catches a line-number pointer into source", function(assert)
		assert.eq(countProseViolations("source-line-citation", SKILL_DIRECTORY, clean), 0, "the fixture cites nothing")

		local cited = clean .. "\nSee the guard in build.luau at lines 100 to 105.\n"
		assert.eq(countProseViolations("source-line-citation", SKILL_DIRECTORY, cited), 1, "a line range is a pointer")

		local singular = clean .. "\nThe check is on line 42 of the script.\n"
		assert.eq(countProseViolations("source-line-citation", SKILL_DIRECTORY, singular), 1, "so is a single line")

		local anchored = clean .. "\nSee the guard in build.luau, grep for BASE_URL.\n"
		assert.eq(
			countProseViolations("source-line-citation", SKILL_DIRECTORY, anchored),
			0,
			"an anchor is the right form"
		)

		local guideline = clean .. "\nThe repo has 3 guidelines 2 of which are new.\n"
		assert.eq(
			countProseViolations("source-line-citation", SKILL_DIRECTORY, guideline),
			0,
			'"guidelines" is not "lines"'
		)
	end)

	suite:case("machine-path catches home and absolute paths inside commands", function(assert)
		assert.eq(countProseViolations("machine-path", SKILL_DIRECTORY, clean), 0, "the fixture has no paths")

		local absolute = clean .. "\n```bash\ncd /Users/you/git/flipbook\n```\n"
		assert.eq(countProseViolations("machine-path", SKILL_DIRECTORY, absolute), 1, "a fenced command still counts")

		local home = clean .. "\nCheck out the siblings as ~/git/storyteller.\n"
		assert.eq(countProseViolations("machine-path", SKILL_DIRECTORY, home), 1, "a home-relative clone path counts")

		local store = clean .. "\nThe package installs to ~/.loom/store/AgentSkills@v1/.\n"
		assert.eq(countProseViolations("machine-path", SKILL_DIRECTORY, store), 0, "the store path is documented")

		local named = clean .. "\nThe symptom is a path starting with `/Users/` reaching darklua.\n"
		assert.eq(countProseViolations("machine-path", SKILL_DIRECTORY, named), 0, "an inline span names the prefix")
	end)

	suite:case("resolvable-links checks relative targets and skips external ones", function(assert)
		local sibling = clean .. "\nSee [code comments](../code-comments/SKILL.md).\n"
		assert.eq(countProseViolations("resolvable-links", SKILL_DIRECTORY, sibling), 0, "the sibling skill exists")

		local renamed = clean .. "\nSee [the old name](../comment-style/SKILL.md).\n"
		assert.eq(
			countProseViolations("resolvable-links", SKILL_DIRECTORY, renamed),
			1,
			"a renamed sibling no longer resolves"
		)

		local offsite = clean .. "\nSee [the docs](https://example.com) and [the route](/docs/stories).\n"
		assert.eq(
			countProseViolations("resolvable-links", SKILL_DIRECTORY, offsite),
			0,
			"neither resolves against the disk"
		)

		local demonstrated = clean .. "\n```markdown\nWrite a link as [label](path).\n```\n"
		assert.eq(countProseViolations("resolvable-links", SKILL_DIRECTORY, demonstrated), 0, "a fenced link is syntax")

		local spanned = clean .. "\nEmbed an image with `![alt](path)` and real alt text.\n"
		assert.eq(countProseViolations("resolvable-links", SKILL_DIRECTORY, spanned), 0, "so is one in an inline span")

		local codeLabel = clean .. "\nSee [`org/code-comments`](../code-comments/SKILL.md) for the bar.\n"
		assert.eq(
			countProseViolations("resolvable-links", SKILL_DIRECTORY, codeLabel),
			0,
			"a code label keeps the link checked"
		)

		local codeLabelBroken = clean .. "\nSee [`org/gone`](../gone/SKILL.md) for the bar.\n"
		assert.eq(
			countProseViolations("resolvable-links", SKILL_DIRECTORY, codeLabelBroken),
			1,
			"and still catches it broken"
		)
	end)

	suite:case("resolvable-links resolves against the folder holding the file", function(assert)
		local draft = clean .. "\nSee [the default draft](1-default.md).\n"
		assert.eq(
			countProseViolations("resolvable-links", NESTED_DIRECTORY, draft),
			0,
			"the draft sits beside a file in the examples folder"
		)
		assert.eq(
			countProseViolations("resolvable-links", SKILL_DIRECTORY, draft),
			1,
			"and the same link does not resolve from a skill root"
		)
	end)
end)
