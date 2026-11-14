import SwiftUI
import UIKit

/// MVI sample entry point. See `MVC` namespace comment for why samples are namespaced.
enum MVI: ArchitectureModule {
    static let meta = ArchitectureMeta(
        name: "MVI",
        summary: "Hand-rolled unidirectional data flow: a single immutable state, an intent enum and a pure reducer — the idea TCA is built on.",
        ui: .swiftui,
        status: .done
    )

    static func makeRoot(repository: any TodoRepository) -> UIViewController {
        UIHostingController(rootView: TodoListView(repository: repository))
    }
}
