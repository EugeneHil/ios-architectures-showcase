import Foundation
import UIKit

extension CleanSwift {
    @MainActor
    protocol TodoListRoutingLogic: AnyObject {
        func navigateToAddEdit(todo: Todo?)
    }

    @MainActor
    final class TodoListRouter: TodoListRoutingLogic {
        private weak var viewController: UIViewController?
        private weak var interactor: (any TodoListBusinessLogic)?

        init(viewController: UIViewController, interactor: any TodoListBusinessLogic) {
            self.viewController = viewController
            self.interactor = interactor
        }

        func navigateToAddEdit(todo: Todo?) {
            guard let viewController else { return }
            let destination = AddEditTodoViewController()
            AddEditTodoConfigurator.configure(destination, todoToEdit: todo) { [weak interactor] saved in
                // The result re-enters the scene's cycle as a new request.
                interactor?.saveTodo(request: TodoListModels.SaveTodo.Request(todo: saved))
            }
            viewController.present(UINavigationController(rootViewController: destination), animated: true)
        }
    }
}
