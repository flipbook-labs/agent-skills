# AgentSkills

AgentSkills is a shared library of agent skills. Each skill is a plain `SKILL.md` file that any agent tool can read, and repos pin the library as a versioned Lute package so every agent works from the same doctrine and runbooks.

AgentSkills is built for flipbook-labs repos.

## Install

Add this to the `dev_dependencies` in `pkg.luau` and run `lute pkg install --vendor`:

```luau
["agent-skills"] = {
	rev = "v0.9.0",
	sourceKind = "github",
	source = "https://github.com/flipbook-labs/agent-skills",
},
```

The skills land in `.lpm/agent-skills@<rev>`.

## Use

Agents find a skill through the routing index at `.lpm/agent-skills@<rev>/AGENTS.md`, which lists every skill with the triggers that call for it. Point your repo's `AGENTS.md` at that index:

```md
## Shared skills

Shared doctrine and runbooks live in the AgentSkills library, vendored into `.lpm/agent-skills@<rev>`, where `<rev>` is the `agent-skills` rev in `pkg.luau`. Read its `AGENTS.md` index in full before you start, then read a skill's `src/<scope>/<name>/SKILL.md` before doing the work it covers.
```

To pick up newer skills, bump `rev` and check [CHANGELOG.md](CHANGELOG.md) for what changed.

## Scopes

Skills live under `src/`, in the narrowest scope that fits:

- `org/`: doctrine for any flipbook-labs repo, such as writing style, Luau style, and changelog entries.
- `family/`: the Flipbook, Storyteller, and ModuleLoader repo family.
- `agent-gateway/`: the AgentGateway protocol.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT.
