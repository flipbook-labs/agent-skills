---
name: write-react-code
description: "The house react-lua component style for flipbook-labs UIs: module anatomy and the `e` alias, exported Props types and defaults via Sift, named-children element trees, state placement (useState vs Charm signals and computeds), context module shape, effect discipline, and colocated .story.luau / .spec.luau files. Use when: writing or editing React components, hooks, stores, or contexts in Luau in any flipbook-labs repo, or reviewing such a diff. Foundation styling specifics live in org/use-foundation."
type: process
---

# Write React Code

The house patterns for UI written with react-lua (React in Luau, rendered through ReactRoblox). They were distilled from Flipbook, the org's largest React codebase, and they are what a reviewer expects any new React code in the org to look like. Match the surrounding file when it already establishes a local convention, and see [`org/write-luau-code`](../write-luau-code/SKILL.md) for the general Luau style underneath all of this.

## Component module anatomy

One component per module, named like its file in PascalCase, returned directly at the bottom. The order inside the file is fixed: requires (packages first, then local modules, alphabetically within each group per StyLua's `sort_requires`), then aliases, then types, then constants, then the component.

```luau
local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

local constants = require("@root/constants")

local useTokens = Foundation.Hooks.useTokens
local e = React.createElement

export type Props = {
	onClose: () -> (),
	LayoutOrder: number?,
}

local function FeedbackDialog(props: Props)
	-- ...
end

return FeedbackDialog
```

- **Alias `React.createElement` as `e` once at the top** and use it throughout. Alias hot hooks the same way (`local useCallback = React.useCallback`, `local useSignalState = ReactCharm.useSignalState`) instead of re-indexing at every call site.
- **Require aliases (`@pkg/`, `@rbxpkg/`, `@root/`) come from the repo's `.luaurc`.** Use the scheme the repo already defines rather than relative paths.
- **`React.memo` is selective.** Wrap components that re-render often or render expensive subtrees (tree nodes, control rows, toolbars). Leave top-level screens and containers unwrapped. Do not cargo-cult it onto everything.

## Props

- **Declare `export type Props` right after the requires and aliases.** Exporting it lets parents and stories type against it. A scoped name (`SidebarProps`) is acceptable when the module defines several prop types, but plain `Props` is the default.
- **Names:** camelCase props, `on*` for callbacks (`onClose`, `onStoryChanged`), `is*`/`has*`/`show*` for booleans (`isDisabled`, `hasError`, `showDevBadge`). Optional props take `?`.
- **Pass-through Roblox properties keep their PascalCase names** (`LayoutOrder: number?`), so a parent can position the component like any instance.
- **A component that forwards Foundation's shared props** (tag, padding, LayoutOrder and friends) intersects them into its type: `type Props = { ... } & Foundation.CommonProps`. See [`org/use-foundation`](../use-foundation/SKILL.md) for the `withCommonProps` half of that pattern.

Defaults live in a `defaultProps` table merged with `Sift.Dictionary.merge`, with a derived type so the body sees every field as present:

```luau
local defaultProps = {
	dragHandleSize = 8, -- px
	minSize = Vector2.new(0, 0),
}

export type Props = {
	dragHandleSize: number?,
	minSize: Vector2?,
	onResize: (newSize: Vector2) -> (),
}
type InternalProps = Props & typeof(defaultProps)

local function ResizablePanel(providedProps: Props)
	local props: InternalProps = Sift.Dictionary.merge(defaultProps, providedProps)
	-- ...
end
```

Sift is the standard for merging prop tables. A middle table of computed values can sit between defaults and provided props in the same merge call.

## Element trees

Children are always a table of named entries, never positional. The key becomes the instance name, so pick names that read well in the Explorer:

```luau
return e(Foundation.View, {
	tag = "size-full row",
}, {
	Sidebar = e(Sidebar, {
		onStoryChanged = onStoryChanged,
	}),

	MainWrapper = e(Foundation.View, {
		tag = "size-full col shrink",
	}, {
		Topbar = e(Topbar, {}),
		Screen = e(Screen, { story = story }),
	}),
})
```

Conditional children use `condition and e(...)` or an if-expression that yields `nil`:

```luau
BadgeCluster = hasBadges and e(View, {}, {
	DevBadge = if props.showDevBadge then e(Badge, { text = "DEV" }) else nil,
}),
```

## State placement

Three tiers, and choosing the right one is most of the design work:

- **`React.useState`:** component-local, ephemeral state. Form fields, open/closed flags, an in-flight error message. If only one component and its children care, it stays here.
- **Charm signal stores:** shared app state (theme, plugin handle, user settings, pinned items). A `create*Store` factory calls `Charm.signal(defaultValue)` and returns a table of getters and setters. Components subscribe with `ReactCharm.useSignalState(getter)`, which re-renders them when the signal changes.
- **`Charm.computed`:** derived state over signals (filtered lists, aggregates, hierarchical rollups). Reads are auto-tracked, so there are no dependency arrays to maintain. Prefer it over `useMemo` when the inputs are signals rather than React state.

```luau
local function createPluginStore(): PluginStore
	local getPlugin, setPlugin = Charm.signal(nil :: Pluginlike?)

	return {
		getPlugin = getPlugin,
		setPlugin = setPlugin,
	}
end

-- In a component:
local pluginStore = useSignalState(PluginStore.get)
local plugin = useSignalState(pluginStore.getPlugin)
```

`Charm.effect` at module scope handles store initialization that must react to a signal (loading persisted settings once a plugin handle arrives). Keep those effects idempotent.

## Context modules

A context lives in its own module and returns three things: the raw `Context`, a `Provider` component, and a `use*` hook wrapping `useContext`. Consumers call the hook, never `useContext` directly.

```luau
local Context = React.createContext(nil :: StoryControlsStore?)

local function useStoryControls(): StoryControlsStore
	local storyControls = React.useContext(Context)
	assert(storyControls ~= nil, "useStoryControls must be used within a StoryControlsProvider")
	return storyControls
end

local function Provider(props: Props)
	local store = React.useMemo(function()
		return props.store or createStoryControlsStore(props.schema)
	end, { props.store, props.schema } :: { unknown })

	return React.createElement(Context.Provider, {
		value = store,
	}, props.children)
end

return {
	Context = Context,
	Provider = Provider,
	useStoryControls = useStoryControls,
}
```

When the default value is a nil-able store, the hook asserts it is inside a provider. When several providers stack at the app root, compose them with a `ContextStack`-style helper (a component that folds `props.children` into a list of provider elements) instead of a nesting pyramid.

## Hooks and effects

- **One concern per effect.** A component tracking visibility, reparenting, and selection gets three effects with separate dependency arrays, not one effect that does everything.
- **List dependencies explicitly, casting mixed arrays to `:: { unknown }`.** Luau cannot type a heterogeneous array, so `end, { plugin, props.story } :: { unknown })` is the idiom. An empty array `{}` means run once.
- **Every event connection is cleaned up** by returning a disconnect function:

```luau
React.useEffect(function()
	local conn = event:Connect(callback)
	return function()
		conn:Disconnect()
	end
end, { event })
```

- **Reset state on prop change with a small effect** (`useEffect(function() setErr(nil) end, { props.story })`), and use a `usePrevious`-style hook when an effect needs to compare against the last value.
- **Custom hooks are named `use*` and live in the repo's shared hooks/common directory.** A hook that bundles state with actions returns one object (`{ value = value, zoomIn = zoomIn, zoomOut = zoomOut }`).
- **Async work from a handler runs in `task.spawn` at the call site.** Track an `isSending`-style flag in state, write the result (or an `err` string) back into state when it completes, and fire telemetry alongside rather than awaiting it.

## Stories and specs live next to the component

Every visual component ships with a `.story.luau` file, and behavior earns a `.spec.luau`, both in the component's directory with its basename.

A story returns a table with a `story` function and optional `summary` and `controls`:

```luau
local React = require("@pkg/React")
local SelectableTextLabel = require("./SelectableTextLabel")

local controls = {
	text = "Sample text to render",
}

return {
	summary = "A styled TextLabel with selectable text",
	controls = controls,
	story = function(props: { controls: typeof(controls) })
		return React.createElement(SelectableTextLabel, {
			Text = props.controls.text,
		})
	end,
}
```

Specs use Jest with ReactRoblox: create a container and root in `beforeEach`, destroy the container in `afterEach`, and wrap every render and state change in `ReactRoblox.act`. There is no `renderHook` utility here. To test a hook, render a small harness component that exercises it and assert on what it rendered. A new screen-sized component gets at least a smoketest (`expect(function() root:render(app) end).never.toThrow()`). For what makes any of these tests worth having, see [`org/write-luau-tests`](../write-luau-tests/SKILL.md).

## When not to use

This skill owns the structure of React code. For styling, theming, tokens, and everything else Foundation-specific, see [`org/use-foundation`](../use-foundation/SKILL.md). For the Luau style underneath (types, naming, table formatting), see [`org/write-luau-code`](../write-luau-code/SKILL.md). For test quality doctrine, see [`org/write-luau-tests`](../write-luau-tests/SKILL.md). For keeping a UI change reviewable, see [`org/reviewable-changes`](../reviewable-changes/SKILL.md).

---

## Provenance and Maintenance

**Date stamped:** 2026-07-13. Distilled from a survey of the Flipbook plugin's React codebase (roughly 80 components across its core and next-generation workspaces, 27 of which alias `e`, plus its stores, contexts, stories, and specs), currently the org's largest body of react-lua UI code. The code excerpts are frozen illustrations edited down from real components, not live pointers into any repo.

**Re-verify these claims when this skill next loads:** this is `org/` doctrine with no single-repo anchors, so there is nothing mechanical to run. The volatile assumptions are the libraries themselves: Charm/ReactCharm for shared state, Sift for prop merging, Jest with ReactRoblox for specs, and Storyteller's story table shape. If a repo you are working in has moved off any of these (for example a `renderHook` utility gets adopted, or stories gain a new format), trust that repo's code, then update this skill and add a `.changes/` entry.
