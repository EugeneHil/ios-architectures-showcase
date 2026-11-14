import UIKit

/// MVC sample entry point.
///
/// Every type of the sample lives inside this namespace so identical type names
/// across samples (e.g. `TodoListViewController`) never collide in the single app target.
enum MVC: ArchitectureModule {
    static let meta = ArchitectureMeta(
        name: "MVC",
        summary: "Apple's take on MVC: the view controller owns the view, input handling and most presentation logic — the baseline every other pattern in this repo is compared against.",
        ui: .uikit,
        status: .done
    )

    static func makeRoot(repository: any TodoRepository) -> UIViewController {
        TodoListViewController(repository: repository)
    }
}
