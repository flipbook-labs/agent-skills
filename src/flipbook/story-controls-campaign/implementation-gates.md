# Story Controls: Implementation Gates

One numbered gate sequence per solution, with the exact commands, the expected observation at each gate, and the success criteria that close it. PHASE 3 of [`SKILL.md`](SKILL.md) sends you here once you have chosen a solution from [`solution-menu.md`](solution-menu.md). Work only the sequence for the solution you chose.

## SOLUTION A: Object Migration Fix (Storyteller)

**GATE A.1: Understand the cross-repo workflow**

This fix lives in **Storyteller**, not Flipbook. The workflow is:

1. Clone/fetch flipbook-labs/storyteller (sibling repo)
2. Create branch in Storyteller
3. Make the 5-line fix in Storyteller
4. Push; open PR in Storyteller
5. In Flipbook: use `test-dependencies` to overlay the Storyteller branch and verify
6. Merge Storyteller PR; version bump (1.12.0 → 1.12.1)
7. In Flipbook: update wally.toml to new Storyteller version
8. `lute run install` to pull new Storyteller
9. Run Flipbook tests to confirm

**GATE A.2: Storyteller fix (in Storyteller repo, not here)**

In Storyteller's `controls/migrations/ui-labs-v2.4.2/migrateUILabsControl.luau`:

Replace:

```luau
elseif control.Type == "Object" then
    return nil
```

With:

```luau
elseif control.Type == "Object" then
    local migrated: ObjectControl = {
        type = ControlType.Object,
        default = nil,
    }
    return migrated
```

Ensure `ObjectControl` type is imported at top if not already.

**Write test in Storyteller:**

```luau
-- In Storyteller's control migrations spec
local migratedObject = migrateUILabsControl({
    Type = "Object",
})

expect(migratedObject).to.be.ok()
expect(migratedObject.type).toBe("Object")
expect(migratedObject.default).toBe(nil)
```

**GATE A.3: Version bump Storyteller**

In Storyteller's `wally.toml`, bump version:

```toml
version = "1.12.1"
```

Publish to Wally registry.

**GATE A.4: Update Flipbook's wally.toml**

In Flipbook (this repo), change:

```toml
Storyteller = "flipbook-labs/storyteller@1.12.0"
```

To:

```toml
Storyteller = "flipbook-labs/storyteller@1.12.1"
```

**Run:**

```bash
lute run install
```

**Expected:** New Storyteller version fetched to `Packages/_Index/`.

**GATE A.5: Test the fix with a UILabs Object story**

Create test story in `/workspace/example/src/Examples/UILabsObjectTest.story.luau`:

```luau
local Storyteller = require("@pkg/Storyteller")
local React = require("@pkg/React")

local e = React.createElement

-- Simulate UILabs.Advanced.Object schema after migration
local uiLabsObjectSchema = {
    Type = "Object",
    -- UILabs-specific metadata (not used by Flipbook)
}

local migratedControl = Storyteller.migrateUILabsControl(uiLabsObjectSchema)

local story: Storyteller.Story = {
    controls = {
        selectedInstance = migratedControl or Storyteller.createObjectControl(nil),
    },
    story = function(props)
        local selected = props.controls.selectedInstance
        return React.createElement("TextLabel", {
            Text = "Selected: " .. (selected and selected.Name or "None"),
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = Color3.fromRGB(240, 240, 240),
            TextColor3 = Color3.fromRGB(0, 0, 0),
        })
    end,
}

return story
```

**Run Flipbook manually or via studio plugin:**

```bash
lute run build plugin --channel dev
# Open Flipbook in Studio; navigate to UILabsObjectTest story
```

**Expected Observation:**

- Story renders
- ObjectControl UI (InstancePicker) appears in the controls panel
- Can click "Select an Instance..." and choose an instance from the DataModel
- Selected instance name appears in the story UI
- Story props.controls.selectedInstance is the Instance object (not nil)

**GATE A.6: Run full test suite**

```bash
lute run test
```

**Expected:** All tests pass. No new errors.

**SUCCESS CRITERIA (A):**

- ✅ Storyteller PR merged with Object migration fix
- ✅ Storyteller version bumped and published
- ✅ Flipbook wally.toml updated
- ✅ UILabs Object story renders with ObjectControl UI
- ✅ ObjectControl selection updates story props
- ✅ `lute run test` passes

