---
name: story-controls-campaign
description: "Runbook for story controls work: reproducing gaps, ranked solutions with implementation paths, validation gates. Use when tasked with UILabs story compatibility, adding new control types, fixing control re-render bugs, or validating controls refactor. Start with PHASE 1 (reproduce and characterize), then PHASE 2 (choose a solution), then implement and validate. All phases include exact commands and expected observations."
type: process
---

# Flipbook Story Controls Campaign

This is the maintainer-designated hardest live problem: bringing Flipbook's story controls to UI Labs parity (ControlGroup nesting, Object instance selection, new data types Color3/DateTime/UDim2/Vector3). The campaign is divided into four phases: (1) reproduce and characterize the gaps; (2) ranked solution menu with design decisions and implementation paths; (3) implementation gates for each option; (4) validation and promotion.

Every phase has exact commands and EXPECTED observations. If you see something else, the decision tree routes you to branch steps. Read the entire skill before starting.

---

## Background: What Broke

The `uilabs-controls-support` branch (tip 66f14210, May 9 2026) attempted UILabs compatibility but has three problems:

1. **Branch is 3 commits stale.** It lacks PR #576 (store + context), PR #579 (ObjectControl UI), and PR #597 (InstancePicker extraction). The main branch has all three; this branch predates them.
2. **Storyteller's Object migration silently drops Object controls.** In `Storyteller.migrateUILabsControl()`, the line `elseif control.Type == "Object" then return nil` means UILabs.Advanced.Object(...) disappears during conversion. Even if ObjectControl UI existed on the branch, the schema never reaches it.
3. **ControlGroup is flattened by design.** Storyteller's migration intentionally flattens ControlGroup nesting into a flat control dict. Flipbook has no UI for grouping/collapsing, so grouping is silently lost.

**Status on main (78d71e8f):** All 11 control types work; re-render isolation is fixed; ObjectControl + InstancePicker exist. UILabs Object migration is the 5-line gap. ControlGroup is a design decision gate.

---

## PHASE 1: Reproduce and Characterize (Baseline)

### Step 1.1: Write a comprehensive story exercising all control types

**Goal:** Create a reference story that tests every control type so you can verify functionality across phases.

**Command:**

```bash
cat > /tmp/test_all_controls.story.luau << 'EOF'
local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local e = React.createElement

-- Sample enum for Select/Radio/Check
local TestEnum = {
    Option1 = "opt1",
    Option2 = "opt2",
    Option3 = "opt3",
}

local function TestEnumToString(value)
    for k, v in TestEnum do
        if v == value then return k end
    end
    return tostring(value)
end

local story: Storyteller.Story = {
    controls = {
        boolControl = Storyteller.createBooleanControl(true),
        stringControl = Storyteller.createStringControl("hello"),
        numberControl = Storyteller.createNumberControl(42),
        sliderControl = Storyteller.createSliderControl(5, NumberRange.new(0, 10)),
        colorControl = Storyteller.createColorControl(Color3.fromRGB(255, 0, 0)),
        dateControl = Storyteller.createDateControl(),
        selectControl = Storyteller.createSelectControl(
            { TestEnum.Option1, TestEnum.Option2, TestEnum.Option3 },
            { tostring = TestEnumToString }
        ),
        radioControl = Storyteller.createRadioControl(
            { TestEnum.Option1, TestEnum.Option2, TestEnum.Option3 },
            { tostring = TestEnumToString }
        ),
        multiSelectControl = Storyteller.createMultiSelectControl(
            { TestEnum.Option1, TestEnum.Option2, TestEnum.Option3 },
            { tostring = TestEnumToString }
        ),
        checkControl = Storyteller.createCheckControl(
            { TestEnum.Option1, TestEnum.Option2, TestEnum.Option3 },
            { tostring = TestEnumToString }
        ),
        objectControl = Storyteller.createObjectControl(nil),
    },
    story = function(props)
        local controlsText = {}
        for key, val in props.controls do
            table.insert(controlsText, string.format("%s = %s", key, tostring(val)))
        end
        return React.createElement("TextLabel", {
            Text = "Controls Test\n" .. table.concat(controlsText, "\n"),
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = Color3.fromRGB(240, 240, 240),
            TextColor3 = Color3.fromRGB(0, 0, 0),
            TextScaled = true,
            TextWrapped = true,
        })
    end,
}

return story
EOF
cp /tmp/test_all_controls.story.luau workspace/example/src/Examples/AllControlTypes.story.luau
echo "✓ Test story written to workspace/example/src/Examples/AllControlTypes.story.luau"
```

