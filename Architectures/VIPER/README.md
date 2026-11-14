# VIPER

**Status:** ✅ implemented

Every screen is a module of protocol-separated roles — View, Interactor, Presenter,
Entity (in `Shared`), Router — wired together by an assembly.

## Structure

TodoList module:

- `TodoList/TodoListContracts.swift` — view/presenter/interactor/router protocols
- `TodoList/TodoListModels.swift` — response payloads crossing layer boundaries
- `TodoList/TodoListViewController.swift` — passive view
- `TodoList/TodoListPresenter.swift` — formats responses, decides navigation; doubles as AddEdit module output
- `TodoList/TodoListInteractor.swift` — business logic + entity cache
- `TodoList/TodoListRouter.swift` — presents/dismisses the AddEdit module
- `TodoList/TodoListAssembly.swift` — the only place knowing concrete types

AddEditTodo module: `Contracts` (incl. module output), `Interactor` (validation), `Presenter`, `Assembly`, `ViewController`.

## What to notice

- File and protocol count per screen — the boilerplate price of strict contracts
- Presenter vs interactor: formatting + routing decisions vs business rules and entity access
- Module boundaries: AddEdit never dismisses itself — it reports through `AddEditTodoModuleOutput`,
  and the TodoList presenter + router decide what happens next
- Testing story: presenter with a mocked interactor, interactor with a mocked repository —
  every seam already exists
- Compare with MVP: same passive view, but the presenter is split in two and navigation got its own object
