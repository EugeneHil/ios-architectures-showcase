# MVP

**Status:** ✅ implemented

Presentation logic moves into a plain presenter; the view controller becomes a passive
view driven through a protocol. No reactive bindings — the point is explicit two-way
protocol communication.

## Structure

- `MVPModule.swift` — namespace, metadata, module entry (wires view + presenter)
- `TodoList/TodoListContracts.swift` — view/presenter protocols
- `TodoList/TodoListPresenter.swift` — formats data, owns no UIKit
- `TodoList/TodoListViewController.swift` — passive view; forwards events, renders commands
- `AddEditTodo/AddEditTodoContracts.swift`, `AddEditTodoPresenter.swift`, `AddEditTodoViewController.swift`

## What to notice

- The presenter never imports UIKit — `TodoListPresenter.swift` has only `Foundation`
- Two-way protocols: the view reports events up, the presenter sends commands down
  (including `showAddTodo` / `close` — even navigation is presenter-decided, view-executed)
- Wiring lives outside both parties (`MVPModule.makeRoot`, `presentAddEdit`)
- The form's `render` nuance: fields already echo user input, so re-rendering drives
  only derived values — a real MVP papercut compared to MVVM bindings
- Compared to MVVM: no Combine at all, but more protocol ceremony on both sides
