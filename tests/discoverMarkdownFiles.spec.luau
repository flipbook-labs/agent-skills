-- The prose rules only see the files discovery hands them, so discovery that
-- silently found nothing would pass every skill vacuously.

local test = require("@std/test")

local discoverMarkdownFiles = require("./lib/discoverMarkdownFiles")

test.suite("discoverMarkdownFiles", function(suite)
	suite:case("finds SKILL.md and the reference files nested beneath it", function(assert)
		local found = discoverMarkdownFiles("src/org/durable-writing")

		assert.that(table.find(found, "src/org/durable-writing/SKILL.md") ~= nil, "SKILL.md is in scope")
		assert.that(
			table.find(found, "src/org/durable-writing/examples/README.md") ~= nil,
			"so is a file one folder down"
		)
		assert.that(
			table.find(found, "src/org/durable-writing/examples/workflow-pr/4-template-fitted.md") ~= nil,
			"so is a file two folders down"
		)
	end)

	suite:case("returns only markdown, so a skill's drift scripts stay out of scope", function(assert)
		local found = discoverMarkdownFiles("src/flipbook/diagnostics-and-tooling")

		assert.that(#found > 0, "the skill ships at least a SKILL.md")
		for _, filePath in found do
			assert.that(string.match(filePath, "%.md$") ~= nil, `{filePath} is markdown`)
		end
	end)

	suite:case("returns nothing for a directory that is not there", function(assert)
		assert.eq(#discoverMarkdownFiles("src/org/not-a-skill"), 0, "a missing directory is empty, not an error")
	end)
end)
