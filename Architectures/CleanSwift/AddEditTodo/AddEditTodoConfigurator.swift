import Foundation
import UIKit

extension CleanSwift {
    enum AddEditTodoConfigurator {
        /// `onFinish` re-enters the result into the presenting scene's cycle
        /// (see `TodoListRouter.navigateToAddEdit`).
        @MainActor
        static func configure(
            _ viewController: AddEditTodoViewController,
            todoToEdit: Todo?,
            onFinish: @escaping (Todo) -> Void
        ) {
            let presenter = AddEditTodoPresenter()
            let interactor = AddEditTodoInteractor()
            let router = AddEditTodoRouter(viewController: viewController)

            viewController.interactor = interactor
            viewController.router = router
            viewController.onSave = onFinish
            interactor.todoToEdit = todoToEdit
            interactor.presenter = presenter
            presenter.viewController = viewController
        }
    }
}
