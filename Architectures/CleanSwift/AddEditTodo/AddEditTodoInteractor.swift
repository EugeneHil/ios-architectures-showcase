import Foundation

extension CleanSwift {
    @MainActor
    protocol AddEditTodoBusinessLogic: AnyObject {
        func initializeForm(request: AddEditTodoModels.InitializeForm.Request)
        func updateTitle(request: AddEditTodoModels.UpdateTitle.Request)
        func updateNotes(request: AddEditTodoModels.UpdateNotes.Request)
        func updatePriority(request: AddEditTodoModels.UpdatePriority.Request)
        func saveTodo(request: AddEditTodoModels.SaveTodo.Request)
    }

    @MainActor
    protocol AddEditTodoPresentationLogic: AnyObject {
        func presentInitializeForm(response: AddEditTodoModels.InitializeForm.Response)
        func presentTitleValidation(response: AddEditTodoModels.UpdateTitle.Response)
        func presentSaveResult(response: AddEditTodoModels.SaveTodo.Response)
    }

    @MainActor
    protocol AddEditTodoDisplayLogic: AnyObject {
        func displayInitializeForm(viewModel: AddEditTodoModels.InitializeForm.ViewModel)
        func displayTitleValidation(viewModel: AddEditTodoModels.UpdateTitle.ViewModel)
        func displaySaveResult(viewModel: AddEditTodoModels.SaveTodo.ViewModel)
    }

    /// Clean Swift data store: how the presenting scene would pass data in.
    @MainActor
    protocol AddEditTodoDataStore: AnyObject {
        var todoToEdit: Todo? { get set }
    }

    @MainActor
    final class AddEditTodoInteractor: AddEditTodoBusinessLogic, AddEditTodoDataStore {
        var presenter: (any AddEditTodoPresentationLogic)?
        var todoToEdit: Todo?

        private var title = ""
        private var notes = ""
        private var priority: Todo.Priority = .medium

        // MARK: AddEditTodoBusinessLogic

        func initializeForm(request: AddEditTodoModels.InitializeForm.Request) {
            title = todoToEdit?.title ?? ""
            notes = todoToEdit?.notes ?? ""
            priority = todoToEdit?.priority ?? .medium
            presenter?.presentInitializeForm(
                response: AddEditTodoModels.InitializeForm.Response(
                    title: title,
                    notes: notes,
                    priority: priority,
                    isSaveEnabled: todoToEdit != nil
                )
            )
        }

        func updateTitle(request: AddEditTodoModels.UpdateTitle.Request) {
            title = request.text
            presenter?.presentTitleValidation(
                response: AddEditTodoModels.UpdateTitle.Response(isValid: isValidTitle)
            )
        }

        func updateNotes(request: AddEditTodoModels.UpdateNotes.Request) {
            notes = request.text
        }

        func updatePriority(request: AddEditTodoModels.UpdatePriority.Request) {
            priority = request.priority
        }

        func saveTodo(request: AddEditTodoModels.SaveTodo.Request) {
            var todo = todoToEdit ?? Todo(title: "")
            todo.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
            todo.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
            todo.priority = priority
            presenter?.presentSaveResult(response: AddEditTodoModels.SaveTodo.Response(todo: isValidTitle ? todo : nil))
        }

        private var isValidTitle: Bool {
            !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
}
