---
name: charm-store-patterns
description: "The three Charm store shapes in the Flipbook / Storyteller / ModuleLoader family: owner-constructed factory modules, lazy singletons behind `get = Charm.computed(factory)`, and eager singletons behind `get = Charm.signal(create...())`, plus the consumer conventions (`useSignalState(XStore.get)` in React, `XStore.get()` elsewhere). Use when: adding or refactoring a store, choosing between lazy and eager construction, wiring store state into React, or reviewing code that creates or consumes a Charm store."
type: knowledge
---

# Charm Store Patterns

The Flipbook / Storyteller / ModuleLoader family keeps shared state in [Charm](https://github.com/littensy/charm) stores: plain module tables whose fields are Charm callables (signal getters and computeds) plus action functions. Three construction shapes recur across the family. Picking the wrong one produces bugs that no test catches loudly: a silently duplicated store, or an effect that never runs. This skill maps the shapes, the invariant each one carries, and how consumers read them.

A naming contract underlies all of it: in this family, a store field named `get` or `get<Noun>` is a Charm callable. Calling it reads the current value, and reading it inside a reactive context (a computed, an effect, `useSignalState`) subscribes that context. A reader who sees `XStore.getRecords` can pass it straight to `Charm.listen`, `Charm.observe`, or `useSignalState` without checking the implementation.

## Shape 1: factory module, constructed by an owner

The module returns a `create<X>Store` function (or a `<X>Store.new` constructor). An owner constructs the instance, holds its lifetime, and passes it down through a React context, a constructor argument, or a return value. Use this shape when more than one instance can exist, or when the store's lifetime belongs to something narrower than the module itself: a mounted panel, one Storyteller instance.

Exemplars:

- Flipbook `workspace/flipbook-core/src/StoryControls/createStoryControlsStore.luau`: one store per story with a controls schema. `StoryControlsContext` constructs it (grep `createStoryControlsStore(props.schema)`) and provides it through context.
- Flipbook `workspace/flipbook-core/src/Logs/LogsStore/createLogsStore.luau`: the factory for the log history store. Its owner is `LogsStore/init.luau`, which wraps it in shape 2. The shapes compose: the factory carries the construction logic, the singleton wrapper owns the lifetime.
- Storyteller `src/stores/StoryModuleRecordStore.luau` (`StoryModuleRecordStore.new`): the story-load record store. `StorytellerStore` constructs it (grep `StoryModuleRecordStore.new()`) and exposes its callables on itself.

## Shape 2: lazy singleton behind a computed

```luau
return {
	get = Charm.computed(createXStore),
}
```

Constructing the computed does no work. The factory runs on the first `get()` call, and the result caches for every later call because the computed is dependency-free: it read no Charm signals while it ran, so Charm never has a reason to re-run it.

That caching is the invariant to protect: **the factory must not read a Charm signal during construction.** A signal read makes the computed depend on that signal, and when the signal changes the computed re-runs and silently builds a second store. Nothing errors. Consumers that already resolved `get()` keep the detached first instance, and state diverges between them. Storyteller states the rule at the definition site (grep `Caching relies on this computed staying dependency-free` in `src/stores/StorytellerStore.luau`).

The shape also makes requiring the module free, which Storyteller depends on: sandboxed copies of Storyteller must stay inert at require time, and `StorytellerStore.luau` opens with a header comment stating so (grep `Requiring this module must do no work`). Default to this shape for any single shared store.

Exemplars:

- Flipbook `workspace/flipbook-core/src/Plugin/PluginStore/init.luau` (grep `Charm.computed(createPluginStore)`).
- Flipbook `workspace/flipbook-core/src/Logs/LogsStore/init.luau` (grep `Charm.computed(createLogsStore)`).
- Storyteller `StorytellerStore.get` in `src/stores/StorytellerStore.luau`, whose header comment explains the require-must-do-no-work requirement.

## Shape 3: eager singleton behind a signal

```luau
local get = Charm.signal(createXStore(...))

return {
	get = get,
}
```

The factory runs at module require time and the instance sits behind a plain signal. Reach for this only when lazy construction is wrong, and in this family that means one thing: the factory registers a `Charm.effect`. An effect must be registered at the top level, not while a computed is evaluating, so a factory that calls `Charm.effect` cannot run inside the shape 2 wrapper.

Both exemplars wrap `createPluginSettingsStore`, whose internal `Charm.effect` (grep `Charm.effect` in `workspace/flipbook-core/src/Plugin/createPluginSettingsStore.luau`) persists settings whenever they change, and both carry the same inline comment naming this constraint (grep `Initialize the store eagerly at module level`):

- Flipbook `workspace/flipbook-core/src/UserSettings/UserSettingsStore.luau`.
- Flipbook `workspace/flipbook-core/src/Plugin/LocalStorageStore.luau`.

Eager construction pays its cost in every environment that requires the module, so it never becomes the default. It is the escape hatch for the effect constraint.

## Choosing a shape

- More than one instance, or a lifetime owned by something else: factory module.
- One shared instance: lazy singleton.
- One shared instance whose factory registers a `Charm.effect`: eager singleton.

## Consumer conventions

In React, read a store through `useSignalState` from ReactCharm. The singleton `get` is itself a Charm callable, so resolving the store and reading one of its fields are two subscriptions, typically stacked:

```luau
local userSettingsStore = useSignalState(UserSettingsStore.get)
local userSettings = useSignalState(userSettingsStore.getStorage)
```

Everywhere else, call the callable directly: `PluginStore.get().getPlugin()`, `UserSettingsStore.get()`. Pass the callable itself, never a wrapping closure, to `Charm.listen`, `Charm.observe`, and `useSignalState`, so subscriptions attach to the real signal.

## When not to use

For why a sandboxed Storyteller copy must stay inert, and the debugging moves when it is not, read `flipbook/moduleloader-sandboxing` once it lands (see the volatile note below). For general Luau style in store code (naming, module shape, type discipline), read [`org/write-luau-code`](../../org/write-luau-code/SKILL.md).

---

## Provenance and Maintenance

**Date stamped:** 2026-07-19. Written from a survey of the family's live stores: Flipbook's StoryControls, LogsStore, PluginStore, UserSettingsStore, and LocalStorageStore, and Storyteller's StorytellerStore and StoryModuleRecordStore. The dependency-free-computed invariant and the require-must-do-no-work requirement come from the sandbox-inert Storyteller work in flipbook-labs/storyteller#147. The top-level-effect constraint comes from the settings stores' inline comments.

**Volatile:** as of the date stamp, the Storyteller exemplars sit on unmerged branches: `src/stores/StoryModuleRecordStore.luau` on `perf/store-story-loading`, and the `StorytellerStore.get` computed on `sandbox-inert-storyteller` (flipbook-labs/storyteller#147). The `flipbook/moduleloader-sandboxing` skill referenced above is pending in agent-skills#32. Once those merge, the references resolve and this note can go, and the sandboxing mention should become a relative link.

**Re-verify these claims when this skill next loads:**

- In Flipbook: `grep -rn "Charm.computed(createPluginStore)\|Charm.computed(createLogsStore)" workspace/flipbook-core/src` confirms the lazy singletons.
- In Flipbook: `grep -rln "Initialize the store eagerly at module level" workspace/flipbook-core/src` should list `UserSettingsStore.luau` and `LocalStorageStore.luau`.
- In Storyteller: `grep -n "Caching relies on this computed staying dependency-free" src/stores/StorytellerStore.luau` (on `sandbox-inert-storyteller` until PR #147 merges).
- In Flipbook: `grep -rn "useSignalState(" workspace/flipbook-core/src --include=*.luau` confirms the React consumer convention.
