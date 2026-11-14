import Foundation

extension CleanSwift {
    /// Clean Swift use-case models: every cycle is a use case with a Request
    /// (view → interactor), Response (interactor → presenter) and ViewModel
    /// (presenter → view).
    ///
    /// `ToggleDone`, `DeleteTodo` and `SaveTodo` have no Response/ViewModel on purpose:
    /// their success path simply restarts the `FetchTodos` cycle, and failures travel
    /// through the `Failure` use case.
    enum TodoListModels {
        struct Row {
            let todo: Todo
            let title: String
            let subtitle: String
            let isDone: Bool
        }

        enum FetchTodos {
            struct Request {}
            struct Response {
                let todos: [Todo]
                let errorMessage: String?
            }
            struct ViewModel {
                let rows: [Row]
                let emptyMessage: String?
            }
        }

        enum SearchTodos {
            struct Request {
                let text: String
            }
            struct Response {
                let todos: [Todo]
            }
            struct ViewModel {
                let rows: [Row]
                let emptyMessage: String?
            }
        }

        enum ToggleDone {
            struct Request {
                let id: UUID
            }
        }

        enum DeleteTodo {
            struct Request {
                let id: UUID
            }
        }

        enum SaveTodo {
            struct Request {
                let todo: Todo
            }
        }

        enum Failure {
            struct Response {
                let errorMessage: String
            }
            struct ViewModel {
                let errorMessage: String
            }
        }
    }
}
