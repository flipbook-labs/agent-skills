-- Exercises each doctrine rule against text that breaks it and text that does
-- not. Without this, a rule that stopped matching would report zero violations
-- for every skill and doctrine.spec.luau would go green on a library it is no
-- longer checking.

local test = require("@std/test")

local doctrineRules = require("./lib/doctrineRules")
local types = require("./lib/types")

type Skill = types.Skill
type DoctrineRule = types.DoctrineRule

local FRONTMATTER = table.concat({
	"---",
	"name: example",
	'description: "Does a thing. Use when: you need the thing."',
	"type: process",
	"---",
	"",
}, "\n")

local PROVENANCE = "\n## Provenance and Maintenance\n\n**Date stamped:** 2026-07-24. Written from a review.\n"

-- Points at a real directory, because `resolvable-links` resolves targets
-- against the skill's own folder on disk.
local SHARED_SKILL: Skill = {
	scope = "org",
	name = "writing-style",
	id = "org/writing-style",
	directory = "src/org/writing-style",
	skillPath = "src/org/writing-style/SKILL.md",
}

local function ruleById(id: string): DoctrineRule
	for _, rule in doctrineRules do
		if rule.id == id then
			return rule
		end
	end
	error(`no doctrine rule named "{id}"`)
end

local function countViolations(ruleId: string, skill: Skill, contents: string): number
	return #ruleById(ruleId).findViolations(skill, contents)
end

