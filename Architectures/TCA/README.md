# TCA (The Composable Architecture)

**Status:** ✅ implemented (requires the package dependency — see below)

The same unidirectional idea as the MVI sample, but industrialized: composable
reducers, effects, dependency injection designed for testing, and navigation tools.

> **Setup:** add the package via **File → Add Package Dependencies** →
> `https://github.com/pointfreeco/swift-composable-architecture`.
> The app target does not build until this dependency is added.

## Structure

- `TCAModule.swift` — namespace, metadata, module entry; creates the `Store`
  with `withDependencies` injecting the showcase repository
- `TodoList/TodoListFeature.swift` — `@Reducer` feature + the repository registered
  as a `DependencyKey`
- `TodoList/TodoListView.swift` — renders state; bindings use `.sending(_:)` to turn
  edits into actions
- `AddEditTodo/AddEditTodoFeature.swift` — child feature reporting through delegate actions
- `AddEditTodo/AddEditTodoView.swift` — the form

## What to notice (compare line by line with the MVI sample)

- The reducer is the same pure function you wrote by hand in MVI — the library
  just standardizes effects, composition and testing around it
- Navigation as state: `@Presents var addEdit` + `.ifLet` + `sheet(item: $store.scope(…))` —
  no coordinator, no router object
- Child→parent communication via delegate actions (`.delegate(.savedTodo(…))`) —
  the same idea as VIPER's module output, formalized
- `@Dependency(\.todoRepository)` + `withDependencies` in `TCAModule.makeRoot` —
  the injection seam tests use to swap in a mock (see `TestStore` in TCA docs)
- The price: a build-time dependency on a third-party library with its own release cadence
