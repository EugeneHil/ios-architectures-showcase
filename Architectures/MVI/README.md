# MVI (hand-rolled unidirectional store)

**Status:** planned

The SwiftUI view dispatches intents; a pure reducer folds them into a single immutable
state; the view is a function of that state. Written by hand, with no third-party
dependencies — stepping stone to understanding TCA.

## Planned structure

- `MVIModule.swift` — namespace, metadata, module entry
- `TodoList/TodoListState.swift` — one immutable state struct
- `TodoList/TodoListIntent.swift` — every user/system intent as an enum case
- `TodoList/TodoListStore.swift` — owns state, runs the reducer, executes effects
- `TodoList/TodoListView.swift` — dispatches intents, renders state
- `AddEditTodo/…` — same set

## What to notice

- One source of truth: debugging means logging state transitions
- Side effects stay out of the reducer — how the store runs them
- Reducer tests are trivial: `(state, intent) → state`
