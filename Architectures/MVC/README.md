# MVC (Apple)

**Status:** ✅ implemented

The view controller owns the view, input handling, navigation, formatting and data
loading — the baseline every other sample in this repo is compared against.

## Structure

- `MVCModule.swift` — namespace, metadata, module entry
- `TodoList/TodoListViewController.swift` — table, search, repository calls, formatting, navigation
- `AddEditTodo/AddEditTodoViewController.swift` — self-contained form with its own validation

## What to notice

- Count the responsibilities in `TodoListViewController`: view setup, data loading,
  business rules (insert-or-update), filtering, formatting, navigation, error handling
- There is no seam for testing: logic talks directly to UIKit and to the repository
  from inside the same object
- The classic data source API (no diffable snapshot) — how UIKit apps were written for a decade
- That for one screen it is perfectly fine — the "Massive View Controller" trouble starts
  when this object keeps growing; every other sample in this repo is a way out
