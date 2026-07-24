-- Parse the leading `---` … `---` frontmatter block into flat key/value pairs.
-- Only simple scalar keys (name/description/type) are emitted, which is all the
-- doctrine requires; nested YAML is not used in SKILL.md frontmatter.

local function parseFrontmatter(contents: string): { [string]: string }?
	local normalized = string.gsub(contents, "\r\n", "\n")
	local block = string.match(normalized, "^%-%-%-\n(.-)\n%-%-%-")
	if not block then
		return nil
	end
	local fields: { [string]: string } = {}
	for _, line in string.split(block, "\n") do
		local key, value = string.match(line, "^([%w_%-]+):%s*(.*)$")
		if key and value then
			local unquoted = string.gsub(value, '^"(.*)"$', "%1")
			unquoted = string.gsub(unquoted, "^'(.*)'$", "%1")
			fields[key] = unquoted
		end
	end
	return fields
end

return parseFrontmatter
