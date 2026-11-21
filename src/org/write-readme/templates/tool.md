# Tool template

For things that run in a terminal or a CI workflow: CLIs and GitHub Actions. Copy the block below into the README, fill it in, and delete its guidance comments. See [the skill](../SKILL.md) for the rules behind it.

````markdown
<!--
flipbook-labs README template: Tool

For things that run in a terminal or a CI workflow: CLIs and GitHub Actions.
Reader: a developer wiring it into their project or pipeline.
Each section is a few lines. With a docs site, end each one with a link to it;
without one, a section can hold the full content.
Say each point once: in the intro or in a section, never both.
Delete guidance comments when filling it in.
-->

# [ToolName](https://flipbook-labs.github.io/REPO)

<!-- Link the title to the docs site when there is one; otherwise use a plain title. -->

<!-- Icon: encouraged. Square SVG, or a PNG of at least 256px, on its own filled background so it reads in light and dark mode. -->
<img src="img/icon.svg" width="128" height="128" align="right" alt="ToolName icon" />

ToolName automates one job, and the traits that set it apart in the same breath.

<!-- Optional: what it supports or works with, in one or two sentences, unless a section covers it. -->

<!-- Optional: a status note, e.g. "ToolName is pre-release." or "Built for flipbook-labs repos." -->

<!-- Optional: only when a docs site exists. -->

Guides and reference live at [flipbook-labs.github.io/REPO](https://flipbook-labs.github.io/REPO).

## Install

<!-- Keep only the ways this tool ships. Changewrite keeps these versions current through [version].mirror. An Action's `uses:` line may repeat in the workflow under Use, with its own mirror pattern. -->

With Rokit:

```sh
rokit add flipbook-labs/REPO
```

As a GitHub Action:

```yaml
- uses: flipbook-labs/REPO@v0.0.0
```

## Use

<!-- One-time setup if any (secrets, config file), then a real run with its output or the workflow step that uses it. End with a docs link. -->

```sh
toolname command --flag
```

See the [command reference](https://flipbook-labs.github.io/REPO/commands) for every command and option.

<!--
Optional topic sections: one per question this tool raises, a few lines each, ending in a docs link.
Name them in a word or two, e.g. "## Configure", "## Inputs", "## Security".
-->

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT.

<!-- Give each bundled third-party license its own paragraph. -->
````
