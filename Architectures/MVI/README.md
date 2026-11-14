# MVI (hand-rolled unidirectional store)

**Status:** ✅ implemented

The SwiftUI view dispatches intents; a pure reducer folds them into a single immutable
state; the view is a function of that state. Written by hand, with no third-party
dependencies — a stepping stone to understanding TCA.

## Structure

- `MVIModule.swift` — namespace, metadata, module entry
- `TodoList/TodoListState.swift` — one immutable state struct + the edit form as a slice of it
- `TodoList/TodoListIntent.swift` — every user/system intent as an enum case + declared effects
- `TodoList/TodoListStore.swift` — `dispatch` → pure `reduce` → `run` effects → results as new intents
- `TodoList/TodoListView.swift` — renders state; bindings are glue that dispatch intents
- `TodoList/EditTodoFormView.swift` — the sheet reading the same state

## What to notice

- One source of truth: list, search, loading, error **and navigation** (`editForm`) are state —
  presenting/dismissing a screen is just another transition
- The reducer is pure and static: `(state, intent) → (state, effects)` — trivially testable,
  trivially debuggable (log every intent + state)
- Side effects are declared, not executed, by the reducer; the store runs them and
  dispatches results back as system intents (`.todosLoaded`, `.failed`)
- SwiftUI bindings never mutate state directly — every `set` dispatches an intent
- The edit form has no view model of its own — it edits a slice of the same state;
  compare this single-store feel with the per-screen view models of the MVVM samples
