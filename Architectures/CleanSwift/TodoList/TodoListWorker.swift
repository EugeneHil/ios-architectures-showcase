import Foundation

extension CleanSwift {
    /// Wraps the shared repository so the interactor never touches storage directly.
    @MainActor
    final class TodoListWorker {
        private let repository: any TodoRepository

        init(repository: any TodoRepository) {
            self.repository = repository
        }

        func fetchAll() async -> (todos: [Todo]?, errorMessage: String?) {
            do {
                return (try await repository.fetchAll(), nil)
            } catch {
                return (nil, Self.message(for: error))
            }
        }

        func add(_ todo: Todo) async -> String? {
            do {
                try await repository.add(todo)
                return nil
            } catch {
                return Self.message(for: error)
            }
        }

        func update(_ todo: Todo) async -> String? {
            do {
                try await repository.update(todo)
                return nil
            } catch {
                return Self.message(for: error)
            }
        }

        func delete(id: UUID) async -> String? {
            do {
                try await repository.delete(id: id)
                return nil
            } catch {
                return Self.message(for: error)
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
