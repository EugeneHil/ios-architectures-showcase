import UIKit

/// Clean Swift (VIP) sample entry point. See `MVC` namespace comment for why samples are namespaced.
enum CleanSwift: ArchitectureModule {
    static let meta = ArchitectureMeta(
        name: "Clean Swift (VIP)",
        summary: "Clean Swift: a view → interactor → presenter cycle with request/response models, worker objects and a configurator.",
        ui: .uikit,
        status: .done
    )

    static func makeRoot(repository: any TodoRepository) -> UIViewController {
        let viewController = TodoListViewController()
        TodoListConfigurator.configure(viewController, repository: repository)
        return viewController
    }
}