---

## SOLUTION B: ControlGroup UI (Requires Design Decision)

**GATE B.0: DESIGN DECISION GATE (Do Not Proceed Without Approval)**

**This gate is a decision point, not a code gate.** Before implementing ControlGroup support, you MUST:

1. **Read the vault spec** (from briefing): `engineering/story-controls/index.md` in `flipbook-docs` branch discusses grouping approach.
2. **Answer the design questions:**
   - Will Flipbook support ControlGroup as a first-class feature?
   - Will grouping be collapsible in the UI?
   - Will the migration flatten or preserve groups?
3. **Get stakeholder buy-in.** This is a significant schema change affecting Storyteller and Flipbook.

**If the answer is "no, accept flattening,"** stop here and document in the vault: "ControlGroup nesting is intentionally flattened during UILabs → Flipbook migration; grouping UI is out of scope."

**If the answer is "yes, preserve grouping,"** proceed to B.1.

---

**[If pursuing ControlGroup, gates B.1–B.5 would follow the same cross-repo pattern as Solution A: design spec → Storyteller schema change → Flipbook UI component → tests. Omitted here for brevity, but same discipline applies.]**

---

## SOLUTION C: New Data Types (UDim2, Vector3)

**GATE C.1: Verify Storyteller has constructors**

**Run:**

```bash
grep -n "createUDim2Control\|createVector3Control" Packages/_Index/flipbook-labs_storyteller@1.12.0/storyteller/dist/controls/ControlTypes.luau
```

**Expected:** Lines showing function definitions, or "no matches" if not yet in Storyteller.

**Branch Decision:**

- **If functions exist:** Proceed to C.2 (implement Flipbook UI).
- **If functions don't exist:** Storyteller needs the constructors first. (Likely they're not yet shipped in 1.12.0; check vault spec for timeline.)

**GATE C.2: Implement UDim2Control in Flipbook**

Create `workspace/flipbook-core/src/StoryControls/ControlElements/UDim2Control.luau`:

```luau
local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local e = React.createElement
local useCallback = React.useCallback

export type Props = {
    controlSchema: Storyteller.UDim2Control,
    controlValue: UDim2,
    onChanged: (UDim2) -> (),
}

local function UDim2Control(props: Props)
    local currentValue = props.controlValue or props.controlSchema.default or UDim2.new()

    local onScaleChanged = useCallback(function(newScale: number)
        local newValue = UDim2.new(newScale, currentValue.Offset.X, 0, currentValue.Offset.Y)
        props.onChanged(newValue)
    end, { currentValue, props.onChanged } :: { unknown })

    local onOffsetChanged = useCallback(function(newOffset: number)
        local newValue = UDim2.new(currentValue.Scale.X, newOffset, currentValue.Scale.Y, 0)
        props.onChanged(newValue)
    end, { currentValue, props.onChanged } :: { unknown })

    return e(Foundation.View, {
        tag = "auto-y col gap-small",
    }, {
        ScaleLabel = e(Foundation.Text, {
            LayoutOrder = 1,
            Text = "Scale: " .. currentValue.Scale.X,
            tag = "text-label-small",
        }),
        ScaleInput = e(Foundation.TextInput, {
            LayoutOrder = 2,
            Value = tostring(currentValue.Scale.X),
            onChanged = function(value)
                local num = tonumber(value) or 0
                onScaleChanged(num)
            end,
            tag = "size-full-x",
        }),
        OffsetLabel = e(Foundation.Text, {
            LayoutOrder = 3,
            Text = "Offset: " .. currentValue.Offset.X,
            tag = "text-label-small",
        }),
        OffsetInput = e(Foundation.TextInput, {
            LayoutOrder = 4,
            Value = tostring(currentValue.Offset.X),
            onChanged = function(value)
                local num = tonumber(value) or 0
                onOffsetChanged(num)
            end,
            tag = "size-full-x",
        }),
    })
end

return React.memo(UDim2Control)
```

**Add to StoryControlRow.luau** (type dispatch):

