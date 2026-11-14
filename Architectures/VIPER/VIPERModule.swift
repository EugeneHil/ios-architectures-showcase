import UIKit

/// VIPER sample entry point. See `MVC` namespace comment for why samples are namespaced.
enum VIPER: ArchitectureModule {
    static let meta = ArchitectureMeta(
        name: "VIPER",
        summary: "Every screen is a module of six roles (View, Interactor, Presenter, Entity, Router, Assembly) connected through protocols.",
        ui: .uikit
    )

    static func makeRoot(repository: any TodoRepository) -> UIViewController {
        PlaceholderSceneViewController(meta: meta)
    }
}
