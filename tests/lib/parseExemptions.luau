-- Reads the opt-out markers a markdown file uses to excuse itself from named
-- prose rules, so a file that exists to show bad writing can hold the bad writing
-- verbatim. The marker is an HTML comment, which renders as nothing, and takes
-- the exact form CONTRIBUTING.md specifies:
--
--     <!-- doctrine-exempt rules="em-dash" reason="why this file has to break it" -->
--
-- A marker missing either attribute exempts nothing and is reported instead. The
-- reason is what stops a file being muted silently, so a marker without one has
-- to fail rather than quietly widen to the default of exempting everything.

local MARKER_PATTERN = "<!%-%-%s*doctrine%-exempt(.-)%-%->"

export type Exemptions = {
	ruleIds: { string },
	problems: { string },
}

local function parseAttribute(attributes: string, name: string): string?
	return string.match(attributes, `{name}="([^"]*)"`)
end

local function parseExemptions(contents: string): Exemptions
	local ruleIds: { string } = {}
	local problems: { string } = {}

	for attributes in string.gmatch(contents, MARKER_PATTERN) do
		local named: { string } = {}
		for _, rawId in string.split(parseAttribute(attributes, "rules") or "", ",") do
			local ruleId = string.gsub(rawId, "^%s*(.-)%s*$", "%1")
			if ruleId ~= "" and not table.find(named, ruleId) then
				table.insert(named, ruleId)
			end
		end

		local reason = parseAttribute(attributes, "reason")
		local hasReason = reason ~= nil and string.match(reason, "^%s*$") == nil

		if #named == 0 then
			table.insert(problems, `exemption marker names no rules: <!-- doctrine-exempt{attributes}-->`)
		elseif not hasReason then
			table.insert(
				problems,
				`exemption marker for {table.concat(named, ", ")} states no reason, so it exempts nothing`
			)
		else
			for _, ruleId in named do
				if not table.find(ruleIds, ruleId) then
					table.insert(ruleIds, ruleId)
				end
			end
		end
	end

	return {
		ruleIds = ruleIds,
		problems = problems,
	}
end

return parseExemptions
