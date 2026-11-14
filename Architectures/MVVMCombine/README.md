# MVVM + Combine

**Status:** planned

The view model exposes observable state and intent methods; the view controller binds
inputs and outputs with Combine and stays free of presentation logic.

## Planned structure

- `MVVMCombineModule.swift` — namespace, metadata, module entry
- `TodoList/TodoListViewModel.swift` — state publishers + intent methods
- `TodoList/TodoListViewController.swift` — binds via `cancellables`
- `AddEditTodo/AddEditTodoViewModel.swift` + view controller

## What to notice

- Binding direction: the view observes, the view model never knows about UIKit
- Loading/error states as part of the published state
- Testing the view model without a view controller in sight