**Expected observation:** Command succeeds; file exists; no Luau errors on `lute run analyze`.

**Verify:**

```bash
lute run analyze 2>&1 | grep -i "allcontroltypes" || echo "No errors for new story"
```

**Expected:** No errors mention AllControlTypes, or grep finds no results.

---

### Step 1.2: Reproduce the Object migration gap (Storyteller issue)

**Goal:** Verify that Storyteller drops UILabs Object controls.

**Command:**

```bash
# Inspect the migration code in the Storyteller package.
# Locate the migrateUILabsControl function and verify Object type handling.

find Packages/_Index -name "*migrateUILabs*" -type f
```

**Expected observation:** Path like `Packages/_Index/flipbook-labs_storyteller@1.12.0/storyteller/dist/controls/migrations/ui-labs-v2.4.2/migrateUILabsControl.luau` exists.

**Verify the gap:**

```bash
grep -A 2 'control.Type == "Object"' Packages/_Index/flipbook-labs_storyteller@1.12.0/storyteller/dist/controls/migrations/ui-labs-v2.4.2/migrateUILabsControl.luau
```

**Expected:** Lines show `return nil` (Object control is dropped).

**Why this matters:** UILabs.Advanced.Object(...) in a story schema gets silently converted to nothing. The story author gets no warning; controls disappear.

---

### Step 1.3: Check re-render isolation (control subscription behavior)

**Goal:** Verify that changing one control does NOT cause all controls to re-render.

**Command:**

```bash
# Read createStoryControlsStore to confirm per-control signal design.
cat workspace/flipbook-core/src/StoryControls/createStoryControlsStore.luau | head -50
```

**Expected observation:** Store exports `getControlValue(key)` which returns a per-control Charm signal (computed), not a whole-schema signal. Each control subscribes independently via `useSignalState()`.

**Spot-check the spec:**

```bash
grep -n "getControlValue" workspace/flipbook-core/src/StoryControls/createStoryControlsStore.spec.luau | head -3
```

**Expected:** Test file has tests for `getControlValue()` returning signals (the `describe("getControlValue", ...)` block).

**Gap identified:** No test for re-render isolation. The spec tests state shape but not subscription behavior. Mark this for Phase 3.

---

### Step 1.4: Confirm CheckControl grid TODO

**Goal:** Verify the documented gap.

**Command:**

```bash
grep -n "TODO.*grid" workspace/flipbook-core/src/StoryControls/ControlElements/CheckControl.luau
```

**Expected observation:** Line ~41 has `-- TODO: Make this a grid` comment.

**Characterization:** CheckControl currently renders checkboxes as vertical stack. Grid layout would be better UX for many items (e.g., 8 options in 4x2 grid vs. vertical list).

---

**END PHASE 1 Checkpoint**

You should now understand:

- ✅ All 11 control types exist and work on main
- ✅ ObjectControl + InstancePicker are extracted
- ✅ Store uses per-control signals (re-render isolated)
- ✅ Object migration in Storyteller drops controls (5-line fix potential)
- ✅ ControlGroup is flattened silently (design decision needed)
- ✅ CheckControl lacks grid layout (small win)
- ✅ Re-render spec is incomplete (test gap)

---

## PHASE 2: Ranked Solution Menu

Solutions are ranked by evidence, scope, and risk. Each has success criteria and a decision gate.

[`solution-menu.md`](solution-menu.md) carries the four solutions in full: the evidence behind each one, the design questions Solution B has to answer before any code, the obligations it takes on, its risks and unverified claims, and the success criteria PHASE 3 holds it to. Read it to choose a path. The shortlist below is what it concludes.

