import ComposableArchitecture
import SwiftUI

extension TCA {
    struct AddEditTodoView: View {
        @Bindable var store: StoreOf<AddEditTodoFeature>

        private let priorities = Todo.Priority.allCases.sorted { $0.rawValue < $1.rawValue }

        var body: some View {
            Form {
                Section("Title") {
                    TextField("Title", text: $store.title.sending(\.titleChanged))
                }
                Section("Notes") {
                    TextEditor(text: $store.notes.sending(\.notesChanged))
                        .frame(minHeight: 120)
                }
                Section("Priority") {
                    Picker("Priority", selection: $store.priority.sending(\.priorityChanged)) {
                        ForEach(priorities, id: \.self) { priority in
                            Text(priority.title).tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle(store.existing == nil ? "New Todo" : "Edit Todo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { store.send(.cancelTapped) }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { store.send(.saveTapped) }
                        .disabled(!store.isSaveEnabled)
                }
            }
        }
    }
}
