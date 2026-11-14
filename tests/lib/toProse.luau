-- The text a prose rule should judge: neither a fenced sample nor an inline
-- token the skill is naming rather than using. `org/writing-style` prints the
-- banned `—` character inside backticks, and that must not trip the em-dash
-- rule. Line count is preserved so reported line numbers match the file.

local stripFencedCode = require("./stripFencedCode")
local stripInlineCode = require("./stripInlineCode")

local function toProse(contents: string): string
	return stripInlineCode(stripFencedCode(contents))
end

return toProse
