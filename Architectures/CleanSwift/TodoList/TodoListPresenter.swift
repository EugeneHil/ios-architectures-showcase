import Foundation

extension CleanSwift {
    @MainActor
    protocol TodoListPresentationLogic: AnyObject {
        func presentFetchedTodos(response: TodoListModels.FetchTodos.Response)
        func presentSearchedTodos(response: TodoListModels.SearchTodos.Response)
        func presentFailure(response: TodoListModels.Failure.Response)
    }

    /// Pure formatting: responses in, view models out. No business decisions here.
    @MainActor
    final class TodoListPresenter: TodoListPresentationLogic {
        weak var viewController: (any TodoListDisplayLogic)?

        func presentFetchedTodos(response: TodoListModels.FetchTodos.Response) {
            viewController?.displayFetchedTodos(
                viewModel: TodoListModels.FetchTodos.ViewModel(
                    rows: response.todos.map(Self.row(for:)),
                    emptyMessage: response.todos.isEmpty ? "No todos yet — tap + to add one." : nil
                )
            )
            if let errorMessage = response.errorMessage {
                presentFailure(response: TodoListModels.Failure.Response(errorMessage: errorMessage))
            }
        }

        func presentSearchedTodos(response: TodoListModels.SearchTodos.Response) {
            viewController?.displaySearchedTodos(
                viewModel: TodoListModels.SearchTodos.ViewModel(
                    rows: response.todos.map(Self.row(for:)),
                    emptyMessage: response.todos.isEmpty ? "Nothing matches your search." : nil
                )
            )
        }

        func presentFailure(response: TodoListModels.Failure.Response) {
            viewController?.displayFailure(viewModel: TodoListModels.Failure.ViewModel(errorMessage: response.errorMessage))
        }

        private static func row(for todo: Todo) -> TodoListModels.Row {
            let subtitle = [todo.priority.title, todo.notes.isEmpty ? nil : todo.notes]
                .compactMap(\.self)
                .joined(separator: " · ")
            return TodoListModels.Row(todo: todo, title: todo.title, subtitle: subtitle, isDone: todo.isDone)
        }
    }
}
