import UIKit

/// TCA sample entry point. See `MVC` namespace comment for why samples are namespaced.
///
/// When implemented: add the Composable Architecture package
/// (https://github.com/pointfreeco/swift-composable-architecture) and return a
/// `UIHostingController` with the feature's root view.
enum TCA: ArchitectureModule {
    static let meta = ArchitectureMeta(
        name: "TCA",
        summary: "The Composable Architecture: composable reducers with state, actions, effects and test-friendly dependency injection.",
        ui: .swiftui
    )

    static func makeRoot(repository: any TodoRepository) -> UIViewController {
        PlaceholderSceneViewController(meta: meta)
    }
}
