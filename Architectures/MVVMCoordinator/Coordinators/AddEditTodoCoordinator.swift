import Combine
import UIKit

extension MVVMCoordinator {
    /// Child flow: builds the add/edit screen, dismisses it on finish and
    /// hands the result back to the parent coordinator.
    final class AddEditTodoCoordinator: Coordinator {
        private let existing: Todo?
        private let presentingViewController: UIViewController
        private let onFinish: (Todo) -> Void
        private var cancellables: Set<AnyCancellable> = []

        init(
            existing: Todo?,
            presentingViewController: UIViewController,
            onFinish: @escaping (Todo) -> Void
        ) {
            self.existing = existing
            self.presentingViewController = presentingViewController
            self.onFinish = onFinish
        }

        @discardableResult
        func start() -> UIViewController {
            let viewModel = AddEditTodoViewModel(existing: existing)
            viewModel.finished
                .sink { [weak self] todo in
                    self?.finish(with: todo)
                }
                .store(in: &cancellables)

            let viewController = AddEditTodoViewController(viewModel: viewModel)
            presentingViewController.present(
                UINavigationController(rootViewController: viewController),
                animated: true
            )
            return viewController
        }

        private func finish(with todo: Todo) {
            presentingViewController.dismiss(animated: true)
            onFinish(todo)
        }
    }
}