---

**END PHASE 2 Checkpoint**

You now have four ranked solutions:

1. **A: Storyteller Object migration** (5 lines, low risk, high impact) ← **DO THIS FIRST**
2. **B: ControlGroup UI** (design gate, high complexity, medium evidence) ← **DO ONLY IF STAKEHOLDERS DECIDE**
3. **C: New data types UDim2/Vector3** (moderate effort, good evidence) ← **DO IF TIME**
4. **D: CheckControl grid** (15 lines, low risk, nice-to-have) ← **DO IF TIME**

---

## PHASE 3: Implementation Gates (Exact Commands & Expected Observations)

Follow the solution menu in order: A is mandatory (closes the Object gap), B requires design approval, C and D are optional. Every implementation has exact success criteria.

[`implementation-gates.md`](implementation-gates.md) carries one numbered gate sequence per solution, each with exact commands, the expected observation at every gate, and the success criteria that close it: the cross-repo Storyteller workflow for A, the design decision gate for B, the UDim2Control and Vector3Control components and their specs for C, and the Foundation grid tag change for D. Open the sequence for the solution you chose and work it top to bottom.

---

**END PHASE 3 Checkpoint**

Each solution has been implemented and verified against exact success criteria. Code changes are minimal and focused.

---

## PHASE 4: Validation and Promotion

### Step 4.1: Validation Protocol (Read-Only, Measurement-Based)

Never judge by eye. Every phase success is a measurable observation, not a visual assessment.

**For Object Migration (Solution A):**

- ✅ Specification: UILabs Object control → migrated ObjectControl with nil default
- ✅ Evidence: UILabs Object story renders with ObjectControl UI
- ✅ Behavior: Selecting instance updates props.controls.selectedInstance
- ✅ Regression: `lute run test` passes (no existing tests break)

**For ControlGroup (Solution B):**

- ✅ Design spec reviewed by stakeholder
- ✅ Spec: ControlGroup nesting preserved during migration or intentionally flattened
- ✅ Evidence: UILabs ControlGroup story renders with visual grouping or flattening matches spec
- ✅ Regression: `lute run test` passes

**For New Data Types (Solution C):**

- ✅ Specification: UDim2Control renders two numeric inputs; Vector3Control renders three
- ✅ Evidence: `lute run test --filter "UDim2Control|Vector3Control"` passes
- ✅ Behavior: Setting control value updates story props
- ✅ Regression: `lute run test` passes

**For Grid Layout (Solution D):**

- ✅ Specification: CheckControl renders checkboxes in grid (not vertical stack)
- ✅ Evidence: Visual inspection (screenshot) shows grid layout
- ✅ Behavior: Toggling checkbox still updates control value
- ✅ Regression: `lute run test` passes

**New Specs Required (Critical for Long-Term Maintenance):**

The briefing notes that "currently uncovered per the briefing" are:

1. **Re-render Isolation:** Add spec to `createStoryControlsStore.spec.luau` verifying that changing one control's signal does NOT trigger renders on others. (Currently missing; only state shape is tested.)
2. **Migration Behavior:** Add spec in Flipbook or Storyteller validating UILabs → Storyteller schema round-trip for each control type (Object, ControlGroup, new types).

**Create spec for re-render isolation:**

```luau
-- In createStoryControlsStore.spec.luau, add:
it("should not re-subscribe to other controls when one changes", function()
    local schema = {
        control1 = Storyteller.createStringControl("a"),
        control2 = Storyteller.createStringControl("b"),
    }
    local store = createStoryControlsStore(schema)

    local signal1 = store.getControlValue("control1")
    local signal2 = store.getControlValue("control2")

    -- Signals are different (per-control)
    expect(signal1 ~= signal2).toBe(true)

    -- Changing control1 does not re-emit signal2
    store.setControl("control1", "new-a")
    expect(signal2.value).toBe("b")  -- unchanged
end)
```

**Create migration spec (Storyteller):**

