import Foundation

extension MVP {
    @MainActor
    protocol AddEditTodoViewProtocol: AnyObject {
        /// Called whenever state changes. Fields already echo user input,
        /// so only derived values (e.g. save-enabled) re-render.
        func render(_ state: AddEditTodoPresenter.State)
        func close()
    }

    @MainActor
    protocol AddEditTodoPresenterProtocol: AnyObject {
        func start()
        func titleChanged(_ text: String)
        func notesChanged(_ text: String)
        func priorityChanged(_ priority: Todo.Priority)
        func saveTapped()
        func cancelTapped()
    }
}
