import UIKit

extension VIPER {
    /// The only place that knows all concrete types of the module and wires them together.
    enum TodoListAssembly {
        @MainActor
        static func build(repository: any TodoRepository) -> UIViewController {
            let view = TodoListViewController()
            let presenter = TodoListPresenter()
            let interactor = TodoListInteractor(repository: repository)
            let router = TodoListRouter(viewController: view, moduleOutput: presenter)

            view.presenter = presenter
            presenter.view = view
            presenter.interactor = interactor
            presenter.router = router
            interactor.presenter = presenter

            return view
        }
    }
}