test.suite("doctrine rules", function(suite)
	local clean = FRONTMATTER .. "\n# Example\n\nA skill body.\n" .. PROVENANCE

	suite:case("frontmatter-genre rejects a type outside the two genres", function(assert)
		assert.eq(countViolations("frontmatter-genre", SHARED_SKILL, clean), 0, "the fixture declares process")

		local runbook = string.gsub(clean, "type: process", "type: runbook")
		assert.eq(countViolations("frontmatter-genre", SHARED_SKILL, runbook), 1, "runbook is not a genre")

		local missing = string.gsub(clean, "type: process\n", "")
		assert.eq(countViolations("frontmatter-genre", SHARED_SKILL, missing), 1, "a missing type is a violation")
	end)

	suite:case("frontmatter-trigger rejects a description with no load trigger", function(assert)
		assert.eq(countViolations("frontmatter-trigger", SHARED_SKILL, clean), 0, 'the fixture says "Use when"')

		local noTrigger = string.gsub(clean, "Use when: you need the thing.", "It is about things.")
		assert.eq(countViolations("frontmatter-trigger", SHARED_SKILL, noTrigger), 1, "a topic summary is not a trigger")

		local narrowed = string.gsub(clean, "Use when:", "Use only when:")
		assert.eq(countViolations("frontmatter-trigger", SHARED_SKILL, narrowed), 0, "a narrowing form still triggers")
	end)

	suite:case("provenance-footer rejects a skill that ends without one", function(assert)
		assert.eq(countViolations("provenance-footer", SHARED_SKILL, clean), 0, "the fixture carries a footer")

		local footerless = FRONTMATTER .. "\n# Example\n\nA skill body.\n"
		assert.eq(countViolations("provenance-footer", SHARED_SKILL, footerless), 1, "no footer heading")
	end)

	suite:case("date-stamp accepts either footer label and rejects a bare date", function(assert)
		assert.eq(countViolations("date-stamp", SHARED_SKILL, clean), 0, "**Date stamped:** with an ISO date")

		local verified = string.gsub(clean, "%*%*Date stamped:%*%*", "**Last verified:**")
		assert.eq(countViolations("date-stamp", SHARED_SKILL, verified), 0, "**Last verified:** is the other label")

		local bare = string.gsub(clean, "%*%*Date stamped:%*%* ", "Date: ")
		assert.eq(countViolations("date-stamp", SHARED_SKILL, bare), 1, "an unlabelled date does not count")
	end)

	suite:case("em-dash catches both spellings and spares a quoted sample", function(assert)
		assert.eq(countViolations("em-dash", SHARED_SKILL, clean), 0, "the fixture has neither")

		local dashed = clean .. "\nThe sink buffers to disk — then replays on reconnect.\n"
		assert.eq(countViolations("em-dash", SHARED_SKILL, dashed), 1, "an em dash in prose")

		local hyphenated = clean .. "\nThe test runs fast -- most of the time.\n"
		assert.eq(countViolations("em-dash", SHARED_SKILL, hyphenated), 1, "a spaced double hyphen stands in for one")

		local quoted = clean .. "\nThe rule covers the `—` character and the `--` substitute.\n"
		assert.eq(countViolations("em-dash", SHARED_SKILL, quoted), 0, "an inline code span names the banned char")

		local fenced = clean .. "\n```luau\nlocal x = 1 -- a comment\n```\n"
		assert.eq(countViolations("em-dash", SHARED_SKILL, fenced), 0, "Luau comment syntax is not punctuation")
	end)

	suite:case("source-line-citation catches a line-number pointer into source", function(assert)
		assert.eq(countViolations("source-line-citation", SHARED_SKILL, clean), 0, "the fixture cites nothing")

		local cited = clean .. "\nSee the guard in build.luau at lines 100 to 105.\n"
		assert.eq(countViolations("source-line-citation", SHARED_SKILL, cited), 1, "a line range is a pointer")

		local singular = clean .. "\nThe check is on line 42 of the script.\n"
		assert.eq(countViolations("source-line-citation", SHARED_SKILL, singular), 1, "so is a single line")

		local anchored = clean .. "\nSee the guard in build.luau, grep for BASE_URL.\n"
		assert.eq(countViolations("source-line-citation", SHARED_SKILL, anchored), 0, "an anchor is the right form")

		local guideline = clean .. "\nThe repo has 3 guidelines 2 of which are new.\n"
		assert.eq(countViolations("source-line-citation", SHARED_SKILL, guideline), 0, '"guidelines" is not "lines"')
	end)

	suite:case("machine-path catches home and absolute paths inside commands", function(assert)
		assert.eq(countViolations("machine-path", SHARED_SKILL, clean), 0, "the fixture has no paths")

		local absolute = clean .. "\n```bash\ncd /Users/you/git/flipbook\n```\n"
		assert.eq(countViolations("machine-path", SHARED_SKILL, absolute), 1, "a fenced command still counts")

		local home = clean .. "\nCheck out the siblings as ~/git/storyteller.\n"
		assert.eq(countViolations("machine-path", SHARED_SKILL, home), 1, "a home-relative clone path counts")

		local store = clean .. "\nThe package installs to ~/.loom/store/AgentSkills@v1/.\n"
		assert.eq(countViolations("machine-path", SHARED_SKILL, store), 0, "the store path is the documented location")

		local named = clean .. "\nThe symptom is a path starting with `/Users/` reaching darklua.\n"
		assert.eq(countViolations("machine-path", SHARED_SKILL, named), 0, "an inline span names the prefix")
	end)

	suite:case("resolvable-links checks relative targets and skips external ones", function(assert)
		local sibling = clean .. "\nSee [code comments](../code-comments/SKILL.md).\n"
		assert.eq(countViolations("resolvable-links", SHARED_SKILL, sibling), 0, "the sibling skill exists")

		local renamed = clean .. "\nSee [the old name](../comment-style/SKILL.md).\n"
		assert.eq(countViolations("resolvable-links", SHARED_SKILL, renamed), 1, "a renamed sibling no longer resolves")

		local offsite = clean .. "\nSee [the docs](https://example.com) and [the route](/docs/stories).\n"
		assert.eq(countViolations("resolvable-links", SHARED_SKILL, offsite), 0, "neither resolves against the disk")

		local demonstrated = clean .. "\n```markdown\nWrite a link as [label](path).\n```\n"
		assert.eq(countViolations("resolvable-links", SHARED_SKILL, demonstrated), 0, "a fenced link is syntax")

		local spanned = clean .. "\nEmbed an image with `![alt](path)` and real alt text.\n"
		assert.eq(countViolations("resolvable-links", SHARED_SKILL, spanned), 0, "so is one in an inline span")

		local codeLabel = clean .. "\nSee [`org/code-comments`](../code-comments/SKILL.md) for the bar.\n"
		assert.eq(countViolations("resolvable-links", SHARED_SKILL, codeLabel), 0, "a code label keeps the link checked")

		local codeLabelBroken = clean .. "\nSee [`org/gone`](../gone/SKILL.md) for the bar.\n"
		assert.eq(countViolations("resolvable-links", SHARED_SKILL, codeLabelBroken), 1, "and still catches it broken")
	end)
end)
