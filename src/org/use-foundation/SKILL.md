---
name: use-foundation
description: "Building UI with Roblox's Foundation design system in react-lua: FoundationProvider and theme resolution, the tag styling system, design tokens via useTokens, component and enum idioms, CommonProps passthrough, and when to drop to a raw Roblox instance. Use when: writing or styling UI that renders Foundation components, picking a color, spacing, or font, or reviewing such a diff. Component structure and state patterns live in org/write-react-code."
type: process
---

# Use Foundation

Foundation is Roblox's design system package, required as `@rbxpkg/Foundation` (or whatever the repo's `.luaurc` aliases the Roblox package store to). It supplies themed components, a utility-tag styling system, and design tokens. This skill is how the org uses it. The structure of the components you build with it is [`org/write-react-code`](../write-react-code/SKILL.md).

## Provider setup

Every Foundation tree sits under a `FoundationProvider` with a resolved theme at the app root:

```luau
React.createElement(Foundation.FoundationProvider, {
	theme = themeName, -- "Dark" or "Light" (Foundation.Theme)
	overlayGui = overlayGui, -- portal target for dialogs and popovers
}, children)
```

Resolve the theme from the user's setting, falling back to the Studio theme when the setting is "system", and re-resolve when Studio's `ThemeChanged` fires. Keep that logic in a `useThemeName`-style hook so the provider line stays declarative. Set `overlayGui` when the app renders dialogs, popovers, or menus, so they can portal above the rest of the UI.

## Style with tags first

Layout and styling are expressed through the `tag` prop, a space-separated utility string in the spirit of Tailwind. Reach for tags before reaching for explicit properties. Do not construct `UIListLayout`, `UIPadding`, or `UICorner` instances yourself.

```luau
e(Foundation.View, {
	tag = "size-full-0 auto-y row gap-small align-y-center radius-medium padding-medium bg-surface-200",
}, children)
```

The vocabulary covers sizing (`size-full`, `size-full-0`, `auto-xy`, `auto-y`, `shrink`), flow (`row`, `col`, `gap-small`, `flex-between`), alignment (`align-x-center`, `align-y-center`), spacing (`padding-medium`, `padding-x-small`, `padding-top-medium`), background (`bg-surface-0` through `bg-surface-300`, `bg-shift-100`), typography and content color on `Text` (`text-body-medium`, `text-label-medium`, `text-heading-medium`, `content-default`, `content-muted`, `content-alert`, `text-wrap`, `text-truncate-end`), corners (`radius-small`, `radius-medium`), and strokes (`stroke-standard`, `stroke-thick`, `stroke-default`, `stroke-system-emphasis`, `stroke-position-inner`).

State-dependent styling uses the table form, where each key is a tag string and each value is whether it applies:

```luau
tag = {
	["size-full-1200 row align-y-center gap-small radius-medium padding-x-small"] = true,
	["stroke-standard"] = not isActive,
	["stroke-thick"] = isActive,
	["stroke-system-emphasis"] = isSelecting,
},
```

A few things stay explicit props rather than tags: `padding = { left = UDim.new(0, 16) }` for a one-off inset, `sizeConstraint = { MaxSize = Vector2.new(300, 200) }`, `LayoutOrder`, and `backgroundStyle` when the color comes from a token rather than a `bg-*` tag.

## Tokens for what tags cannot say

When a value has to leave the tag system (a raw instance, a computed style, a brand color), pull it from the design tokens via `useTokens`. Never hardcode a color, font, or pixel size that a token covers.

```luau
local useTokens = Foundation.Hooks.useTokens

local function CodeLabel(props: Props)
	local tokens = useTokens()
	local font = tokens.Typography.BodyMedium
	local color = tokens.Color.Content.Default

	return e("TextLabel", {
		TextSize = font.FontSize,
		Font = font.Font,
		TextColor3 = color.Color3,
		TextTransparency = color.Transparency,
	})
end
```

Tokens are theme-aware, so a component styled from them follows light and dark for free. The families you will use most: `tokens.Color.*` (Surface, Content, ActionEmphasis, and the Extended palettes), `tokens.Typography.*` (Font, FontSize, LineHeight per named style), and the numeric `tokens.Padding.*` and `tokens.Size.*`. Every color entry is a ColorStyle carrying `Color3` and `Transparency`. When one token choice recurs across an app (a brand accent, say), wrap it in a one-line hook (`useBrandAccent`) so the decision lives in one place.

## Reach for Foundation components before raw instances

