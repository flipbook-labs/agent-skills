---
name: use-studio-mcp-for-flipbook
description: "Build and validate Flipbook through Studio MCP and FlipbookAgentGateway. Use when driving a local Flipbook build, changing gateway actions, or verifying Stories through semantic actions, embedded Play-mode input, and screenshots."
type: process
---

# Use Studio MCP for Flipbook

Build Flipbook, open the generated Storybook experience in Studio, use the gateway for semantic checks, and embed Flipbook for Play-mode interaction and screenshots. Keep behavior-specific fixtures and assertions in a reference beside this skill.

## When not to use

Use [`flipbook/run-checks`](../run-checks/SKILL.md) for headless checks. Use [`flipbook/test-dependencies`](../test-dependencies/SKILL.md) before this workflow when the task overlays Storyteller or ModuleLoader. Use [`agent-gateway/use-agent-gateway`](../../agent-gateway/use-agent-gateway/SKILL.md) for generic gateway discovery, protocol details, and connection troubleshooting.

## Build and connect

```bash
lute run build plugin --channel dev --clean
lute run build storybook --channel dev --clean
```

Open the generated Storybook experience in a new Studio instance. The repository registers Studio MCP as `Roblox_Studio` in `.mcp.json`. Select the new instance with `list_roblox_studios` and `set_active_studio`, then use the Edit data model for gateway calls.

If Studio MCP reports `Not connected to the WS host`, stop and ask the user to enable Studio MCP in the open Studio session. Selecting the instance again does not repair that connection.

## Drive Flipbook

Start with the gateway manifest and read its instructions. Follow the protocol in [`agent-gateway/use-agent-gateway`](../../agent-gateway/use-agent-gateway/SKILL.md), using the gateway named `FlipbookAgentGateway`.

Use this sequence:

1. Call `openWidget`.
2. Call `embedFlipbook` before Play mode when visual evidence or virtual input is needed.
3. Poll `listStorybooks` until the target Storybook appears.
4. Call `listStories` with the returned Storybook path.
5. Call `openStory` with returned Story and Storybook paths.
6. Poll `getCurrentStory` until the path matches and `isMounted` is true.
7. Poll `getControls` until the expected control appears.
8. Call `setControls`, then confirm the values with `getControls`.

Do not use fixed sleeps. Discover paths from gateway results instead of hard-coding a DataModel layout.

## Embedded visual and input checks

Studio MCP viewport captures do not include plugin dock widgets. For visual evidence, or when a missing semantic action makes UI input necessary, follow the [embedded Play-mode workflow](references/embedded-play-mode.md). Prefer gateway actions in Edit mode. Use virtual input against the embedded client when no semantic action covers the interaction, and add a focused action when the same interaction becomes routine.

When changing story reload behavior or control wiring, follow the [story hot-reload controls workflow](references/story-hot-reload-controls.md) to verify that controls remain connected after Studio reloads an open story module.

## Provenance and maintenance

**Last verified:** 2026-09-13 against Flipbook PR #635.

**Re-verify these claims when this skill next loads:** read the `AgentSkills` `rev` pinned in the Flipbook checkout's `loom.config.luau`, resolve `<skills>` as `~/.loom/store/AgentSkills@<rev>`, and run `lute run <skills>/src/flipbook/use-studio-mcp-for-flipbook/scripts/check-drift.luau`. It checks the registered Studio MCP server, gateway name and actions, and build subcommands.
