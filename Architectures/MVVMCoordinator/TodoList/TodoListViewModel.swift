import Combine
import Foundation

extension MVVMCoordinator {
    /// View model for the todo list screen — a pure data state machine.
    /// Unlike the plain MVVM sample it has no `events` output:
    /// navigation decisions are not the view model's business — coordinators own them.
    @MainActor
    final class TodoListViewModel {
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

        let state = CurrentValueSubject<State, Never>(State())
        let errors = PassthroughSubject<String, Never>()

        private let repository: any TodoRepository
        private var allTodos: [Todo] = []
        private var searchText = ""

        init(repository: any TodoRepository) {
            self.repository = repository
        }

        // MARK: Inputs (user intents)

        func viewDidLoad() {
            Task { await reload() }
        }

        func searchTextChanged(_ text: String) {
            searchText = text
            publishRows()
        }

        func toggleDone(_ row: TodoRow) {
            guard var todo = allTodos.first(where: { $0.id == row.id }) else { return }
            todo.isDone.toggle()
            persist(todo)
        }

        func delete(_ row: TodoRow) {
            Task {
                do {
                    try await repository.delete(id: row.id)
                    await reload()
                } catch {
                    errors.send(Self.message(for: error))
                }
            }
        }

        /// The add/edit flow finished with a todo — insert or update by id, then refresh.
        func todoSaved(_ todo: Todo) {
            persist(todo)
        }

        /// The coordinator asks for the entity behind a row when routing to the edit flow.
        func todo(id: UUID) -> Todo? {
            allTodos.first { $0.id == id }
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
                    errors.send(Self.message(for: error))
                }
            }
        }

        private func reload() async {
            do {
                allTodos = try await repository.fetchAll()
            } catch {
                errors.send(Self.message(for: error))
            }
            state.value.isLoading = false
            publishRows()
        }

        private func publishRows() {
            let todos = filteredTodos()
            state.value.todos = todos.map(Self.row(for:))
            state.value.emptyMessage = todos.isEmpty
                ? (searchText.isEmpty ? "No todos yet — tap + to add one." : "Nothing matches \"\(searchText)\".")
                : nil
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
