import ComposableArchitecture
import SwiftUI
import UIKit

/// TCA sample entry point. See `MVC` namespace comment for why samples are namespaced.
///
/// Requires the Composable Architecture package:
/// **File → Add Package Dependencies** → https://github.com/pointfreeco/swift-composable-architecture
enum TCA: ArchitectureModule {
    static let meta = ArchitectureMeta(
        name: "TCA",
        summary: "The Composable Architecture: composable reducers with state, actions, effects and test-friendly dependency injection.",
        ui: .swiftui,
        status: .done
    )

    static func makeRoot(repository: any TodoRepository) -> UIViewController {
        // The store receives the showcase's repository through TCA's dependency system —
        // the same seam tests use to inject a mock.
        let store = Store(initialState: TodoListFeature.State()) {
            TodoListFeature()
        } withDependencies: {
            $0.todoRepository = repository
        }
        return UIHostingController(rootView: TodoListView(store: store))
    }
}
