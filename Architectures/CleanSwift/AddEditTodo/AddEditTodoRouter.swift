import UIKit

extension CleanSwift {
    @MainActor
    protocol AddEditTodoRoutingLogic: AnyObject {
        func navigateBack()
    }

    @MainActor
    final class AddEditTodoRouter: AddEditTodoRoutingLogic {
        private weak var viewController: UIViewController?

        init(viewController: UIViewController) {
            self.viewController = viewController
        }

        func navigateBack() {
            viewController?.dismiss(animated: true)
        }
    }
}
