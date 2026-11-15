---
name: use-studio-mcp-for-flipbook
description: "Drive a local Flipbook build through the Studio MCP and the FlipbookAgentGateway actions, including embedded Play-mode screenshots and input. Use when: verifying Stories in Studio, changing gateway actions, or capturing visual evidence of Flipbook UI."
type: process
---

# Use Studio MCP for Flipbook

Build Flipbook, open the generated Storybook experience in Studio, drive it through the gateway, and embed it for visual checks. For the protocol, polling, and connection errors, read [`agent-gateway/use-agent-gateway`](../../agent-gateway/use-agent-gateway/SKILL.md).

## When not to use

Use [`flipbook/dev-env`](../dev-env/SKILL.md) for headless checks, and for overlaying local Storyteller or ModuleLoader changes first.

## Build and connect

```bash
lute run build plugin --channel dev --clean
lute run build storybook --channel dev --clean
```

Open the generated Storybook experience in a new Studio instance, find it with `list_roblox_studios`, and use the Edit data model for gateway calls. Find the gateway named `FlipbookAgentGateway`.

## Drive Flipbook

Call `list` first, then use this order:

1. Call `openWidget`.
2. Call `embedFlipbook` before Play mode if you need screenshots or virtual input.
3. Poll `listStorybooks` until the target Storybook appears.
4. Call `listStories` with that Storybook path.
5. Call `openStory` with the Story and Storybook paths.
6. Poll `getCurrentStory` until the path matches and `isMounted` is true.
7. Poll `getControls` until the expected control appears.
8. Call `setControls`, then confirm with `getControls`.

Take every path from gateway results.

## Visual and input checks

Studio MCP viewport captures do not include plugin dock widgets, so a capture in Edit mode never shows Flipbook's widget.

Flipbook PR #650, which is not merged, adds a gateway action that moves the mounted app into the Edit-mode viewport and back. When the manifest advertises it, capture in Edit mode: open the story, poll until it's mounted, capture, then call the return action and confirm the story and controls are unchanged. Record a short clip driven by virtual input when the behavior depends on hover or a transition, so your own pointer stays out of it.

Otherwise, embed Flipbook and playtest:

1. Call `embedFlipbook`. It returns the `path` it embedded into. The `parent` param defaults to `ReplicatedStorage`.
2. Start Play mode with `start_stop_play`, then poll `get_studio_state` until the Client data model appears.
3. Find the embedded UI in the Client data model and wait for the target Story or control to appear. A blank or loading capture is not evidence.
4. Capture with `screen_capture`.
5. If no gateway action covers an interaction, use `user_mouse_input` or `user_keyboard_input` against a Client instance path you discovered. If the same fallback keeps recurring, add a gateway action for it.
6. Check Client console output when the UI does not mount or react.
7. Stop Play mode when you finish.

Embedding changes the open place. Do not pass `overwrite = true`, which replaces an existing embedded runtime, and do not save the place without the user's permission.

## Provenance and Maintenance

**Date stamped:** 2026-11-14. Merged the embedded Play-mode reference and linked the gateway skill for protocol details.

**Re-verify these claims when this skill next loads.** Run these from a Flipbook checkout. A command that fails or prints nothing means the skill needs updating:

```sh
git grep -n -E "listStorybooks|openStory|setControls|getCurrentStory" -- workspace/flipbook-agents/src
git grep -n embedFlipbook -- workspace/flipbook-agents/src
git grep -n FlipbookAgentGateway -- workspace
```
