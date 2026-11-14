import ComposableArchitecture
import Foundation

// The shared repository as a TCA dependency — injectable (and mockable) per store.
extension DependencyValues {
    var todoRepository: any TodoRepository {
        get { self[TodoRepositoryKey.self] }
        set { self[TodoRepositoryKey.self] = newValue }
    }
}

private enum TodoRepositoryKey: DependencyKey {
    static let liveValue: any TodoRepository = InMemoryTodoRepository()
}

extension TCA {
    /// The list feature: same domain as every other sample in this repo,
    /// expressed as State + Action + reducer + effects.
    @Reducer
    struct TodoListFeature {
        @ObservableState
        struct State: Equatable {
            var todos: [Todo] = []
            var searchText = ""
            var isLoading = true
            var errorMessage: String?
            @Presents var addEdit: AddEditTodoFeature.State?

            var visibleTodos: [Todo] {
                let query = searchText.trimmingCharacters(in: .whitespaces)
                guard !query.isEmpty else { return todos }
                return todos.filter {
                    $0.title.localizedCaseInsensitiveContains(query)
                        || $0.notes.localizedCaseInsensitiveContains(query)
                }
            }

            var emptyMessage: String? {
                guard !isLoading, visibleTodos.isEmpty else { return nil }
                return searchText.isEmpty
                    ? "No todos yet — tap + to add one."
                    : "Nothing matches \"\(searchText)\"."
            }

            static func subtitle(for todo: Todo) -> String {
                [todo.priority.title, todo.notes.isEmpty ? nil : todo.notes]
                    .compactMap(\.self)
                    .joined(separator: " · ")
            }
        }

        enum Action {
            case onAppear
            case searchChanged(String)
            case toggleDoneTapped(UUID)
            case deleteTapped(UUID)
            case addTapped
            case editTapped(UUID)
            case addEdit(PresentationAction<AddEditTodoFeature.Action>)

            // System actions fed by effects
            case todosLoaded([Todo])
            case failed(String)
            case errorDismissed
        }

        @Dependency(\.todoRepository) var repository

        var body: some ReducerOf<Self> {
            Reduce { state, action in
                switch action {
                case .onAppear:
                    state.isLoading = true
                    return .run { send in
                        do {
                            await send(.todosLoaded(try await repository.fetchAll()))
                        } catch {
                            await send(.failed(Self.message(for: error)))
                        }
                    }

                case .searchChanged(let text):
                    state.searchText = text
                    return .none

                case .toggleDoneTapped(let id):
                    guard let index = state.todos.firstIndex(where: { $0.id == id }) else { return .none }
                    var updated = state.todos[index]
                    updated.isDone.toggle()
                    let todo = updated
                    let isUpdate = state.todos.contains(where: { $0.id == todo.id })
                    return .run { [repository, todo] send in
                        do {
                            try await isUpdate ? repository.update(todo) : repository.add(todo)
                            await send(.todosLoaded(try await repository.fetchAll()))
                        } catch {
                            await send(.failed(Self.message(for: error)))
                        }
                    }

                case .deleteTapped(let id):
                    return .run { [repository] send in
                        do {
                            try await repository.delete(id: id)
                            await send(.todosLoaded(try await repository.fetchAll()))
                        } catch {
                            await send(.failed(Self.message(for: error)))
                        }
                    }

                case .addTapped:
                    state.addEdit = AddEditTodoFeature.State(existing: nil)
                    return .none

                case .editTapped(let id):
                    guard let todo = state.todos.first(where: { $0.id == id }) else { return .none }
                    state.addEdit = AddEditTodoFeature.State(existing: todo)
                    return .none

                case .addEdit(.presented(.delegate(.savedTodo(let todo)))):
                    state.addEdit = nil
                    let isUpdate = state.todos.contains(where: { $0.id == todo.id })
                    return .run { [repository] send in
                        do {
                            try await isUpdate ? repository.update(todo) : repository.add(todo)
                            await send(.todosLoaded(try await repository.fetchAll()))
                        } catch {
                            await send(.failed(Self.message(for: error)))
                        }
                    }

                case .addEdit(.presented(.delegate(.cancelled))):
                    state.addEdit = nil
                    return .none

                case .addEdit:
                    return .none

                case .todosLoaded(let todos):
                    state.todos = todos
                    state.isLoading = false
                    return .none

                case .failed(let message):
                    state.errorMessage = message
                    state.isLoading = false
                    return .none

                case .errorDismissed:
                    state.errorMessage = nil
                    return .none
                }
            }
            .ifLet(\.$addEdit, action: \.addEdit) {
                AddEditTodoFeature()
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
