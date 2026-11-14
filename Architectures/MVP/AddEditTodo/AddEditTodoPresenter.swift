import Foundation

extension MVP {
    /// Form logic without UIKit: validates and builds the finished `Todo`,
    /// then hands it to the parent through `onFinished` (set by the list view).
    @MainActor
    final class AddEditTodoPresenter: AddEditTodoPresenterProtocol {
        struct State: Equatable {
            var title = ""
            var notes = ""
            var priority: Todo.Priority = .medium
            var isSaveEnabled = false
        }

        private(set) var state: State
        private weak var view: (any AddEditTodoViewProtocol)?
        private let existing: Todo?
        private let onFinished: (Todo) -> Void
        private var didFinish = false

        init(view: any AddEditTodoViewProtocol, existing: Todo?, onFinished: @escaping (Todo) -> Void) {
            self.view = view
            self.existing = existing
            self.onFinished = onFinished
            self.state = State(
                title: existing?.title ?? "",
                notes: existing?.notes ?? "",
                priority: existing?.priority ?? .medium,
                isSaveEnabled: existing != nil
            )
        }

        // MARK: AddEditTodoPresenterProtocol

        func start() {
            view?.render(state)
        }

        func titleChanged(_ text: String) {
            state.title = text
            state.isSaveEnabled = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            view?.render(state)
        }

        func notesChanged(_ text: String) {
            state.notes = text
        }

        func priorityChanged(_ priority: Todo.Priority) {
            state.priority = priority
        }

        func saveTapped() {
            guard !didFinish, state.isSaveEnabled else { return }
            didFinish = true

            var todo = existing ?? Todo(title: "")
            todo.title = state.title.trimmingCharacters(in: .whitespacesAndNewlines)
            todo.notes = state.notes.trimmingCharacters(in: .whitespacesAndNewlines)
            todo.priority = state.priority

            view?.close()
            onFinished(todo)
        }

        func cancelTapped() {
            view?.close()
        }
    }
}
