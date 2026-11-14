import UIKit

extension MVVMCoordinator {
    /// Flow owner for the list screen: builds the view model + view controller pair,
    /// routes to the add/edit flow and feeds saved todos back into the view model.
    ///
    /// Lifetime: the list view controller keeps this coordinator alive through its
    /// `onAddTodoTapped`/`onEditTodo` closures, while the coordinator holds the VC weakly.
    /// (In a full app the scene delegate or a parent coordinator would own it.)
    final class TodoListCoordinator: Coordinator {
        private let repository: any TodoRepository
        private let viewModel: TodoListViewModel
        private weak var viewController: TodoListViewController?
        private var childCoordinators: [AddEditTodoCoordinator] = []

        init(repository: any TodoRepository) {
            self.repository = repository
            self.viewModel = TodoListViewModel(repository: repository)
        }

        @discardableResult
        func start() -> UIViewController {
            let viewController = TodoListViewController(viewModel: viewModel)
            // Strong captures on purpose: the screen keeps its flow (this coordinator) alive.
            viewController.onAddTodoTapped = { [self] in showAddEdit(existing: nil) }
            viewController.onEditTodo = { [self] todo in showAddEdit(existing: todo) }
            self.viewController = viewController
            return viewController
        }

        private func showAddEdit(existing: Todo?) {
            guard let viewController else { return }
            let child = AddEditTodoCoordinator(
                existing: existing,
                presentingViewController: viewController,
                onFinish: { [weak self] todo in
                    guard let self else { return }
                    self.childCoordinators.removeAll()
                    self.viewModel.todoSaved(todo)
                }
            )
            childCoordinators.append(child)
            child.start()
        }
    }
}
