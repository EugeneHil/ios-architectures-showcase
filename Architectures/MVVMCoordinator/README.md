# MVVM + Coordinator

**Status:** ✅ implemented

Same view models as plain MVVM, but coordinators own navigation and module wiring:
view models stop knowing which screens exist.

## Structure

- `MVVMCoordinatorModule.swift` — namespace, metadata, module entry
- `Coordinators/Coordinator.swift` — the flow-owner protocol
- `Coordinators/TodoListCoordinator.swift` — builds VM + VC, routes to add/edit, feeds results back
- `Coordinators/AddEditTodoCoordinator.swift` — child flow: presents the form, dismisses, reports back
- `TodoList/TodoListViewModel.swift` — pure data state machine, **no navigation output**
- `TodoList/TodoListViewController.swift` — renders state; reports user actions via closures set by the coordinator
- `AddEditTodo/…` — form VM/VC, same as the plain MVVM sample (coordinators change who presents, not the form)

## What to notice (vs the plain MVVM sample)

- The view model has no `events` publisher — navigation decisions left the VM entirely
- The VC no longer builds or presents the form; it only reports taps through coordinator-owned closures
- Child coordinator lifecycle: held in the parent's `childCoordinators`, removed on finish
- Lifetime: the screen keeps the coordinator alive via its closures; in a real app the scene
  delegate or a parent coordinator owns it — be ready to explain this in an interview
- Interview story: coordinators make flows reusable and deep-linkable, and remove UIKit knowledge from view models
