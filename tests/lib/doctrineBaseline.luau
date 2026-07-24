-- Violations that predate the validator, so CI stays green while the backlog is
-- worked down. Each count is a ceiling that only moves toward zero:
-- tests/doctrine.spec.luau fails when a skill exceeds its entry and also when it
-- beats it, so a fix cannot land without lowering the number. Delete a rule's
-- entry once it reaches zero, and the skill's entry once it is empty.
--
-- Adding a number here for new work is the thing this file exists to prevent.
--
-- The `org/writing-style` em-dash entry is the one deliberate exception: that
-- skill quotes the banned `--` spelling inside a sentence to name it, and the
-- rule cannot tell a quoted sample from a real one outside a code span.

local types = require("./types")

type DoctrineBaseline = types.DoctrineBaseline

local baseline: DoctrineBaseline = {
	["flipbook/architecture-contract"] = table.freeze({
		["body-length"] = 1,
		["provenance-footer"] = 1,
		["em-dash"] = 22,
		["drift-script"] = 1,
	}),
	["flipbook/build-and-toolchain"] = table.freeze({
		["frontmatter-trigger"] = 1,
		["body-length"] = 1,
		["date-stamp"] = 1,
		["em-dash"] = 32,
		["drift-script"] = 1,
	}),
	["flipbook/change-control"] = table.freeze({
		["em-dash"] = 19,
		["drift-script"] = 1,
	}),
	["flipbook/community-and-positioning"] = table.freeze({
		["frontmatter-trigger"] = 1,
		["provenance-footer"] = 1,
		["date-stamp"] = 1,
		["em-dash"] = 32,
		["drift-script"] = 1,
	}),
	["flipbook/config-and-flags"] = table.freeze({
		["frontmatter-trigger"] = 1,
		["provenance-footer"] = 1,
		["em-dash"] = 40,
		["drift-script"] = 1,
	}),
	["flipbook/debugging-playbook"] = table.freeze({
		["em-dash"] = 9,
		["machine-path"] = 1,
		["drift-script"] = 1,
	}),
	["flipbook/develop-through-studioplugins"] = table.freeze({
		["frontmatter-trigger"] = 1,
		["drift-script"] = 1,
	}),
	["flipbook/diagnostics-and-tooling"] = table.freeze({
		["date-stamp"] = 1,
		["em-dash"] = 13,
	}),
	["flipbook/domain-reference"] = table.freeze({
		["em-dash"] = 29,
		["drift-script"] = 1,
	}),
	["flipbook/failure-archaeology"] = table.freeze({
		["frontmatter-trigger"] = 1,
		["body-length"] = 1,
		["date-stamp"] = 1,
		["em-dash"] = 8,
		["drift-script"] = 1,
	}),
	["flipbook/proof-and-analysis-toolkit"] = table.freeze({
		["frontmatter-trigger"] = 1,
		["body-length"] = 1,
		["date-stamp"] = 1,
		["em-dash"] = 29,
		["drift-script"] = 1,
	}),
	["flipbook/release-and-operations"] = table.freeze({
		["frontmatter-trigger"] = 1,
		["body-length"] = 1,
		["em-dash"] = 12,
		["drift-script"] = 1,
	}),
	["flipbook/research-frontier"] = table.freeze({
		["frontmatter-trigger"] = 1,
		["provenance-footer"] = 1,
		["date-stamp"] = 1,
		["em-dash"] = 6,
		["drift-script"] = 1,
	}),
	["flipbook/research-methodology"] = table.freeze({
		["provenance-footer"] = 1,
		["em-dash"] = 7,
		["drift-script"] = 1,
	}),
	["flipbook/run-checks"] = table.freeze({
		["drift-script"] = 1,
	}),
	["flipbook/setup-dev-env"] = table.freeze({
		["em-dash"] = 4,
		["machine-path"] = 3,
		["drift-script"] = 1,
	}),
	["flipbook/story-controls-campaign"] = table.freeze({
		["body-length"] = 1,
		["em-dash"] = 5,
		["drift-script"] = 1,
	}),
	["flipbook/test-dependencies"] = table.freeze({
		["em-dash"] = 1,
		["drift-script"] = 1,
	}),
	["flipbook/validation-and-qa"] = table.freeze({
		["body-length"] = 1,
		["date-stamp"] = 1,
		["em-dash"] = 22,
		["drift-script"] = 1,
	}),
	["flipbook/write-docs"] = table.freeze({
		["em-dash"] = 3,
		["resolvable-links"] = 1,
		["drift-script"] = 1,
	}),
	["org/code-comments"] = table.freeze({
		["em-dash"] = 2,
	}),
	["org/durable-writing"] = table.freeze({
		["em-dash"] = 2,
	}),
	["org/writing-style"] = table.freeze({
		["em-dash"] = 1,
	}),
}

return table.freeze(baseline)
