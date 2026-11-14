import UIKit

extension VIPER {
    enum AddEditTodoAssembly {
        @MainActor
        static func build(existing: Todo?, moduleOutput: any AddEditTodoModuleOutput) -> UIViewController {
            let view = AddEditTodoViewController()
            let presenter = AddEditTodoPresenter(existing: existing, moduleOutput: moduleOutput)
            let interactor = AddEditTodoInteractor(existing: existing)

            view.presenter = presenter
            presenter.view = view
            presenter.interactor = interactor

            return view
        }
    }
}
