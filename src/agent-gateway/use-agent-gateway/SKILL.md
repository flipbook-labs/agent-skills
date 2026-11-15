---
name: use-agent-gateway
description: "Drive Studio plugins that expose actions through an AgentGateway. Use when: interacting with such a plugin from inside Roblox Studio, calling its actions through the Studio MCP server, or debugging a gateway call. Generic, and applies to any plugin built on AgentGateway."
type: knowledge
---

# Use an AgentGateway

Plugins built on [AgentGateway](https://github.com/flipbook-labs/agent-gateway) expose actions to in-Studio agents through a `BindableFunction`. Each gateway describes its own actions, so ask the gateway before you read plugin source.

## When not to use

To validate the gateway library itself, see the `e2e` skill in the `flipbook-labs/agent-gateway` repo. For Flipbook's workflow, see [`flipbook/use-studio-mcp-for-flipbook`](../../flipbook/use-studio-mcp-for-flipbook/SKILL.md).

## Connect and find a gateway

Run Luau in the Edit data model through the Studio MCP `execute_luau` tool, with `datamodel_type = "Edit"`. If a tool reports `Not connected to the WS host`, stop and ask the user to enable Studio as an MCP server. Retrying does not fix it. If several Studio instances are open, call `list_roblox_studios` to find the right one.

Before opening a place to validate in, call `list_roblox_studios` and record the instance ids already open. Open one place, record its new id, and reuse that instance. When you finish, close only the instance you opened and check that the list is back to where it started, since each extra Studio process holds its own memory.

Plugins parent gateways to `CoreGui` in the Edit data model unless they set another parent. Find one by name:

```lua
local gateway = game:GetService("CoreGui"):FindFirstChild("FlipbookAgentGateway")
```

Discovery by tag is pending [agent-gateway PR #13](https://github.com/flipbook-labs/agent-gateway/pull/13), which is not merged. Once it ships, every gateway carries the `AgentGateway` CollectionService tag, so `CollectionService:GetTagged("AgentGateway")` finds them all. Until then, look up a gateway by name.

## Speak the protocol

Everything goes through `gateway:Invoke(request)`:

```lua
-- List the actions and their input schemas
local manifest = gateway:Invoke({ method = "list" })

-- Call one
local response = gateway:Invoke({ method = "call", action = "<actionName>", params = { ... } })
```

- Responses are always `{ ok: boolean, result: any?, error: string? }`. Read the payload from `response.result`. Errors do not throw, so check `ok`.
- The manifest lists each action's `name`, `title`, `description`, and optional `inputSchema`, plus `protocolVersion`.
- Unknown actions return `unknown action: <name>`. A bad request returns an error starting with `malformed request:`.
- Pending PR #13: the manifest also carries the plugin author's `instructions`, and params are validated against `inputSchema` before an action runs. Validation errors start with `invalid params for <action>:` and quote the schema. Without that change, an action gets raw params and reports its own errors.
- Return data from `execute_luau` as a string with `HttpService:JSONEncode(...)`.

## Poll, do not sleep

If an action has asynchronous effects, poll a read-back action in a loop with `task.wait()` until the expected state appears. Do not use fixed sleeps.

## Gotchas

- `screen_capture` captures the Studio viewport, never plugin dock widgets. If the manifest advertises an action that moves the mounted plugin UI into the Edit-mode viewport, capture there, then call its return action so the UI goes back to its widget. Otherwise use a gateway action that embeds the UI into the place, then capture in Play mode.
- Prefer gateway actions over simulated input. If you must fall back to input, tell the user, because that is a gap worth a new action.

## Provenance and Maintenance

**Date stamped:** 2026-11-14. Trimmed; marked tag discovery, instructions, and validation as pending PR #13.

**Re-verify these claims when this skill next loads:** run `scripts/check-drift.luau` with `lute` from the hub root. It reads PR #13's branch in a sibling `../agent-gateway` checkout through `git show`, so it works whatever is checked out, and skips cleanly when the repo or branch is missing. When PR #13 merges, point `REF` in the script at `origin/main` and drop the pending notes above.
