import Foundation

extension VIPER {
    /// Commands the presenter sends to the view.
    @MainActor
    protocol TodoListViewProtocol: AnyObject {
        func render(_ viewModel: TodoListPresenter.ViewModel)
        func showError(_ message: String)
    }

    /// Events the view forwards to the presenter + interactor output callbacks.
    @MainActor
    protocol TodoListPresenterProtocol: AnyObject {
        func viewDidLoad()
        func searchChanged(_ text: String)
        func toggleDone(id: UUID)
        func delete(id: UUID)
        func addTapped()
        func editTapped(id: UUID)

        func presentTodos(_ response: TodoListModels.TodosResponse)
        func presentOperationResult(_ response: TodoListModels.OperationResponse)
    }

    /// Business actions the presenter requests from the interactor.
    @MainActor
    protocol TodoListInteractorProtocol: AnyObject {
        func fetchTodos()
        func toggleDone(id: UUID)
        func delete(id: UUID)
        func save(_ todo: Todo)
        func todo(id: UUID) -> Todo?
    }

    /// Navigation the presenter asks the router to perform.
    @MainActor
    protocol TodoListRouterProtocol: AnyObject {
        func showAddTodo()
        func showEditTodo(_ todo: Todo)
        func dismissAddEdit()
    }
}
