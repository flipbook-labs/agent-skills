-- Parse the leading `---` … `---` frontmatter block into flat key/value pairs.
-- Only simple scalar keys (name/description/type) are emitted, which is all the
-- doctrine requires; nested YAML is not used in SKILL.md frontmatter.

local function parseFrontmatter(contents: string): { [string]: string }?
	local normalized = contents:gsub("\r\n", "\n")
	local block = normalized:match("^%-%-%-\n(.-)\n%-%-%-")
	if not block then
		return nil
	end
	local fields: { [string]: string } = {}
	for _, line in block:split("\n") do
		local key, value = line:match("^([%w_%-]+):%s*(.*)$")
		if key and value then
			local unquoted = value:gsub('^"(.*)"$', "%1")
			unquoted = unquoted:gsub("^'(.*)'$", "%1")
			fields[key] = unquoted
		end
	end
	return fields
end

return parseFrontmatter
