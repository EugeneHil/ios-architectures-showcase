import Foundation

extension CleanSwift {
    @MainActor
    final class AddEditTodoPresenter: AddEditTodoPresentationLogic {
        weak var viewController: (any AddEditTodoDisplayLogic)?

        func presentInitializeForm(response: AddEditTodoModels.InitializeForm.Response) {
            viewController?.displayInitializeForm(
                viewModel: AddEditTodoModels.InitializeForm.ViewModel(
                    title: response.title,
                    notes: response.notes,
                    priority: response.priority,
                    isSaveEnabled: response.isSaveEnabled
                )
            )
        }

        func presentTitleValidation(response: AddEditTodoModels.UpdateTitle.Response) {
            viewController?.displayTitleValidation(
                viewModel: AddEditTodoModels.UpdateTitle.ViewModel(isSaveEnabled: response.isValid)
            )
        }

        func presentSaveResult(response: AddEditTodoModels.SaveTodo.Response) {
            viewController?.displaySaveResult(viewModel: AddEditTodoModels.SaveTodo.ViewModel(todo: response.todo))
        }
    }
}
