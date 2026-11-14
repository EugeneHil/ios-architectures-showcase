import Foundation

extension MVI {
    /// The single immutable source of truth for the whole screen — list and edit form.
    /// Every renderable value is derived from it; views never own state of their own.
    struct TodoListState: Equatable {
        var todos: [Todo] = []
        var searchText = ""
        var isLoading = true
        var errorMessage: String?
        /// Non-nil means the edit sheet is presented. Navigation *is* state here.
        var editForm: EditFormState?

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

    /// State of the create/edit form — a value, not a separate object.
    struct EditFormState: Equatable, Identifiable {
        let id: UUID
        let existing: Todo?
        var title = ""
        var notes = ""
        var priority: Todo.Priority = .medium

        init(existing: Todo?) {
            self.id = UUID()
            self.existing = existing
            self.title = existing?.title ?? ""
            self.notes = existing?.notes ?? ""
            self.priority = existing?.priority ?? .medium
        }

        var isSaveEnabled: Bool {
            !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        var builtTodo: Todo? {
            guard isSaveEnabled else { return nil }
            var todo = existing ?? Todo(title: "")
            todo.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
            todo.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
            todo.priority = priority
            return todo
        }
    }
}
