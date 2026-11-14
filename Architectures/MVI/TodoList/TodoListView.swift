import SwiftUI

extension MVI {
    /// View = f(state): renders `TodoListState`, dispatches intents.
    /// Bindings below are thin glue — every set dispatches an intent, nothing mutates state directly.
    struct TodoListView: View {
        @State private var store: TodoListStore

        init(repository: any TodoRepository) {
            _store = State(initialValue: TodoListStore(repository: repository))
        }

        var body: some View {
            List {
                Section {
                    ForEach(store.state.visibleTodos) { todo in
                        row(todo)
                    }
                } header: {
                    header
                }
            }
            .listStyle(.insetGrouped)
            .overlay {
                if store.state.isLoading {
                    ProgressView()
                } else if let message = store.state.emptyMessage {
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding()
                }
            }
            .sheet(item: editFormBinding) { _ in
                EditTodoFormView(store: store)
            }
            .alert(
                "Something went wrong",
                isPresented: errorAlertBinding
            ) {
                Button("OK") { store.dispatch(.errorDismissed) }
            } message: {
                Text(store.state.errorMessage ?? "")
            }
            .onAppear {
                store.dispatch(.onAppear)
            }
        }

        // MARK: Parts

        private var header: some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Todos")
                        .font(.title2.bold())
                    Spacer()
                    Button {
                        store.dispatch(.addTapped)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
                TextField("Search", text: searchBinding)
                    .textFieldStyle(.roundedBorder)
            }
            .textCase(nil)
            .padding(.vertical, 4)
        }

        private func row(_ todo: Todo) -> some View {
            Button {
                store.dispatch(.editTapped(todo.id))
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: todo.isDone ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(todo.isDone ? Color.green : Color.secondary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(todo.title)
                            .strikethrough(todo.isDone)
                        Text(TodoListState.subtitle(for: todo))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
            }
            .buttonStyle(.plain)
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                Button(todo.isDone ? "Undo" : "Done") {
                    store.dispatch(.toggleDone(todo.id))
                }
                .tint(.green)
            }
            .swipeActions(edge: .trailing) {
                Button(role: .destructive) {
                    store.dispatch(.delete(todo.id))
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }

        // MARK: Bindings — glue that turns SwiftUI setters into intents

        private var searchBinding: Binding<String> {
            Binding(
                get: { store.state.searchText },
                set: { store.dispatch(.searchChanged($0)) }
            )
        }

        private var editFormBinding: Binding<EditFormState?> {
            Binding(
                get: { store.state.editForm },
                set: { if $0 == nil { store.dispatch(.editDismissed) } }
            )
        }

        private var errorAlertBinding: Binding<Bool> {
            Binding(
                get: { store.state.errorMessage != nil },
                set: { if !$0 { store.dispatch(.errorDismissed) } }
            )
        }
    }
}
