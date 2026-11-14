import Foundation

extension CleanSwift {
    @MainActor
    protocol TodoListBusinessLogic: AnyObject {
        func fetchTodos(request: TodoListModels.FetchTodos.Request)
        func searchTodos(request: TodoListModels.SearchTodos.Request)
        func toggleDone(request: TodoListModels.ToggleDone.Request)
        func deleteTodo(request: TodoListModels.DeleteTodo.Request)
        func saveTodo(request: TodoListModels.SaveTodo.Request)
    }

    /// Business logic of the scene: receives requests, talks to the worker,
    /// sends responses to the presenter.
    @MainActor
    final class TodoListInteractor: TodoListBusinessLogic {
        var presenter: (any TodoListPresentationLogic)?
        var worker: TodoListWorker?

        private var todos: [Todo] = []
        private var searchText = ""

        // MARK: TodoListBusinessLogic

        func fetchTodos(request: TodoListModels.FetchTodos.Request) {
            Task {
                let result = await worker?.fetchAll() ?? (nil, "Storage is not configured.")
                if let todos = result.todos {
                    self.todos = todos
                }
                presenter?.presentFetchedTodos(
                    response: TodoListModels.FetchTodos.Response(
                        todos: result.todos ?? todos,
                        errorMessage: result.errorMessage
                    )
                )
            }
        }

        func searchTodos(request: TodoListModels.SearchTodos.Request) {
            searchText = request.text
            presenter?.presentSearchedTodos(response: TodoListModels.SearchTodos.Response(todos: filteredTodos()))
        }

        func toggleDone(request: TodoListModels.ToggleDone.Request) {
            guard var todo = todos.first(where: { $0.id == request.id }) else { return }
            todo.isDone.toggle()
            persist(todo)
        }

        func deleteTodo(request: TodoListModels.DeleteTodo.Request) {
            Task {
                if let errorMessage = await worker?.delete(id: request.id) {
                    presenter?.presentFailure(response: TodoListModels.Failure.Response(errorMessage: errorMessage))
                } else {
                    fetchTodos(request: TodoListModels.FetchTodos.Request())
                }
            }
        }

        func saveTodo(request: TodoListModels.SaveTodo.Request) {
            persist(request.todo)
        }

        // MARK: Privates

        private func persist(_ todo: Todo) {
            Task {
                let errorMessage: String?
                if todos.contains(where: { $0.id == todo.id }) {
                    errorMessage = await worker?.update(todo)
                } else {
                    errorMessage = await worker?.add(todo)
                }
                if let errorMessage {
                    presenter?.presentFailure(response: TodoListModels.Failure.Response(errorMessage: errorMessage))
                } else {
                    fetchTodos(request: TodoListModels.FetchTodos.Request())
                }
            }
        }

        private func filteredTodos() -> [Todo] {
            let query = searchText.trimmingCharacters(in: .whitespaces)
            guard !query.isEmpty else { return todos }
            return todos.filter {
                $0.title.localizedCaseInsensitiveContains(query)
                    || $0.notes.localizedCaseInsensitiveContains(query)
            }
        }
    }
}
