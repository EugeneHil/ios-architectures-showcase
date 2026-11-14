import UIKit

/// MVP sample entry point. See `MVC` namespace comment for why samples are namespaced.
enum MVP: ArchitectureModule {
    static let meta = ArchitectureMeta(
        name: "MVP",
        summary: "Presentation logic moves into a plain presenter object; the view controller becomes a passive view driven through a protocol.",
        ui: .uikit,
        status: .done
    )

    static func makeRoot(repository: any TodoRepository) -> UIViewController {
        // Wiring happens outside both parties — the view stays fully passive.
        let view = TodoListViewController()
        let presenter = TodoListPresenter(view: view, repository: repository)
        view.presenter = presenter
        return view
    }
}
