import ComposableArchitecture
import Foundation

extension TCA {
    /// The form feature: pure state, no effects — persistence is the parent's concern.
    /// Results travel to the parent through delegate actions, exactly like VIPER's module output.
    @Reducer
    struct AddEditTodoFeature {
        @ObservableState
        struct State: Equatable {
            let existing: Todo?
            var title = ""
            var notes = ""
            var priority: Todo.Priority

            init(existing: Todo?) {
                self.existing = existing
                self.title = existing?.title ?? ""
                self.notes = existing?.notes ?? ""
                self.priority = existing?.priority ?? .medium
            }

            var isSaveEnabled: Bool {
                !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
        }

        enum Action {
            case titleChanged(String)
            case notesChanged(String)
            case priorityChanged(Todo.Priority)
            case cancelTapped
            case saveTapped
            case delegate(Delegate)

            enum Delegate: Equatable {
                case savedTodo(Todo)
                case cancelled
            }
        }

        var body: some ReducerOf<Self> {
            Reduce { state, action in
                switch action {
                case .titleChanged(let text):
                    state.title = text
                    return .none

                case .notesChanged(let text):
                    state.notes = text
                    return .none

                case .priorityChanged(let priority):
                    state.priority = priority
                    return .none

                case .cancelTapped:
                    return .run { send in await send(.delegate(.cancelled)) }

                case .saveTapped:
                    guard state.isSaveEnabled else { return .none }
                    var todo = state.existing ?? Todo(title: "")
                    todo.title = state.title.trimmingCharacters(in: .whitespacesAndNewlines)
                    todo.notes = state.notes.trimmingCharacters(in: .whitespacesAndNewlines)
                    todo.priority = state.priority
                    return .run { send in await send(.delegate(.savedTodo(todo))) }
                }
            }
        }
    }
}
