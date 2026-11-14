# MVVM + Coordinator

**Status:** planned

Same view models as plain MVVM, but coordinators own navigation and module wiring:
view models stop knowing which screens exist.

## Planned structure

- `MVVMCoordinatorModule.swift` — namespace, metadata, module entry
- `Coordinators/AppCoordinator.swift` — root flow
- `Coordinators/TodoListCoordinator.swift`, `Coordinators/AddEditTodoCoordinator.swift`
- View models / view controllers (no navigation code inside)

## What to notice

- Navigation decisions live in coordinators, not in view models or VCs
- How a coordinator builds and wires a VC + VM pair
- What deep linking and flow reuse look like compared to ad hoc pushes
