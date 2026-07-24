-- Blanks fenced code blocks, keeping line count so reported line numbers still
-- match the file. A fence holds a sample: Luau comment syntax, a markdown link
-- shown as syntax, prose punctuation inside a quoted command.

local function stripFencedCode(text: string): string
	local lines = {}
	local isInFence = false
	for _, line in string.split(text, "\n") do
		if string.match(line, "^%s*```") then
			isInFence = not isInFence
			table.insert(lines, "")
			continue
		end
		table.insert(lines, if isInFence then "" else line)
	end
	return table.concat(lines, "\n")
end

return stripFencedCode
