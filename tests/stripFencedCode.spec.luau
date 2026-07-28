-- Specifies which lines a prose rule gets to judge. Every prose rule reads the
-- stripped text, so a block that ends in the wrong place silently moves the
-- boundary between a sample and the writing around it: a rule stops firing on
-- prose it should cover, or fires on a sample it should ignore, and the suite
-- stays green either way.

local test = require("@std/test")

local stripFencedCode = require("./lib/stripFencedCode")

local SAMPLE = "a line only a sample would hold"
local PROSE = "a line the rules should judge"

local function countLines(text: string): number
	return #string.split(text, "\n")
end

local function isKept(prose: string, line: string): boolean
	return string.find(prose, line, 1, true) ~= nil
end

test.suite("stripping fenced code", function(suite)
	suite:case("blanks a fenced block and leaves the prose around it", function(assert)
		local text = `Before.\n\`\`\`luau\n{SAMPLE}\n\`\`\`\nAfter.`

		assert.eq(stripFencedCode(text), "Before.\n\n\n\nAfter.", "the fence and its contents go, the prose stays")
	end)

	suite:case("keeps the line count so a reported line number matches the file", function(assert)
		local text = `One.\n\`\`\`\ntwo\nthree\n\`\`\`\nfour\n`

		assert.eq(countLines(stripFencedCode(text)), countLines(text), "every later line keeps its position")
	end)

	suite:case("a longer backtick fence holds a shorter one without ending the block", function(assert)
		local text = `\`\`\`\`\n\`\`\`code-sample\n{SAMPLE}\n\`\`\`\n\`\`\`\`\n{PROSE}`

		local prose = stripFencedCode(text)
		assert.that(not isKept(prose, SAMPLE), "the wrapped fence is sample text, not the end of the block")
		assert.that(isKept(prose, PROSE), "and the block ends on the run that opened it")
	end)

	suite:case("a tilde fence blanks the sample it holds", function(assert)
		local text = `Before.\n~~~\n{SAMPLE}\n~~~\n{PROSE}`

		local prose = stripFencedCode(text)
		assert.that(not isKept(prose, SAMPLE), "a tilde run opens a block the same way a backtick run does")
		assert.that(isKept(prose, PROSE), "and a matching tilde run closes it")
	end)

	suite:case("a block does not close on the delimiter it did not open with", function(assert)
		local text = `\`\`\`\n~~~\n{SAMPLE}\n\`\`\`\n{PROSE}`

		local prose = stripFencedCode(text)
		assert.that(not isKept(prose, SAMPLE), "a tilde run cannot close a backtick block")
		assert.that(isKept(prose, PROSE), "only a backtick run can")
	end)

	suite:case("an unclosed fence blanks the rest of the file", function(assert)
		local text = `Before.\n\`\`\`\n{SAMPLE}`

		local prose = stripFencedCode(text)
		assert.that(not isKept(prose, SAMPLE), "nothing reopens prose after a fence nobody closed")
		assert.that(isKept(prose, "Before."), "and what came before it is untouched")
	end)
end)
