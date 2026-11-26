return {
	categories = { "Features", "Changes", "Fixes", "Dependencies", "Internal" },
	collapsed = { "Dependencies", "Internal" },
	version = {
		current = "0.10.0",
		mirror = {
			{ file = "pkg.luau" },
			{ file = "README.md", pattern = 'rev = "v([%d%.]+)"' },
		},
	},
	kind = {
		release = { text = "Release", color = "#94606f" },
		["agent-gateway"] = { text = "AgentGateway", color = "#8250df" },
		build = { text = "Build", color = "#5a7396" },
		ci = { text = "CI", color = "#75659a" },
		contributing = { text = "Contributing", color = "#5f7f55" },
		docs = { text = "Docs", color = "#8a5a2b" },
		flipbook = { text = "Flipbook", color = "#bc4c00" },
		org = { text = "Org", color = "#5b5bd6" },
		packages = { text = "Packages", color = "#7a7444" },
		tooling = { text = "Tooling", color = "#4e8079" },
		validation = { text = "Validation", color = "#0969da" },
	},
}
