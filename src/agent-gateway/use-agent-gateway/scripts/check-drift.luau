-- Drift detector for agent-gateway/use-agent-gateway.
--
-- This skill documents the "discoverable and self-describing gateways" design in
-- agent-gateway PR #13 (branch `agent-discoverability`), which is not yet merged.
-- So the checks run against that ref via `git show`, not the working tree (main
-- does not have this design yet). When PR #13 merges, re-point REF to origin/main
-- or the release tag. Skips cleanly when the sibling repo or the ref is absent.
--
-- Run with `lute` from the hub repo root.

local fs = require("@std/fs")
local process = require("@std/process")

type Check = { file: string, needle: string, desc: string }

local REPO = "../agent-gateway"
local REF = "origin/agent-discoverability" -- agent-gateway PR #13; re-point on merge

if not fs.exists(REPO) then
	print(`skip: {REPO} is not checked out; cannot verify anchors`)
	return
end

local checks: { Check } = {
	{ file = "src/constants.luau", needle = 'local TAG = "AgentGateway"', desc = "CollectionService tag" },
	{ file = "src/types.luau", needle = 'method: "list" | "call"', desc = "protocol methods" },
	{ file = "src/createGateway.luau", needle = 'SetAttribute("ProtocolVersion"', desc = "ProtocolVersion attribute" },
	{ file = "src/createGateway.luau", needle = 'SetAttribute("Usage"', desc = "Usage attribute" },
	{ file = "src/createGateway.luau", needle = 'SetAttribute("Description"', desc = "Description attribute" },
}

local drift: { string } = {}
for _, check in checks do
	local result = process.run({ "git", "-C", REPO, "show", `{REF}:{check.file}` })
	if not result.ok then
		table.insert(drift, `cannot read {check.file} at {REF} (is the branch fetched?)`)
	elseif not string.find(result.stdout, check.needle, 1, true) then
		table.insert(drift, `{check.desc}: "{check.needle}" not found in {check.file} at {REF}`)
	end
end

if #drift > 0 then
	print(`use-agent-gateway drift vs {REF} ({#drift}):`)
	for _, msg in drift do
		print(`  - {msg}`)
	end
	process.exit(1)
end

print(`use-agent-gateway: all anchors present at {REF}`)
