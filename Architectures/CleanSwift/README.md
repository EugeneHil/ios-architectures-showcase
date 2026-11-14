# Clean Swift (VIP)

**Status:** planned

A single-direction VIP cycle per scene: the view sends a request, the interactor does
work (through workers), the presenter formats a response into a view model.
A configurator wires the cycle.

## Planned structure

- `CleanSwiftModule.swift` — namespace, metadata, module entry
- `TodoList/TodoListModels.swift` — use-case request/response/view model structs
- `TodoList/TodoListViewController.swift`, `TodoListInteractor.swift`, `TodoListPresenter.swift`
- `TodoList/TodoListWorker.swift` — talks to the repository
- `TodoList/TodoListConfigurator.swift` — wires the cycle
- `AddEditTodo/…` — same set

## What to notice

- One-way cycle vs VIPER's mesh of protocols — fewer wires, same separation
- Named request/response models make the use case explicit
- How configurator injection enables testing without a real repository
