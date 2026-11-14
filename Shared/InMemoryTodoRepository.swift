import Foundation

/// In-memory repository with simulated latency and optional failure injection.
///
/// `shouldFail: true` turns every call into an error — handy for checking how
/// each architecture surfaces error states.
actor InMemoryTodoRepository: TodoRepository {
    private var todos: [Todo]
    private let latency: TimeInterval
    private let shouldFail: Bool

    init(
        seed: [Todo] = Todo.samples(),
        latency: TimeInterval = 0.3,
        shouldFail: Bool = false
    ) {
        self.todos = seed
        self.latency = latency
        self.shouldFail = shouldFail
    }

    func fetchAll() async throws -> [Todo] {
        try await simulateSideEffects()
        return sorted()
    }

    func add(_ todo: Todo) async throws {
        try await simulateSideEffects()
        todos.append(todo)
    }

    func update(_ todo: Todo) async throws {
        try await simulateSideEffects()
        guard let index = todos.firstIndex(where: { $0.id == todo.id }) else {
            throw TodoRepositoryError.notFound
        }
        todos[index] = todo
    }

    func delete(id: UUID) async throws {
        try await simulateSideEffects()
        todos.removeAll { $0.id == id }
    }

    private func simulateSideEffects() async throws {
        if shouldFail {
            throw TodoRepositoryError.storageFailed("Injected failure for error-state demos")
        }
        if latency > 0 {
            try await Task.sleep(for: .seconds(latency))
        }
    }

    /// Undone first, then higher priority, then newest.
    private func sorted() -> [Todo] {
        todos.sorted { lhs, rhs in
            if lhs.isDone != rhs.isDone { return !lhs.isDone }
            if lhs.priority != rhs.priority { return lhs.priority > rhs.priority }
            return lhs.createdAt > rhs.createdAt
        }
    }
}
