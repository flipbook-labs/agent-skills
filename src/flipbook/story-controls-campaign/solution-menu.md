# Story Controls: Solution Menu

The four candidate solutions for the story controls campaign, ranked by evidence, scope, and risk. PHASE 2 of [`SKILL.md`](SKILL.md) sends you here to choose a path, and [`implementation-gates.md`](implementation-gates.md) holds the gates that implement whichever one you choose.

## SOLUTION A: Fix Storyteller UILabs Object Migration (HIGH CONFIDENCE, LOW EFFORT)

**Scope:** ~5-line change in Storyteller package (not Flipbook). Storyteller 1.12.0 is pinned in `wally.toml`.

**Evidence:**

- Storyteller already defines `ObjectControl` type (ControlTypes.luau in Storyteller dist)
- Flipbook has ObjectControl UI (InstancePicker extraction in PR #597)
- UILabs.Advanced.Object("ModuleScript") just needs default = nil (typeclass filter is UILabs-only; Flipbook doesn't use it)
- InstancePicker handles nil gracefully; displays "Select an Instance..."

**Implementation Path:**

1. **Locate Storyteller's migrateUILabsControl.luau:**

   ```bash
   MIGRATION_FILE="Packages/_Index/flipbook-labs_storyteller@1.12.0/storyteller/dist/controls/migrations/ui-labs-v2.4.2/migrateUILabsControl.luau"
   grep -n "Object" "$MIGRATION_FILE" | head -5
   ```

   **Expected:** Shows lines with `control.Type == "Object"` returning `nil`.

2. **Cross-repo workflow (important):**
   - This fix goes in the **Storyteller repo** (`flipbook-labs/storyteller`), not Flipbook.
   - After fix in Storyteller, version bump needed (e.g., 1.12.1).
   - Flipbook updates `wally.toml` to new Storyteller version.
   - Use `test-dependencies` to verify the fix works in Flipbook before releasing.

3. **The actual fix (in Storyteller, not here):**
   - Change line from `return nil` to:
     ```luau
     elseif control.Type == "Object" then
         local migrated: ObjectControl = {
             type = ControlType.Object,
             default = nil,
         }
         return migrated
     ```
   - Add `ObjectControl` type import at top if missing.
   - Write test in Storyteller validating UILabs Object → Storyteller ObjectControl round-trip.

**Obligations:**

- Depends on Flipbook having ObjectControl UI ✅ (exists in main)
- Storyteller version bump + wally.toml update
- Test in Storyteller validating migration

**Risks:** LOW. ObjectControl is already in main; migration is straightforward 1-to-1 conversion.

**Unverified:** Whether UILabs.Advanced.Object("ModuleScript") typeclass parameter should be stored as metadata; Flipbook doesn't use it, but storing it could enable future filtering.

**Success Criteria (Phase 3):**

- Storyteller fix merged; version bumped
- Flipbook wally.toml updated to new Storyteller version
- `lute run test` passes
- Write a UILabs Object story; verify ObjectControl appears in Flipbook UI
- Interact with ObjectControl; verify selection updates story props

---

## SOLUTION B: Design & Implement ControlGroup UI (MEDIUM CONFIDENCE, HIGH COMPLEXITY)

**Scope:** Flipbook + Storyteller design decision. Not a simple feature.

**Evidence:**

- ControlGroup is a UILabs feature: groups controls under collapsible headers
- Storyteller migration flattens ControlGroup intentionally (simpler for non-grouping authors)
- Flipbook has NO ControlGroup UI at all; no grouping/collapsing
- PR #465 comment: "UILabsControls story broken → becomes #577" (never resolved)

**Key Design Questions (must decide before implementing):**

1. **Should ControlGroup be a first-class Flipbook feature?** Currently it's not. UILabs stories with grouping render as flat lists.
2. **How to represent groups in Storyteller schema?** Current schema is flat dict. Supporting nesting requires:
   - Schema type change to allow `dict<string, Control | ControlGroup>`
   - UI component to render visual grouping (collapsible section, visual border, etc.)
   - Store logic for group collapse/expand state
3. **Backward compatibility?** Migration flattening is intentional. Changing it requires coordination with Storyteller maintainers.

**Candidate Design Option: Preserve Grouping (Don't Flatten):**

- In Storyteller: new ControlGroup type in schema union
- In Flipbook: render groups as Foundation.Card or collapsible section with child controls nested
- Store: track collapse state per group
- Migration: don't flatten; preserve nested structure

**Candidate Design Option: Document Flattening (Status Quo):**

- Accept that UILabs grouping is lost in translation
- Document this as known limitation
- Focus effort elsewhere (other control types, better UX for individual controls)

**Obligations (if pursuing):**

- Design spec (when to group, visual language, interaction model)
- Storyteller schema change + version bump
- Flipbook UI component for grouping + store state
- Documentation & examples for authors
- Migration compatibility story (what happens to existing flat schemas?)

**Risks:** HIGH complexity. May require Storyteller major version bump. Scope creep risk. Only one UILabs-compatible storybook uses this feature in repo evidence.

**Unverified:** Whether grouping is a real need (only UILabs stories use it; no community requests found in issues/discussions).

**Success Criteria (Phase 3, if pursued):**

- Design spec reviewed and approved (by maintainer or team lead)
- Storyteller PR merged with ControlGroup schema support
- Flipbook UI component renders grouping correctly
- `lute run test` passes
- Write a UILabs ControlGroup story; verify groups render and collapse/expand works
- Verify backward compat: flat schema still works

---

## SOLUTION C: New Control Data Types (HIGH CONFIDENCE, MODERATE COMPLEXITY)

**Scope:** Flipbook + Storyteller. The controls revamp spec in the Obsidian vault (unmerged `flipbook-docs` branch; list files with `git ls-tree -r --name-only flipbook-docs -- docs/obsidian-vault`, read via `git show flipbook-docs:<path>`) targets Color3, DateTime, UDim2, Vector3.

**Evidence:**

- Storyteller already has type definitions for these (ControlTypes.luau)
- Flipbook has UI for Color3 (ColorControl), DateTime (DateControl) ✅
- UDim2, Vector3 are planned but not yet implemented
- Vault spec lists acceptance criteria per type

**Data Types from Vault Spec:**

| Type     | Status                    | Notes                           |
| -------- | ------------------------- | ------------------------------- |
| Color3   | ✅ Shipped (ColorControl) | Flipbook UI exists              |
| DateTime | ✅ Shipped (DateControl)  | Flipbook UI exists              |
| UDim2    | ⚠ Candidate               | Needs CSV input UI + validation |
| Vector3  | ⚠ Candidate               | Needs CSV input UI + validation |

**Implementation Path (per type):**

1. **UDim2:** `{Scale, Offset}` as two separate number inputs or one CSV field.
   - Acceptance: story with UDim2 control renders; Flipbook shows UI; selecting value updates story props
   - Component needed: two NumberControl inputs or custom CSVInput → UDim2 parser
2. **Vector3:** `{X, Y, Z}` as three NumberControl inputs or one CSV field.
   - Acceptance: story with Vector3 control renders; Flipbook shows UI; value updates story props
   - Component needed: three NumberControl inputs or CSVInput → Vector3 parser

**Obligations:**

- Storyteller: verify control constructors exist (createUDim2Control, createVector3Control)
- Flipbook: add UDim2Control, Vector3Control components
- Tests: spec for each new control type validating schema → UI → story props round-trip
- Vault spec says each type needs "acceptance criteria": those become test assertions

**Risks:** MODERATE. Simple 1-to-1 component mapping (like ObjectControl → InstancePicker). Risk if Storyteller constructors don't exist or have different names.

**Success Criteria (Phase 3):**

- UDim2Control component added; spec written
- Vector3Control component added; spec written
- `lute run test` passes all new specs
- StoryControls.story.luau updated with UDim2 + Vector3 examples
- Verify each control renders, accepts input, updates story props

---

## SOLUTION D: CheckControl Grid Layout (HIGH CONFIDENCE, LOW EFFORT)

**Scope:** Flipbook only, ~15-line change.

**Evidence:**

- TODO explicitly in codebase (grep `TODO: Make this a grid` in CheckControl.luau)
- Current UI is vertical stack; many checkbox items are cramped
- Foundation.View with grid tag (`tag="auto-y grid gap-small"` or similar) can fix it

**Implementation Path:**

1. Change CheckControl.luau (grep `return e(Foundation.View`) from:

   ```luau
   return e(Foundation.View, {
       tag = "size-full-y auto-x col gap-small",
   }, checkboxes)
   ```

   to something like:

   ```luau
   return e(Foundation.View, {
       tag = "size-full-y auto-x grid gap-small",
   }, checkboxes)
   ```

   (Exact tag depends on Foundation's grid support; verify in Foundation.View docs.)

2. Test with CheckControl story having 8+ items; verify they lay out in grid, not vertical stack.

**Obligations:**

- Verify Foundation grid tag syntax (read Foundation.View component)
- Visual test: story with many CheckControl items

**Risks:** LOW. Purely UI layout; no logic changes. May need to adjust padding/gaps if grid looks wrong.

**Success Criteria (Phase 3):**

- CheckControl renders checkboxes in grid layout (not vertical stack)
- `lute run test` passes
- Visual inspection: grid layout looks good with 4–12 items
