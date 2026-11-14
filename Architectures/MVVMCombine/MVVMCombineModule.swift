import UIKit

/// MVVM + Combine sample entry point. See `MVC` namespace comment for why samples are namespaced.
enum MVVMCombine: ArchitectureModule {
    static let meta = ArchitectureMeta(
        name: "MVVM + Combine",
        summary: "A view model exposes observable state and intent methods; the UIKit view controller binds to it with Combine.",
        ui: .uikit,
        status: .done
    )

    static func makeRoot(repository: any TodoRepository) -> UIViewController {
        let viewModel = TodoListViewModel(repository: repository)
        return TodoListViewController(viewModel: viewModel)
    }
}
