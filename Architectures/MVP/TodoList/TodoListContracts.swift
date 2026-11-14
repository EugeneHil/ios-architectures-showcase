import Foundation

extension MVP {
    /// Commands the presenter can send to its (dumb) view.
    @MainActor
    protocol TodoListViewProtocol: AnyObject {
        func render(_ state: TodoListPresenter.State)
        func showAddTodo()
        func showEditTodo(_ todo: Todo)
        func showError(_ message: String)
    }

    /// User events the view forwards to its presenter.
    @MainActor
    protocol TodoListPresenterProtocol: AnyObject {
        func viewDidLoad()
        func searchChanged(_ text: String)
        func toggleDone(id: UUID)
        func delete(id: UUID)
        func addTapped()
        func editTapped(id: UUID)
        func todoSaved(_ todo: Todo)
    }
}
