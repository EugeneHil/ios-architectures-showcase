import Foundation

extension VIPER {
    /// Business logic: talks to the repository, keeps the entity cache,
    /// reports raw results to the presenter (no formatting, no UIKit).
    @MainActor
    final class TodoListInteractor: TodoListInteractorProtocol {
        weak var presenter: (any TodoListPresenterProtocol)?
        private let repository: any TodoRepository
        private var todos: [Todo] = []

        init(repository: any TodoRepository) {
            self.repository = repository
        }

        // MARK: TodoListInteractorProtocol

        func fetchTodos() {
            Task {
                do {
                    todos = try await repository.fetchAll()
                    presenter?.presentTodos(TodoListModels.TodosResponse(todos: todos, errorMessage: nil))
                } catch {
                    presenter?.presentTodos(TodoListModels.TodosResponse(todos: todos, errorMessage: Self.message(for: error)))
                }
            }
        }

        func toggleDone(id: UUID) {
            guard var todo = todos.first(where: { $0.id == id }) else { return }
            todo.isDone.toggle()
            persist(todo)
        }

        func delete(id: UUID) {
            Task {
                do {
                    try await repository.delete(id: id)
                    fetchTodos()
                } catch {
                    presenter?.presentOperationResult(TodoListModels.OperationResponse(errorMessage: Self.message(for: error)))
                }
            }
        }

        func save(_ todo: Todo) {
            persist(todo)
        }

        func todo(id: UUID) -> Todo? {
            todos.first { $0.id == id }
        }

        // MARK: Privates

        private func persist(_ todo: Todo) {
            Task {
                do {
                    if todos.contains(where: { $0.id == todo.id }) {
                        try await repository.update(todo)
                    } else {
                        try await repository.add(todo)
                    }
                    fetchTodos()
                } catch {
                    presenter?.presentOperationResult(TodoListModels.OperationResponse(errorMessage: Self.message(for: error)))
                }
            }
        }

        private static func message(for error: Error) -> String {
            if let repositoryError = error as? TodoRepositoryError {
                switch repositoryError {
                case .notFound: return "This todo no longer exists."
                case .storageFailed(let reason): return reason
                }
            }
            return error.localizedDescription
        }
    }
}
