-- Blanks out fenced code blocks and inline code spans so a prose rule never
-- fires on a sample a skill is deliberately quoting: `org/writing-style` prints
-- the banned `—` character inside backticks to name it. Blanked lines are kept
-- as empty lines rather than dropped, so line numbers still match the file.

local function toProse(contents: string): string
	local lines = {}
	local isInFence = false
	for _, line in string.split(contents, "\n") do
		if string.match(line, "^%s*```") then
			isInFence = not isInFence
			table.insert(lines, "")
			continue
		end
		if isInFence then
			table.insert(lines, "")
			continue
		end
		local withoutSpans = string.gsub(line, "`[^`]*`", "")
		table.insert(lines, withoutSpans)
	end
	return table.concat(lines, "\n")
end

return toProse