Foundation ships the full palette: `View`, `ScrollView`, `Text`, `Image`, `Icon`, `IconButton`, `Button`, form inputs (`TextInput`, `TextArea`, `NumberInput`, `Checkbox`, `Toggle`, `Slider`, `ColorPicker`, `Dropdown`), and overlays (`Dialog`, `Popover`, `Menu`, `Tooltip`). Prop idioms to match:

- **Activation is `onActivated`**, secondary (right-click) is `onSecondaryActivated`, and state transitions arrive via `onStateChanged = function(state: Foundation.ControlState) end`.
- **Foundation-level props are lowercase** (`text`, `label`, `hint`, `placeholder`, `hasError`, `isRequired`, `size`, `variant`, `width`), while pass-through Roblox properties stay PascalCase (`LayoutOrder`, `Text` on `Foundation.Text`).
- **Hover and press feedback is the `stateLayer` prop**, for example `stateLayer = { affordance = Foundation.Enums.StateLayerAffordance.None }` to suppress it on a container that is not a button.
- **Overlay components are compound:** `Dialog.Root` with `Dialog.Title`, `Dialog.Content`, and `Dialog.Actions` (which takes an `actions` array of button descriptors), and `Popover.Root` wrapping `Popover.Anchor` plus `Popover.Content` with `side` and `align` enums.
- **`ScrollView` takes sub-tables**: `scroll` for ScrollingFrame properties and `layout` for list-layout properties, alongside the usual `tag`.

Drop to a raw instance (`e("TextBox", ...)`) only when Foundation does not provide the behavior, such as selectable or editable text. Even then, style it from tokens, and wrap it in a shared component (a `SelectableTextLabel`) so the exception lives in one audited place instead of being repeated ad hoc.

For animation, ReactSpring springs bind directly to numeric properties: `TextTransparency = styles.alpha`.

## Enums, never raw strings

Every variant, size, and state comes from `Foundation.Enums`: `ButtonVariant`, `InputSize`, `ControlState`, `IconName`, `PopoverSide`, `StateLayerAffordance`, `Theme`, and the rest. A raw string in a `variant` or `size` prop is a review comment.

Volatile, dated 2026-07-13: Foundation has deprecated its per-component size enums in favor of shared ones. `ButtonSize`, `CheckboxSize`, and `ToggleSize` are deprecated for `InputSize`, and `DividerOrientation` for `Orientation`. Older code still compiles with the deprecated names. New code must use the replacements, and it is fine to migrate a line you are already touching.

## CommonProps passthrough

A wrapper component that should accept Foundation's shared props (tag, padding, LayoutOrder and friends) intersects `Foundation.CommonProps` into its own `Props` type and merges the caller's values over its base props with `Foundation.Utility.withCommonProps`:

```luau
local withCommonProps = Foundation.Utility.withCommonProps

export type Props = {
	onActivated: () -> (),
} & Foundation.CommonProps

local function PanelButton(props: Props)
	return e(
		Foundation.View,
		withCommonProps(props, {
			tag = "auto-xy row gap-small",
			onActivated = props.onActivated,
		})
	)
end
```

## When not to use

This skill is Foundation usage only. For component structure, props conventions, state placement, and effects, see [`org/write-react-code`](../write-react-code/SKILL.md). For the underlying Luau style, see [`org/write-luau-code`](../write-luau-code/SKILL.md). If a repo does not depend on Foundation, none of this applies. Follow that repo's existing UI conventions instead.

---

## Provenance and Maintenance

**Date stamped:** 2026-07-13. Distilled from the Flipbook plugin's roughly 44 Foundation-consuming modules and from the exports of the Foundation package version Flipbook pins. The tag vocabulary, token families, component palette, and deprecation list are a snapshot of that release. The code excerpts are frozen illustrations, not live pointers.

**Re-verify these claims when this skill next loads:** the volatile layer here tracks the Foundation release the consuming repo pins, so re-derive against that repo's installed package before leaning on a specific name.

- Deprecations: `grep -rn "DEPRECATED" <roblox package store>/_Index/Foundation/Foundation/init.lua` (in Flipbook, the store is `RobloxPackages/`).
- A tag or token name you are about to rely on: confirm it in the installed Foundation package's `StyleSheet/` and `Generated/` directories, or by grepping the consuming repo for an existing use.
- The enum and hook surface: read `Foundation.Enums` and `Foundation.Hooks` from the installed package's `init.lua` rather than trusting the lists above.
