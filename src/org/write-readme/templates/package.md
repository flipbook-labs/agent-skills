# Package template

For libraries other code depends on: Wally packages, Lute packages, or both. Copy the block below into the README, fill it in, and delete its guidance comments. See [the skill](../SKILL.md) for the rules behind it.

````markdown
<!--
flipbook-labs README template: Package

For libraries other code depends on: Wally packages, Lute packages, or both.
Reader: a developer deciding whether to add it as a dependency.
Each section is a few lines. With a docs site, end each one with a link to it;
without one, a section can hold the full content.
Say each point once: in the intro or in a section, never both.
Delete guidance comments when filling it in.
-->

# [PackageName](https://flipbook-labs.github.io/REPO)

<!-- Link the title to the docs site when there is one; otherwise use a plain title. -->

<!-- Icon: encouraged. Square SVG, or a PNG of at least 256px, on its own filled background so it reads in light and dark mode. -->
<img src="img/icon.svg" width="128" height="128" align="right" alt="PackageName icon" />

PackageName does one thing, and the traits that set it apart in the same breath. It runs on Roblox, Lute, or both.

<!-- Optional: what it supports or is compatible with, in one or two sentences, unless a section covers it. -->

<!-- Optional: a status note, e.g. "PackageName is pre-release; the API may change before v1." or "Built for flipbook-labs repos." -->

<!-- Optional: only when a docs site exists. -->

API reference lives at [flipbook-labs.github.io/REPO](https://flipbook-labs.github.io/REPO).

## Install

<!-- Keep only the ways this package ships. Changewrite keeps these versions current through [version].mirror. -->

With Wally:

```toml
[dependencies]
PackageName = "flipbook-labs/REPO@0.0.0"
```

With Lute, add this to `pkg.luau` and run `lute pkg install --vendor`:

```luau
REPO = {
	rev = "v0.0.0",
	sourceKind = "github",
	source = "https://github.com/flipbook-labs/REPO",
},
```

## Use

<!-- The smallest example that does something real, then the next most common case or two. End with a docs link. -->

```luau
local PackageName = require("@pkg/PackageName")
```

See the [API reference](https://flipbook-labs.github.io/REPO/api) for every option.

<!--
Optional topic sections: one per question this package raises, a few lines each, ending in a docs link.
Name them in a word or two, e.g. "## Sinks", "## Compatibility", "## Non-goals".
-->

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT.

<!-- Give each bundled third-party license its own paragraph. -->
````
