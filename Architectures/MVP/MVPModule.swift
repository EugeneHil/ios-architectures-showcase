import UIKit

/// MVP sample entry point. See `MVC` namespace comment for why samples are namespaced.
enum MVP: ArchitectureModule {
    static let meta = ArchitectureMeta(
        name: "MVP",
        summary: "Presentation logic moves into a plain presenter object; the view controller becomes a passive view driven through a protocol.",
        ui: .uikit
    )

    static func makeRoot(repository: any TodoRepository) -> UIViewController {
        PlaceholderSceneViewController(meta: meta)
    }
}
