import ComposableArchitecture
import SwiftUI

extension TCA {
    /// Renders feature state; every interaction is `store.send(action)`.
    /// Bindings route through the store with `.sending(_:)` — no direct state mutation.
    struct TodoListView: View {
        @Bindable var store: StoreOf<TodoListFeature>

        var body: some View {
            List {
                Section {
                    ForEach(store.visibleTodos) { todo in
                        row(todo)
                    }
                } header: {
                    header
                }
            }
            .listStyle(.insetGrouped)
            .overlay {
                if store.isLoading {
                    ProgressView()
                } else if let message = store.emptyMessage {
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding()
                }
            }
            .sheet(item: $store.scope(state: \.addEdit, action: \.addEdit)) { store in
                NavigationStack {
                    AddEditTodoView(store: store)
                }
                .presentationDetents([.medium, .large])
            }
            .alert(
                "Something went wrong",
                isPresented: Binding(
                    get: { store.errorMessage != nil },
                    set: { if !$0 { store.send(.errorDismissed) } }
                )
            ) {
                Button("OK") { store.send(.errorDismissed) }
            } message: {
                Text(store.errorMessage ?? "")
            }
            .onAppear {
                store.send(.onAppear)
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
                        store.send(.addTapped)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
                TextField("Search", text: $store.searchText.sending(\.searchChanged))
                    .textFieldStyle(.roundedBorder)
            }
            .textCase(nil)
            .padding(.vertical, 4)
        }

        private func row(_ todo: Todo) -> some View {
            Button {
                store.send(.editTapped(todo.id))
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: todo.isDone ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(todo.isDone ? Color.green : Color.secondary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(todo.title)
                            .strikethrough(todo.isDone)
                        Text(TodoListFeature.State.subtitle(for: todo))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
            }
            .buttonStyle(.plain)
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                Button(todo.isDone ? "Undo" : "Done") {
                    store.send(.toggleDoneTapped(todo.id))
                }
                .tint(.green)
            }
            .swipeActions(edge: .trailing) {
                Button(role: .destructive) {
                    store.send(.deleteTapped(todo.id))
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}
