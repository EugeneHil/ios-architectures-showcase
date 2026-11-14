import Foundation

extension VIPER {
    /// Request/response payloads crossing the module's layer boundaries.
    /// Entities (`Todo`) live in `Shared`.
    enum TodoListModels {
        struct TodosResponse {
            let todos: [Todo]
            let errorMessage: String?
        }

        struct OperationResponse {
            let errorMessage: String?
        }
    }
}
