import Combine
import Foundation

extension MVVMCoordinator {
    /// View model for the create/edit form — identical to the plain MVVM sample:
    /// the coordinator pattern changes who *presents* the form, not the form itself.
    @MainActor
    final class AddEditTodoViewModel {
        struct State: Equatable {
            var title = ""
            var notes = ""
            var priority: Todo.Priority = .medium
            var isSaveEnabled = false
        }

        let screenTitle: String
        let state = CurrentValueSubject<State, Never>(State())
        let finished = PassthroughSubject<Todo, Never>()

        private let existing: Todo?
        private var didFinish = false

        init(existing: Todo?) {
            self.existing = existing
            self.screenTitle = existing == nil ? "New Todo" : "Edit Todo"
            if let existing {
                state.value = State(
                    title: existing.title,
                    notes: existing.notes,
                    priority: existing.priority,
                    isSaveEnabled: true
                )
            }
        }

        // MARK: Inputs

        func titleChanged(_ text: String) {
            state.value.title = text
            state.value.isSaveEnabled = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        func notesChanged(_ text: String) {
            state.value.notes = text
        }

        func priorityChanged(_ priority: Todo.Priority) {
            state.value.priority = priority
        }

        func saveTapped() {
            guard !didFinish, state.value.isSaveEnabled else { return }
            didFinish = true
            var todo = existing ?? Todo(title: "")
            todo.title = state.value.title.trimmingCharacters(in: .whitespacesAndNewlines)
            todo.notes = state.value.notes.trimmingCharacters(in: .whitespacesAndNewlines)
            todo.priority = state.value.priority
            finished.send(todo)
        }
    }
}
