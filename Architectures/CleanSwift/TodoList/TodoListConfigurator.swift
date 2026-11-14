import Foundation
import UIKit

extension CleanSwift {
    /// Wires the VIP cycle for the scene and injects the worker —
    /// the configurator is the only place that knows every concrete type.
    enum TodoListConfigurator {
        @MainActor
        static func configure(_ viewController: TodoListViewController, repository: any TodoRepository) {
            let presenter = TodoListPresenter()
            let interactor = TodoListInteractor()
            let worker = TodoListWorker(repository: repository)
            let router = TodoListRouter(viewController: viewController, interactor: interactor)

            viewController.interactor = interactor
            viewController.router = router
            interactor.worker = worker
            interactor.presenter = presenter
            presenter.viewController = viewController
        }
    }
}
