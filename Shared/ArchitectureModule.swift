import UIKit

/// Metadata describing one architecture sample, rendered by the showcase menu.
struct ArchitectureMeta {
    enum UIKind: String {
        case uikit = "UIKit"
        case swiftui = "SwiftUI"
    }

    enum Status {
        case planned
        case inProgress
        case done

        var symbol: String {
            switch self {
            case .planned: "⚪️"
            case .inProgress: "🚧"
            case .done: "✅"
            }
        }
    }

    let name: String
    let summary: String
    let ui: UIKind
    let status: Status

    init(name: String, summary: String, ui: UIKind, status: Status = .planned) {
        self.name = name
        self.summary = summary
        self.ui = ui
        self.status = status
    }
}

/// Contract every architecture sample exposes to the showcase app.
/// `makeRoot` returns the sample's initial screen wired with the shared repository.
protocol ArchitectureModule {
    static var meta: ArchitectureMeta { get }
    static func makeRoot(repository: any TodoRepository) -> UIViewController
}
