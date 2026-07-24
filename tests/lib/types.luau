-- Shared types for the skill-library test suite.

export type Skill = {
	scope: string,
	name: string,
	id: string,
	directory: string,
	skillPath: string,
}

-- `findViolations` returns one string per place the skill breaks the rule. The
-- count is what the baseline ratchets against, so a rule that can fire many
-- times per skill must return one entry per occurrence rather than a summary.
export type DoctrineRule = {
	id: string,
	summary: string,
	findViolations: (skill: Skill, contents: string) -> { string },
}

-- Skill id to rule id to the number of violations grandfathered for that pair.
export type DoctrineBaseline = { [string]: { [string]: number } }

return {}
