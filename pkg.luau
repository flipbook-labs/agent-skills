return {
	package = {
		name = "AgentSkills",
		version = "0.9.0",
		-- Pure skill library: markdown SKILL.md files under src/, no runtime dependencies.
		-- Consumers vendor this package into `.lpm/` and read the skills from there; see README.md.
		dependencies = {},
	},
}