```luau
elseif controlType == ControlType.UDim2 then
    controlElement = e(UDim2Control, {
        controlSchema = props.control :: Storyteller.UDim2Control,
        controlValue = controlValue :: UDim2,
        onChanged = setControl,
    })
```

**GATE C.3: Implement Vector3Control**

Same pattern as UDim2Control, but with three inputs (X, Y, Z).

**GATE C.4: Write specs for UDim2 and Vector3**

Create `workspace/flipbook-core/src/StoryControls/ControlElements/UDim2Control.spec.luau`:

```luau
local jest = require("@pkg/JestGlobals")
local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local UDim2Control = require("@root/StoryControls/ControlElements/UDim2Control")

local expect = jest.expect
local it = jest.it
local describe = jest.describe

describe("UDim2Control", function()
    it("should render UDim2 input fields", function()
        local controlSchema = Storyteller.createUDim2Control(UDim2.new(0.5, 10, 0.3, 20))
        local onChanged = jest.fn()

        local element = React.createElement(UDim2Control, {
            controlSchema = controlSchema,
            controlValue = UDim2.new(0.5, 10, 0.3, 20),
            onChanged = onChanged,
        })

        expect(element).toBeTruthy()
    end)
end)
```

**GATE C.5: Add examples to StoryControls.story.luau**

Add UDim2 and Vector3 controls to the comprehensive example story.

**Run tests:**

```bash
lute run test --filter "UDim2Control|Vector3Control"
```

**Expected:** Specs pass.

**SUCCESS CRITERIA (C):**

- ✅ UDim2Control component added; spec passes
- ✅ Vector3Control component added; spec passes
- ✅ StoryControlRow type dispatch includes both types
- ✅ StoryControls.story.luau has examples
- ✅ `lute run test` passes

---

## SOLUTION D: CheckControl Grid Layout

**GATE D.1: Check Foundation grid support**

**Run:**

```bash
grep -n "grid" workspace/flipbook-core/src/StoryControls/ControlElements/CheckControl.luau
```

**Expected:** Current tag is `"size-full-y auto-x col gap-small"` (vertical column).

**Read Foundation docs** (in Flipbook or Wally):

```bash
grep -A 5 "grid" Packages/_Index/*/Foundation/src/Component.luau | head -20
```

**Decision:** If Foundation supports grid tag (e.g., `"auto-y grid gap-small"` or `"grid cols-4"`), proceed to D.2.

**GATE D.2: Update CheckControl**

Change the `return e(Foundation.View` statement in CheckControl.luau from:

```luau
return e(Foundation.View, {
    tag = "size-full-y auto-x col gap-small",
}, checkboxes)
```

To:

```luau
return e(Foundation.View, {
    tag = "size-full-y auto-x grid gap-small cols-4",  -- 4-column grid (adjust if needed)
}, checkboxes)
```

**Verify no spec exists for CheckControl layout:**

```bash
find . -name "*CheckControl*.spec*" -type f
```

**Expected:** No spec for CheckControl. (Only logic to test is toggle logic, which is tested in createStoryControlsStore.spec.luau.)

**GATE D.3: Visual test**

Create a test story with CheckControl having 8+ items:

```luau
local Storyteller = require("@pkg/Storyteller")
local React = require("@pkg/React")

local e = React.createElement

local items = {}
for i = 1, 8 do
    table.insert(items, "Option " .. i)
end

local story: Storyteller.Story = {
    controls = {
        multiCheck = Storyteller.createCheckControl(items),
    },
    story = function(props)
        return React.createElement("TextLabel", {
            Text = "Checked: " .. table.concat(props.controls.multiCheck, ", "),
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = Color3.fromRGB(240, 240, 240),
            TextColor3 = Color3.fromRGB(0, 0, 0),
            TextWrapped = true,
        })
    end,
}

return story
```

**Build and open:**

```bash
lute run build plugin --channel dev
# Open Flipbook in Studio; navigate to test story
# Inspect CheckControl in controls panel
```

**Expected:** Checkboxes render in a 4-column grid (or whatever column count you set), not vertical stack.

**SUCCESS CRITERIA (D):**

- ✅ CheckControl renders grid layout (not vertical stack)
- ✅ Grid is responsive; looks good with 4–12 items
- ✅ Toggle behavior still works (clicking checkbox checks/unchecks)
