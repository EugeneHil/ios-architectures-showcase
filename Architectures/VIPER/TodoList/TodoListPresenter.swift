import Foundation

extension VIPER {
    /// Presentation logic: formats interactor responses into view models,
    /// decides when to navigate (through the router).
    /// Also acts as the output of the AddEdit module — VIPER modules talk through module outputs.
    @MainActor
    final class TodoListPresenter: TodoListPresenterProtocol, AddEditTodoModuleOutput {
        struct TodoRow: Hashable {
            let id: UUID
            let title: String
            let subtitle: String
            let isDone: Bool
        }

        struct ViewModel: Equatable {
            var rows: [TodoRow] = []
            var emptyMessage: String?
        }

        weak var view: (any TodoListViewProtocol)?
        var interactor: (any TodoListInteractorProtocol)?
        var router: (any TodoListRouterProtocol)?

        private var searchText = ""
        private var lastTodos: [Todo] = []

        // MARK: TodoListPresenterProtocol (view events)

        func viewDidLoad() {
            interactor?.fetchTodos()
        }

        func searchChanged(_ text: String) {
            searchText = text
            render()
        }

        func toggleDone(id: UUID) {
            interactor?.toggleDone(id: id)
        }

        func delete(id: UUID) {
            interactor?.delete(id: id)
        }

        func addTapped() {
            router?.showAddTodo()
        }

        func editTapped(id: UUID) {
            guard let todo = interactor?.todo(id: id) else { return }
            router?.showEditTodo(todo)
        }

        // MARK: TodoListPresenterProtocol (interactor output)

        func presentTodos(_ response: TodoListModels.TodosResponse) {
            lastTodos = response.todos
            render()
            if let errorMessage = response.errorMessage {
                view?.showError(errorMessage)
            }
        }

        func presentOperationResult(_ response: TodoListModels.OperationResponse) {
            if let errorMessage = response.errorMessage {
                view?.showError(errorMessage)
            }
        }

        // MARK: AddEditTodoModuleOutput

        func addEditTodoDidFinish(with todo: Todo) {
            router?.dismissAddEdit()
            interactor?.save(todo)
        }

        func addEditTodoDidCancel() {
            router?.dismissAddEdit()
        }

        // MARK: Privates

        private func render() {
            let todos = filteredTodos()
            view?.render(
                ViewModel(
                    rows: todos.map(Self.row(for:)),
                    emptyMessage: todos.isEmpty
                        ? (searchText.isEmpty ? "No todos yet — tap + to add one." : "Nothing matches \"\(searchText)\".")
                        : nil
                )
            )
        }

        private func filteredTodos() -> [Todo] {
            let query = searchText.trimmingCharacters(in: .whitespaces)
            guard !query.isEmpty else { return lastTodos }
            return lastTodos.filter {
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
    }
}
