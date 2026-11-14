import Combine
import XCTest
@testable import ArchitecturesShowcase

/// View model tests for the MVVM + Combine sample.
/// No view controller involved — just a mocked repository and published state.
@MainActor
final class MVVMCombineTests: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: TodoListViewModel

    func test_viewDidLoad_loadsTodosAndStopsLoading() async throws {
        let repository = MockTodoRepository(seed: [
            Todo(title: "Buy milk"),
            Todo(title: "Read TCA docs", isDone: true),
        ])
        let viewModel = MVVMCombine.TodoListViewModel(repository: repository)

        let loaded = expectation(description: "state with isLoading == false")
        viewModel.state
            .filter { !$0.isLoading }
            .sink { _ in loaded.fulfill() }
            .store(in: &cancellables)

        viewModel.viewDidLoad()
        await fulfillment(of: [loaded], timeout: 1)

        let state = viewModel.state.value
        XCTAssertEqual(state.todos.map(\.title), ["Buy milk", "Read TCA docs"]) // repository sorts: undone first
        XCTAssertNil(state.emptyMessage)
    }

    func test_searchText_filtersRows() async throws {
        let repository = MockTodoRepository(seed: [
            Todo(title: "Buy milk"),
            Todo(title: "Walk the dog"),
        ])
        let viewModel = MVVMCombine.TodoListViewModel(repository: repository)

        let loaded = expectation(description: "loaded")
        viewModel.state
            .filter { !$0.isLoading }
            .sink { _ in loaded.fulfill() }
            .store(in: &cancellables)

        viewModel.viewDidLoad()
        await fulfillment(of: [loaded], timeout: 1)

        viewModel.searchTextChanged("milk")
        XCTAssertEqual(viewModel.state.value.todos.map(\.title), ["Buy milk"])

        viewModel.searchTextChanged("no such todo")
        XCTAssertEqual(viewModel.state.value.todos.map(\.title), [])
        XCTAssertEqual(viewModel.state.value.emptyMessage, "Nothing matches \"no such todo\".")
    }

    func test_toggleDone_persistsThroughRepository() async throws {
        let repository = MockTodoRepository(seed: [Todo(title: "A")])
        let viewModel = MVVMCombine.TodoListViewModel(repository: repository)

        let loaded = expectation(description: "loaded")
        viewModel.state
            .filter { !$0.isLoading }
            .sink { _ in loaded.fulfill() }
            .store(in: &cancellables)
        viewModel.viewDidLoad()
        await fulfillment(of: [loaded], timeout: 1)

        let toggled = expectation(description: "row becomes done")
        viewModel.state
            .filter { $0.todos.first?.isDone == true }
            .sink { _ in toggled.fulfill() }
            .store(in: &cancellables)

        let row = try XCTUnwrap(viewModel.state.value.todos.first)
        viewModel.toggleDone(row)
        await fulfillment(of: [toggled], timeout: 1)

        let updated = await repository.updated
        XCTAssertEqual(updated.count, 1)
        XCTAssertEqual(updated.first?.isDone, true)
    }

    func test_todoSaved_insertsNewTodo() async throws {
        let repository = MockTodoRepository(seed: [Todo(title: "A")])
        let viewModel = MVVMCombine.TodoListViewModel(repository: repository)

        let loaded = expectation(description: "loaded")
        viewModel.state
            .filter { !$0.isLoading }
            .sink { _ in loaded.fulfill() }
            .store(in: &cancellables)
        viewModel.viewDidLoad()
        await fulfillment(of: [loaded], timeout: 1)

        let inserted = expectation(description: "new todo appears in rows")
        viewModel.state
            .filter { $0.todos.count == 2 }
            .sink { _ in inserted.fulfill() }
            .store(in: &cancellables)

        viewModel.todoSaved(Todo(title: "New"))
        await fulfillment(of: [inserted], timeout: 1)

        let added = await repository.added
        XCTAssertEqual(added.map(\.title), ["New"])
    }

    // MARK: AddEditTodoViewModel

    func test_addEdit_saveDisabledUntilTitlePresent() {
        let viewModel = MVVMCombine.AddEditTodoViewModel(existing: nil)
        XCTAssertFalse(viewModel.state.value.isSaveEnabled)

        viewModel.titleChanged("   ")
        XCTAssertFalse(viewModel.state.value.isSaveEnabled)

        viewModel.titleChanged("Hello")
        XCTAssertTrue(viewModel.state.value.isSaveEnabled)
    }

    func test_addEdit_saveEmitsUpdatedTodo() async throws {
        let existing = Todo(title: "Old title", priority: .low)
        let viewModel = MVVMCombine.AddEditTodoViewModel(existing: existing)
        viewModel.titleChanged("New title")
        viewModel.priorityChanged(.high)

        let saved = expectation(description: "finished emits todo")
        viewModel.finished
            .sink { todo in
                XCTAssertEqual(todo.id, existing.id)
                XCTAssertEqual(todo.title, "New title")
                XCTAssertEqual(todo.priority, .high)
                saved.fulfill()
            }
            .store(in: &cancellables)

        viewModel.saveTapped()
        await fulfillment(of: [saved], timeout: 1)
    }
}

/// Scripted stand-in for the repository; records every mutation.
private actor MockTodoRepository: TodoRepository {
    private var todos: [Todo]
    private(set) var added: [Todo] = []
    private(set) var updated: [Todo] = []
    private(set) var deletedIDs: [UUID] = []

    init(seed: [Todo]) {
        self.todos = seed
    }

    func fetchAll() -> [Todo] { todos }

    func add(_ todo: Todo) {
        todos.append(todo)
        added.append(todo)
    }

    func update(_ todo: Todo) throws {
        guard let index = todos.firstIndex(where: { $0.id == todo.id }) else {
            throw TodoRepositoryError.notFound
        }
        todos[index] = todo
        updated.append(todo)
    }

    func delete(id: UUID) {
        todos.removeAll { $0.id == id }
        deletedIDs.append(id)
    }
}
