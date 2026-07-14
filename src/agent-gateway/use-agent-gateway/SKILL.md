---
name: use-agent-gateway
description: "Discover and drive Studio plugins that expose actions through an AgentGateway. Use when: interacting with such a plugin from inside Roblox Studio, connecting to the Roblox Studio MCP server, or troubleshooting that connection. Generic, and applies to any plugin built on AgentGateway from any repo."
type: knowledge
---

# Use an AgentGateway

Plugins built on [AgentGateway](https://github.com/flipbook-labs/agent-gateway) expose their actions to in-Studio agents through a single `BindableFunction`. This skill covers everything generic: connecting to Studio, finding gateways, and speaking the protocol. What each gateway can _do_ is self-served: its manifest carries descriptions, input schemas, and usage instructions, so prefer asking the gateway over reading plugin source.

## When not to use

This skill is for _consuming_ a gateway from inside Studio. To build the AgentGateway example plugin and validate the gateway itself end-to-end, see the `e2e` skill in the `flipbook-labs/agent-gateway` repo (it will move here as `agent-gateway/e2e` once seeded).

## Connect to Roblox Studio

You need a way to run Luau inside the open Studio session. Preferred: the **Roblox Studio MCP server** ([docs](https://create.roblox.com/docs/studio/mcp)), which exposes an `execute_luau` tool.

1. In Studio, the user enables it once: **Assistant → ⋯ → Manage MCP Servers → Enable Studio as MCP server**.
2. Register the server with your agent host, either via the Quick Connect dropdown in that same Studio dialog, or by adding it to the host's MCP config (`.mcp.json` or equivalent):

   ```json
   {
     "mcpServers": {
       "Roblox_Studio": {
         "command": "/Applications/RobloxStudio.app/Contents/MacOS/StudioMCP"
       }
     }
   }
   ```

   On Windows the command is `cmd.exe` with args `["/c", "%LOCALAPPDATA%\\Roblox\\mcp.bat"]`.

Useful Studio MCP tools:

- `list_roblox_studios` / `set_active_studio`: pick the target Studio instance.
- `get_studio_state`: confirm Edit/Client/Server data models and play state.
- `execute_luau`: run Luau. Use `datamodel_type = "Edit"` for plugin and gateway work.
- `start_stop_play`, `screen_capture`: playtesting and viewport captures.

### Troubleshooting

- **No active instance:** call `list_roblox_studios`, then `set_active_studio`. As a fallback probe, `search_game_tree` against `Workspace` before retrying.
- **`Not connected to the WS host`:** the Studio-side server isn't enabled in the open session. Stop and ask the user to enable it (step 1 above). Retrying tools will not fix this.
- **`screen_capture` captures the 3D viewport only**, never plugin dock widgets. To visually inspect plugin UI, look for a gateway action that embeds the UI into the place, then capture in play mode.
- If a Command Bar is all you have (no MCP), the same Luau snippets below work there (View → Command Bar).

## Discover gateways

Every gateway `BindableFunction` carries the `AgentGateway` CollectionService tag. This one convention replaces all plugin-specific knowledge, so no gateway names or locations are needed:

```lua
local CollectionService = game:GetService("CollectionService")

for _, gateway in CollectionService:GetTagged("AgentGateway") do
	print(gateway:GetFullName())
	print("  ", gateway:GetAttribute("Description"))
	print("  ", gateway:GetAttribute("Usage"))
	print("  protocol", gateway:GetAttribute("ProtocolVersion"))
end
```

Run this in the **Edit** data model. Gateways are created by plugins, which live there (usually under `CoreGui`).

## Speak the protocol

Everything goes through `gateway:Invoke(request)`. Two methods:

```lua
-- Orient: identity, agent instructions, and every action with its input schema
local manifest = gateway:Invoke({ method = "list" })
-- -> { ok = true, result = { protocolVersion, name, description, instructions, actions = {
--        { name, title, description, inputSchema? }, ...
--    } } }

-- Act
local response = gateway:Invoke({ method = "call", action = "<actionName>", params = { ... } })
-- -> { ok = true, result = ... } or { ok = false, error = "..." }
```

Rules of the road:

- **Start with `list` and read `result.instructions`:** the plugin author put workflow guidance there (ordering, readiness rules, caveats).
- Responses are always `{ ok: boolean, result: any?, error: string? }`. Read payloads from `response.result`, not the top level. Errors never throw; check `ok`.
- `params` are validated against the action's `inputSchema` before the action runs: required params, declared types, `enum` values, and no unknown params. Validation errors quote the schema, so read them and fix the call.
- Error prefixes worth recognizing: `malformed request:` (your request shape, and the error restates the grammar), `unknown action:` (the error lists valid names), `invalid params for <action>:` (the error quotes the schema).
- Results are plain JSON-encodable tables. When returning data from `execute_luau`, `game:GetService("HttpService"):JSONEncode(...)` the response.
- **No fixed sleeps.** If an action has asynchronous effects, poll a read-back action in a `for` loop with `task.wait()` until the expected state appears, then proceed.
- Prefer gateway actions over driving plugin UI with simulated mouse/keyboard input. If you must fall back to manual input against plugin UI, tell the user; that's a gap worth a new gateway action.

## A complete first contact

```lua
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")

local gateways = CollectionService:GetTagged("AgentGateway")
assert(#gateways > 0, "no AgentGateway found; is the plugin installed and the place open?")

local gateway = gateways[1]
local manifest = gateway:Invoke({ method = "list" })
assert(manifest.ok, manifest.error)

return HttpService:JSONEncode(manifest.result)
```

---

## Provenance and Maintenance

**Date stamped:** 2026-07-05. Based on the "discoverable and self-describing gateways" design in agent-gateway [PR #13](https://github.com/flipbook-labs/agent-gateway/pull/13) (branch `agent-discoverability`), which is **not yet merged**. Tag-based discovery and the `Usage`/`Description` attributes exist on that branch, not on agent-gateway `main`.

**Re-verify these claims when this skill next loads:** run `scripts/check-drift.luau` (via `lute` from the hub root). It checks the anchors against `origin/agent-discoverability` in a sibling `../agent-gateway` checkout (via `git show`, so it works regardless of what's checked out) and skips cleanly when the repo or ref is absent. It confirms the `AgentGateway` tag (`src/constants.luau`), the `list`/`call` methods (`src/types.luau`), and the `ProtocolVersion` / `Usage` / `Description` attributes (`src/createGateway.luau`).

**When PR #13 merges:** re-point `REF` in the drift script to `origin/main` (or the release tag) and drop the "not yet merged" note above.
