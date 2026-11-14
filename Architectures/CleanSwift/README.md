# Clean Swift (VIP)

**Status:** ✅ implemented

A single-direction VIP cycle per scene: the view sends a request, the interactor does
work through workers, the presenter formats a response into a view model.
A configurator wires the cycle.

## Structure

TodoList scene:

- `TodoList/TodoListModels.swift` — use cases with Request/Response/ViewModel + `Row`
- `TodoList/TodoListViewController.swift` — sends requests, implements display logic
- `TodoList/TodoListInteractor.swift` — business logic (`TodoListBusinessLogic`)
- `TodoList/TodoListWorker.swift` — wraps the repository
- `TodoList/TodoListPresenter.swift` — pure formatting (`TodoListPresentationLogic`)
- `TodoList/TodoListRouter.swift` — navigation
- `TodoList/TodoListConfigurator.swift` — wires the cycle

AddEditTodo scene: `Models`, `Interactor` (with a `DataStore` for `todoToEdit`),
`Presenter`, `Router`, `Configurator`, `ViewController`.

## What to notice

- Every user action is a *use case* with explicit Request/Response/ViewModel types —
  verbose, but the data flow through the scene is impossible to misunderstand
- The cycle is strictly one-way: view → interactor → presenter → view;
  `ToggleDone`/`DeleteTodo`/`SaveTodo` succeed by restarting the `FetchTodos` cycle
- The result of the AddEdit scene re-enters this scene as a `SaveTodo` request
  (see `TodoListRouter`) — compare with VIPER's module-output indirection
- The worker seam: storage can be swapped without touching the interactor's logic
- Compare with VIPER: same rigidity, fewer protocols — Clean Swift trades
  module-level indirection for per-scene uniformity
