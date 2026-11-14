import Foundation

extension VIPER {
    @MainActor
    protocol AddEditTodoViewProtocol: AnyObject {
        func render(_ viewModel: AddEditTodoPresenter.ViewModel)
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

    @MainActor
    protocol AddEditTodoInteractorProtocol: AnyObject {
        func validateTitle(_ title: String) -> Bool
        func makeTodo(title: String, notes: String, priority: Todo.Priority) -> Todo?
    }

    /// How this module reports back to the module that presented it.
    /// Dismissal is owned by the presenting module's router.
    @MainActor
    protocol AddEditTodoModuleOutput: AnyObject {
        func addEditTodoDidFinish(with todo: Todo)
        func addEditTodoDidCancel()
    }
}
