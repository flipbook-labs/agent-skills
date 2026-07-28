-- Blanks fenced code blocks, keeping line count so reported line numbers still
-- match the file. A fence holds a sample: Luau comment syntax, a markdown link
-- shown as syntax, prose punctuation inside a quoted command.
--
-- A block closes only on the delimiter that opened it, in a run at least as long.
-- A skill that teaches markdown wraps a sample fence in a longer one or in tildes,
-- and the run inside is sample text rather than the end of the block.

local function matchFence(line: string): string?
	return string.match(line, "^%s*(```+)") or string.match(line, "^%s*(~~~+)")
end

local function isClosedBy(openingFence: string, fence: string): boolean
	return string.sub(fence, 1, 1) == string.sub(openingFence, 1, 1) and #fence >= #openingFence
end

local function stripFencedCode(text: string): string
	local lines = {}
	local openingFence: string? = nil
	for _, line in string.split(text, "\n") do
		local fence = matchFence(line)
		if openingFence then
			if fence and isClosedBy(openingFence, fence) then
				openingFence = nil
			end
			table.insert(lines, "")
		elseif fence then
			openingFence = fence
			table.insert(lines, "")
		else
			table.insert(lines, line)
		end
	end
	return table.concat(lines, "\n")
end

return stripFencedCode
