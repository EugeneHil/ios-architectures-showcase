# MVC (Apple)

**Status:** planned

The view controller owns the view, input handling, navigation and most presentation
logic — the baseline every other sample in this repo is compared against.

## Planned structure

- `MVCModule.swift` — namespace, metadata, module entry
- `TodoList/TodoListViewController.swift` — table, search, repository calls
- `AddEditTodo/AddEditTodoViewController.swift` — form screen

## What to notice

- Where business rules end up living as the screen grows
- The testing story (or lack of it) when logic is glued to the view controller
- That for one simple screen it is genuinely fine — know when to stop apologizing for MVC
