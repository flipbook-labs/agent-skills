-- Blanks inline code spans, keeping line count so reported line numbers still
-- match the file. Inline code names a token rather than instructing the reader,
-- so a skill can mention `/Users/` or `—` to talk about it without using it.

local function stripInlineCode(text: string): string
	local lines = {}
	for _, line in string.split(text, "\n") do
		local stripped = string.gsub(line, "`[^`]*`", "")
		table.insert(lines, stripped)
	end
	return table.concat(lines, "\n")
end

return stripInlineCode
