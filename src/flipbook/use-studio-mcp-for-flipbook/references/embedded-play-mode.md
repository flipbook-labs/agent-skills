# Embedded Play-mode checks

Use this workflow when a Flipbook check needs viewport screenshots or virtual mouse and keyboard input. Run semantic gateway actions in Edit mode first. The embedded client is the visual and input surface.

1. Discover gateways through the `AgentGateway` CollectionService tag, select the gateway whose manifest name is `FlipbookAgentGateway`, and invoke `embedFlipbook`. Omit `parent` to use `ReplicatedStorage`, and leave `overwrite` false unless replacing an existing embedded runtime is intended. With no gateway, embed the runtime as described in [Embedding without the gateway](#embedding-without-the-gateway).
2. Start Play mode with `start_stop_play`, then poll `get_studio_state` until the Client data model is available.
3. Find the embedded UI under `LocalPlayer.PlayerGui.Flipbook` and wait for its target story or control to appear. Do not substitute a blank or loading capture for evidence.
4. Use `screen_capture` for visual evidence.
5. When no gateway action covers an interaction, use `user_mouse_input` or `user_keyboard_input` against a discovered Client instance path. Treat repeated fallback interactions as candidates for a focused gateway action.
6. Inspect Client console errors when the UI does not mount or react as expected.
7. Stop Play mode when finished unless the user asks to leave the experience running.

Embedding mutates the open place. Do not pass `overwrite = true`, save the place, or replace an existing runtime without authorization.

## Embedding without the gateway

The embedded runtime is the dev build placed under `ReplicatedStorage.Flipbook`. Its starter scripts mount the UI when Play mode starts. Without the gateway, there are two ways to get the runtime into a place.

The first needs no one at the keyboard. Build a place from a Rojo project that maps `ReplicatedStorage.Flipbook` to `build/dev/roblox` and sets `"emitLegacyScripts": false`, then open that place in Studio. The root `default.project.json` has the right tree, but by default Rojo emits a legacy `LocalScript` and `Script`, and those never run from `ReplicatedStorage`. If a place already has legacy starter scripts, replace each one with a `Script` whose `RunContext` is `Client` or `Server`.

The second is Flipbook's **Embed into experience** dialog, which a person has to click. It copies the installed plugin, not your checkout. Confirm the widget's commit before embedding.

## Driving the embedded UI

These behaviors were observed with the built-in Studio MCP server. Re-check them when input stops landing.

- `user_mouse_input` coordinates are in GUI space, matching `AbsolutePosition`. `screen_capture` also includes the top-bar inset, so a point read off a screenshot lands lower than intended. Read the target's `AbsolutePosition` and `AbsoluteSize` from the Client data model, and click its center.
- `mouseButtonClick` does not activate Foundation buttons. Send `mouseButtonDown`, wait about 80 ms, then send `mouseButtonUp`.
- The first press after a long move sometimes only hovers. Read the state back after every press, and press once more if nothing changed.
- A fresh profile opens the telemetry consent dialog first. Close it with its close affordance. **Done** would submit the checked consent box.
- Play-mode captures show the embedded UI as rendered. If a capture comes back as a solid color, stop and report it rather than using it as evidence.