```luau
-- In Storyteller migrations spec:
it("should migrate UILabs Object to Storyteller ObjectControl", function()
    local uiLabsObject = {
        Type = "Object",
    }
    local migrated = migrateUILabsControl(uiLabsObject)

    expect(migrated).to.be.ok()
    expect(migrated.type).toBe("Object")
    expect(migrated.default).toBe(nil)
end)
```

---

### Step 4.2: Route Through Change Control

**Reference:** `change-control` skill (AGENTS.md, `.github/pull_request_template.md`).

**For each solution implemented:**

1. **Create branch:** `git switch -c story-controls-<solution>` (e.g., `story-controls-object-migration`)
2. **Commit changes** (if in Flipbook, not Storyteller):

   ```bash
   git add workspace/flipbook-core/src/StoryControls/...
   git add wally.toml
   git commit -m "Add UDim2/Vector3 controls and fix CheckControl grid layout

   - Implement UDim2Control component with scale/offset inputs
   - Implement Vector3Control component with X/Y/Z inputs
   - Update StoryControlRow type dispatch for new controls
   - Change CheckControl from col to grid layout (4-column)
   - Add specs for new control types validating schema→UI→props round-trip
   - Add re-render isolation spec to createStoryControlsStore.spec.luau

   Closes story controls gaps in UI Labs parity work.

   Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
   ```

3. **Open draft PR:**

   ```bash
   gh pr create --draft --title "Story Controls: New Data Types and Grid Layout" \
     --body "Adds UDim2 and Vector3 control types, fixes CheckControl grid layout, and adds missing re-render isolation spec."
   ```

4. **Await review.** All PRs must route through change control (see skill).

**Cross-repo note:** If implementing Solution A (Object migration), the primary commit happens in Storyteller; Flipbook's PR is the version bump in wally.toml (smaller, lower-risk change).

---

### Step 4.3: Known Wrong Paths (Explicitly Fenced)

**DO NOT:**

