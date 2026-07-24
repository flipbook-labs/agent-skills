-- Shared types for the skill-library test suite.

export type Skill = {
	scope: string,
	name: string,
	id: string,
	directory: string,
	skillPath: string,
}

-- `findViolations` returns one string per place the skill breaks the rule, so a
-- single run hands the author the whole worklist rather than the first failure.
export type DoctrineRule = {
	id: string,
	summary: string,
	findViolations: (skill: Skill, contents: string) -> { string },
}

return {}
