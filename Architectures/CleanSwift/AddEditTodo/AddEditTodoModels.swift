import Foundation

extension CleanSwift {
    enum AddEditTodoModels {
        enum InitializeForm {
            struct Request {}
            struct Response {
                let title: String
                let notes: String
                let priority: Todo.Priority
                let isSaveEnabled: Bool
            }
            struct ViewModel {
                let title: String
                let notes: String
                let priority: Todo.Priority
                let isSaveEnabled: Bool
            }
        }

        enum UpdateTitle {
            struct Request {
                let text: String
            }
            struct Response {
                let isValid: Bool
            }
            struct ViewModel {
                let isSaveEnabled: Bool
            }
        }

        enum UpdateNotes {
            struct Request {
                let text: String
            }
        }

        enum UpdatePriority {
            struct Request {
                let priority: Todo.Priority
            }
        }

        enum SaveTodo {
            struct Request {}
            struct Response {
                let todo: Todo?
            }
            struct ViewModel {
                let todo: Todo?
            }
        }
    }
}
