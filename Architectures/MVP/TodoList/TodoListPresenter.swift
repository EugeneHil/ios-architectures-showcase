import Foundation

extension MVP {
    /// Presentation logic for the todo list. Talks to the view only through
    /// `TodoListViewProtocol` and never imports UIKit.
    @MainActor
    final class TodoListPresenter: TodoListPresenterProtocol {
        struct TodoRow: Hashable {
            let id: UUID
            let title: String
            let subtitle: String
            let isDone: Bool
        }

        struct State: Equatable {
            var todos: [TodoRow] = []
            var isLoading = true
            var emptyMessage: String?
        }

        private weak var view: (any TodoListViewProtocol)?
        private let repository: any TodoRepository
        private var allTodos: [Todo] = []
        private var searchText = ""

        init(view: any TodoListViewProtocol, repository: any TodoRepository) {
            self.view = view
            self.repository = repository
        }

        // MARK: TodoListPresenterProtocol

        func viewDidLoad() {
            Task { await reload() }
        }

        func searchChanged(_ text: String) {
            searchText = text
            publishRows()
        }

        func toggleDone(id: UUID) {
            guard var todo = allTodos.first(where: { $0.id == id }) else { return }
            todo.isDone.toggle()
            persist(todo)
        }

        func delete(id: UUID) {
            Task {
                do {
                    try await repository.delete(id: id)
                    await reload()
                } catch {
                    view?.showError(Self.message(for: error))
                }
            }
        }

        func addTapped() {
            view?.showAddTodo()
        }

        func editTapped(id: UUID) {
            guard let todo = allTodos.first(where: { $0.id == id }) else { return }
            view?.showEditTodo(todo)
        }

        func todoSaved(_ todo: Todo) {
            persist(todo)
        }

        // MARK: Privates

        private func persist(_ todo: Todo) {
            Task {
                do {
                    if allTodos.contains(where: { $0.id == todo.id }) {
                        try await repository.update(todo)
                    } else {
                        try await repository.add(todo)
                    }
                    await reload()
                } catch {
                    view?.showError(Self.message(for: error))
                }
            }
        }

        private func reload() async {
            do {
                allTodos = try await repository.fetchAll()
            } catch {
                view?.showError(Self.message(for: error))
            }
            publishRows(isLoading: false)
        }

        private func publishRows(isLoading: Bool = true) {
            let todos = filteredTodos()
            view?.render(
                State(
                    todos: todos.map(Self.row(for:)),
                    isLoading: isLoading,
                    emptyMessage: todos.isEmpty
                        ? (searchText.isEmpty ? "No todos yet — tap + to add one." : "Nothing matches \"\(searchText)\".")
                        : nil
                )
            )
        }

        private func filteredTodos() -> [Todo] {
            let query = searchText.trimmingCharacters(in: .whitespaces)
            guard !query.isEmpty else { return allTodos }
            return allTodos.filter {
                $0.title.localizedCaseInsensitiveContains(query)
                    || $0.notes.localizedCaseInsensitiveContains(query)
            }
        }

        private static func row(for todo: Todo) -> TodoRow {
            let subtitle = [todo.priority.title, todo.notes.isEmpty ? nil : todo.notes]
                .compactMap(\.self)
                .joined(separator: " · ")
            return TodoRow(id: todo.id, title: todo.title, subtitle: subtitle, isDone: todo.isDone)
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
