import Foundation

extension VIPER {
    /// Business rules of the form: validation and building the entity.
    @MainActor
    final class AddEditTodoInteractor: AddEditTodoInteractorProtocol {
        private let existing: Todo?

        init(existing: Todo?) {
            self.existing = existing
        }

        func validateTitle(_ title: String) -> Bool {
            !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        func makeTodo(title: String, notes: String, priority: Todo.Priority) -> Todo? {
            guard validateTitle(title) else { return nil }
            var todo = existing ?? Todo(title: "")
            todo.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
            todo.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
            todo.priority = priority
            return todo
        }
    }
}
