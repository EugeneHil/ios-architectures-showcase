import UIKit

/// MVVM + Coordinator sample entry point. See `MVC` namespace comment for why samples are namespaced.
enum MVVMCoordinator: ArchitectureModule {
    static let meta = ArchitectureMeta(
        name: "MVVM + Coordinator",
        summary: "MVVM plus coordinator objects that own navigation and module wiring, keeping view models screen-agnostic.",
        ui: .uikit,
        status: .done
    )

    static func makeRoot(repository: any TodoRepository) -> UIViewController {
        let coordinator = TodoListCoordinator(repository: repository)
        return coordinator.start()
    }
}
