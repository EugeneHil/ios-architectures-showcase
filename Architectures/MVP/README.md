# MVP

**Status:** planned

Presentation logic moves into a plain presenter; the view controller becomes a passive
view driven through a protocol. No reactive bindings — the point is explicit two-way
protocol communication.

## Planned structure

- `MVPModule.swift` — namespace, metadata, module entry
- `TodoList/TodoListViewController.swift` — passive view conforming to `TodoListViewProtocol`
- `TodoList/TodoListPresenter.swift` — formats data, owns no UIKit
- `AddEditTodo/…` — same trio

## What to notice

- The presenter never imports UIKit — how far that promise holds in practice
- Who initiates what: view → presenter → view callback
- Testing the presenter with a mocked view
