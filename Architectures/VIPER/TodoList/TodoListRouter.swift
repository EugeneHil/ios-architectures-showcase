import UIKit

extension VIPER {
    /// Owns navigation for the TodoList module: presents the AddEdit module
    /// built by its assembly and dismisses it when the module output reports back.
    @MainActor
    final class TodoListRouter: TodoListRouterProtocol {
        private weak var viewController: UIViewController?
        private weak var moduleOutput: (any AddEditTodoModuleOutput)?

        init(viewController: UIViewController, moduleOutput: any AddEditTodoModuleOutput) {
            self.viewController = viewController
            self.moduleOutput = moduleOutput
        }

        // MARK: TodoListRouterProtocol

        func showAddTodo() {
            presentAddEdit(existing: nil)
        }

        func showEditTodo(_ todo: Todo) {
            presentAddEdit(existing: todo)
        }

        func dismissAddEdit() {
            viewController?.presentedViewController?.dismiss(animated: true)
        }

        // MARK: Privates

        private func presentAddEdit(existing: Todo?) {
            guard let viewController, let moduleOutput else { return }
            let module = AddEditTodoAssembly.build(existing: existing, moduleOutput: moduleOutput)
            viewController.present(UINavigationController(rootViewController: module), animated: true)
        }
    }
}
