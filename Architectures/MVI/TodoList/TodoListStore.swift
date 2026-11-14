import Foundation
import Observation

extension MVI {
    /// The loop's engine: intents in → pure state transition → effects out →
    /// async work → results dispatched back as new intents.
    @Observable
    @MainActor
    final class TodoListStore {
        private(set) var state = TodoListState()
        private let repository: any TodoRepository

        init(repository: any TodoRepository) {
            self.repository = repository
        }

        /// The only entry point into the system.
        func dispatch(_ intent: TodoListIntent) {
            let effects = Self.reduce(&state, intent)
            for effect in effects {
                run(effect)
            }
        }

        /// Pure reducer: same (state, intent) always yields the same transition.
        /// Side effects are *declared* here but never executed — see `run`.
        static func reduce(_ state: inout TodoListState, _ intent: TodoListIntent) -> [TodoListEffect] {
            switch intent {
            case .onAppear:
                return [.fetchAll]

            case .searchChanged(let text):
                state.searchText = text

            case .toggleDone(let id):
                guard let index = state.todos.firstIndex(where: { $0.id == id }) else { return [] }
                var todo = state.todos[index]
                todo.isDone.toggle()
                return [.persist(todo)]

            case .delete(let id):
                return [.delete(id)]

            case .addTapped:
                state.editForm = EditFormState(existing: nil)

            case .editTapped(let id):
                guard let todo = state.todos.first(where: { $0.id == id }) else { return [] }
                state.editForm = EditFormState(existing: todo)

            case .editTitleChanged(let text):
                state.editForm?.title = text

            case .editNotesChanged(let text):
                state.editForm?.notes = text

            case .editPriorityChanged(let priority):
                state.editForm?.priority = priority

            case .editSaveTapped:
                guard let todo = state.editForm?.builtTodo else { return [] }
                state.editForm = nil
                return [.persist(todo)]

            case .editDismissed:
                state.editForm = nil

            case .todosLoaded(let todos):
                state.todos = todos
                state.isLoading = false

            case .failed(let message):
                state.errorMessage = message
                state.isLoading = false

            case .errorDismissed:
                state.errorMessage = nil
            }
            return []
        }

        // MARK: Privates — the only place with impurity

        private func run(_ effect: TodoListEffect) {
            Task {
                switch effect {
                case .fetchAll:
                    await fetchAndDispatch()

                case .persist(let todo):
                    do {
                        if state.todos.contains(where: { $0.id == todo.id }) {
                            try await repository.update(todo)
                        } else {
                            try await repository.add(todo)
                        }
                        await fetchAndDispatch()
                    } catch {
                        dispatch(.failed(Self.message(for: error)))
                    }

                case .delete(let id):
                    do {
                        try await repository.delete(id: id)
                        await fetchAndDispatch()
                    } catch {
                        dispatch(.failed(Self.message(for: error)))
                    }
                }
            }
        }

        private func fetchAndDispatch() async {
            do {
                dispatch(.todosLoaded(try await repository.fetchAll()))
            } catch {
                dispatch(.failed(Self.message(for: error)))
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