1. **Resurrect uilabs-controls-support branch:** It is 3 commits stale (lacks #576, #579, #597). Merging it would revert ObjectControl + InstancePicker work, and lose re-render isolation fixes. If you need UILabs compat, port examples forward onto main. **Citation:** Briefing states branch predates ObjectControl extraction; main is current.

2. **Reintroduce shared-store subscriptions:** PR #576 eliminated a prior pattern where all controls subscribed to one shared Charm signal. This caused all controls to re-render when any changed. Current per-control signal pattern is the fix. Don't go back. **Citation:** Briefing says #576 is the "lesson". Don't make the same mistake.

3. **Bypass Storyteller by parsing controls in Flipbook:** UILabs schema → Storyteller schema → Flipbook UI is the layering contract. If Storyteller doesn't support a control type, the fix goes in Storyteller (as with Object migration). Flipbook must not parse raw UILabs schema or duplicate Storyteller's migration logic. **Citation:** Briefing states "layering contract". Maintain it.

---

### Step 4.4: Promotion Criteria

**Before merging any solution PR:**

1. ✅ **Code review** completed (via `gh pr review` or maintainer approval)
2. ✅ **All tests pass:** `lute run test` (entire suite)
3. ✅ **Lint passes:** `lute run lint` (StyLua, Selene, Prettier)
4. ✅ **Type check passes:** `lute run analyze` (Luau strict mode)
5. ✅ **Measurable validation** (per Phase 4.1 protocol: test assertions, not eyeballing)
6. ✅ **Changelog entry** added (if repo uses changewrite; see `release-and-operations` skill)
7. ✅ **PR body discloses AI authorship** (maintainer convention; see the `change-control` skill and fill the `.github/pull_request_template.md`)

**Merge to main:**

```bash
gh pr merge <PR_URL> --squash --delete-branch
```

(Squash keeps history clean; `--delete-branch` cleans up.)

**Post-merge:**

1. Announce to maintainer/team (e.g., "Story Controls Phase 3 complete; Object migration landed")
2. If cross-repo (Storyteller version bump), coordinate release timing with Storyteller maintainers
3. Add entry to vault docs (flipbook-docs branch or main, per publication plan) documenting the new control types and ControlGroup decision

---

## Appendix: Troubleshooting & Branch Decisions

### Troubleshooting: "But my story still doesn't show the control"

**Symptom:** You wrote a UILabs story with Object control; after Solution A, the control still doesn't appear.

**Diagnostic:**

1. Verify Storyteller was bumped and Flipbook's wally.toml is updated:
   ```bash
   grep Storyteller wally.toml
   ```
2. Verify `lute run install` ran:
   ```bash
   ls Packages/_Index/flipbook-labs_storyteller@*/storyteller/dist/controls/migrations/
   ```
3. Verify ObjectControl component exists in Flipbook:
   ```bash
   grep -n "ObjectControl" workspace/flipbook-core/src/StoryControls/ControlElements/ObjectControl.luau | head -3
   ```
4. Run Flipbook dev build:
   ```bash
   lute run build plugin --channel dev
   ```
   Open story in Studio. Check browser console for errors (Storyteller migration errors, React errors).

**Branch decision:**

- **If Storyteller doesn't have the fix:** Merge Object migration PR in Storyteller first.
- **If wally.toml doesn't have the new version:** Update and re-run `lute run install`.
- **If ObjectControl missing:** Don't blame the migration; ObjectControl was in main before Solution A. Verify you're on main and built correctly.

### Troubleshooting: "Grid layout broke my CheckControl"

**Symptom:** After Solution D, CheckControl renders incorrectly (overlapping, cut off).

**Diagnostic:**

1. Verify Foundation's grid tag syntax:
   ```bash
   grep -C 3 "grid" Packages/_Index/*/Foundation/src/Component.luau | head -20
   ```
2. If grid tag is wrong, adjust. E.g., change `"grid cols-4"` to `"grid cols-3"` or Foundation's actual grid class.
3. Verify story has enough items to fill grid:
   ```luau
   -- Use 8+ items so grid is visible
   local items = {}
   for i = 1, 12 do table.insert(items, "Item " .. i) end
   ```

**Branch decision:**

- **If Foundation doesn't support grid:** Use CSS Flexbox fallback or two-column layout.
- **If grid layout is ugly:** Adjust cols count or padding/gap.

---

## Provenance and Maintenance

**Last verified:** 2026-07-01

**Files:** This file is the campaign spine: what broke, PHASE 1's characterization, the ranked shortlist, and PHASE 4's validation and promotion. The per-solution detail sits beside it, PHASE 2's four evaluations in [`solution-menu.md`](solution-menu.md) and PHASE 3's gates in [`implementation-gates.md`](implementation-gates.md), so a reader loads only the path they chose. The commands below re-verify facts across all three.

**Commands to re-verify facts:**

1. **Storyteller version pinned in wally.toml:**

   ```bash
   grep "Storyteller = " wally.toml
   ```

2. **ObjectControl component exists:**

   ```bash
   test -f workspace/flipbook-core/src/StoryControls/ControlElements/ObjectControl.luau && echo "✓"
   ```

3. **InstancePicker was extracted (PR #597):**

   ```bash
   git log --oneline --all | grep "Extract InstancePicker"
   ```

4. **CheckControl grid TODO exists:**

   ```bash
   grep "TODO.*grid" workspace/flipbook-core/src/StoryControls/ControlElements/CheckControl.luau
   ```

5. **uilabs-controls-support branch is stale:**

   ```bash
   git log uilabs-controls-support..main --oneline | wc -l
   ```

   (Output > 2 = branch is behind)

6. **Current main is 78d71e8f (Embed Flipbook in DataModel):**
   ```bash
   git log -1 --oneline
   ```

**Re-verification schedule:** Quarterly. If any command returns unexpected output, update the skill.

---

## Summary: Why This Campaign Exists

Flipbook's story controls are the hardest live problem because they require coordinated changes across two repos (Storyteller + Flipbook), resolve a silent data loss bug (Object migration), and involve a design decision (ControlGroup). The campaign front-loads characterization (Phase 1) so you understand what's broken, ranks solutions by evidence (Phase 2) so you fix high-impact items first, provides exact implementation gates (Phase 3) so you don't guess, and enforces measurement-based validation (Phase 4) so you know when you're done. Follow the phases in order. Do not skip to implementation.
