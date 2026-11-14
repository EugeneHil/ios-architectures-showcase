# VIPER

**Status:** planned

Every screen is a module of six roles — View, Interactor, Presenter, Entity (in `Shared`),
Router — wired together by an assembly through protocols.

## Planned structure

- `VIPERModule.swift` — namespace, metadata, module entry
- `TodoList/TodoListContracts.swift` — module input/output protocols
- `TodoList/TodoListViewController.swift`, `TodoListPresenter.swift`, `TodoListInteractor.swift`, `TodoListRouter.swift`
- `TodoList/TodoListModels.swift` — request/response/view structs
- `TodoList/TodoListAssembly.swift` — the only place knowing concrete types
- `AddEditTodo/…` — same set

## What to notice

- File and protocol count per screen — the boilerplate price of strict contracts
- Presenter vs interactor: presentation logic vs business logic
- Testing presenter and interactor in complete isolation
