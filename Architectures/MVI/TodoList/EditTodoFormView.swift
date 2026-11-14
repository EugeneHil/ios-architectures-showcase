import SwiftUI

extension MVI {
    /// The edit sheet — reads the same store's `editForm` slice of state.
    struct EditTodoFormView: View {
        let store: TodoListStore

        private let priorities = Todo.Priority.allCases.sorted { $0.rawValue < $1.rawValue }

        var body: some View {
            NavigationStack {
                Form {
                    Section("Title") {
                        TextField("Title", text: titleBinding)
                    }
                    Section("Notes") {
                        TextEditor(text: notesBinding)
                            .frame(minHeight: 120)
                    }
                    Section("Priority") {
                        Picker("Priority", selection: priorityBinding) {
                            ForEach(priorities, id: \.self) { priority in
                                Text(priority.title).tag(priority)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                .navigationTitle(store.state.editForm?.existing == nil ? "New Todo" : "Edit Todo")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { store.dispatch(.editDismissed) }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { store.dispatch(.editSaveTapped) }
                            .disabled(store.state.editForm?.isSaveEnabled != true)
                    }
                }
            }
            .presentationDetents([.medium, .large])
        }

        private var titleBinding: Binding<String> {
            Binding(
                get: { store.state.editForm?.title ?? "" },
                set: { store.dispatch(.editTitleChanged($0)) }
            )
        }

        private var notesBinding: Binding<String> {
            Binding(
                get: { store.state.editForm?.notes ?? "" },
                set: { store.dispatch(.editNotesChanged($0)) }
            )
        }

        private var priorityBinding: Binding<Todo.Priority> {
            Binding(
                get: { store.state.editForm?.priority ?? .medium },
                set: { store.dispatch(.editPriorityChanged($0)) }
            )
        }
    }
}
