-- Shared types for the skill-library test suite.

export type Skill = {
	scope: string,
	name: string,
	id: string,
	directory: string,
	skillPath: string,
}

-- One markdown file a skill ships. `directory` is the file's own folder rather
-- than the skill root, because a relative link inside a nested reference file
-- resolves against the folder holding it.
export type MarkdownFile = {
	skill: Skill,
	filePath: string,
	directory: string,
	contents: string,
}

-- `findViolations` returns one string per place the rule is broken, so a single
-- run hands the author the whole worklist rather than the first failure.

-- A rule about the skill as a unit, checked once against `SKILL.md`. Frontmatter,
-- the provenance footer, and the body ceiling are properties of the skill and
-- mean nothing on a file sitting next to it.
export type SkillRule = {
	id: string,
	summary: string,
	findViolations: (skill: Skill, contents: string) -> { string },
}

-- A rule about prose, checked against every markdown file the skill ships. A
-- reader who follows a link out of `SKILL.md` into a reference file reads it the
-- same way, so it has to hold to the same conventions.
export type ProseRule = {
	id: string,
	summary: string,
	findViolations: (file: MarkdownFile) -> { string },
}

export type DoctrineRules = {
	skill: { SkillRule },
	prose: { ProseRule },
}

return {}
