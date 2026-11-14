# TCA (The Composable Architecture)

**Status:** planned

The same unidirectional idea as the MVI sample, but industrialized: composable
reducers, effects, dependency injection designed for testing, and navigation tools.

> When implementing: add the package via
> **File → Add Package Dependencies** → `https://github.com/pointfreeco/swift-composable-architecture`

## Planned structure

- `TCAModule.swift` — namespace, metadata, module entry
- `TodoList/TodoListFeature.swift` — `State`, `Action`, reducer body, repository as a dependency
- `TodoList/TodoListView.swift` — SwiftUI view over the store
- `AddEditTodo/AddEditTodoFeature.swift` + view

## What to notice

- Compare line by line with the MVI sample: what the library actually buys you
- Effects and `@Dependency` — testing with a mocked repository
- Feature composition and state sharing between parent and child features
