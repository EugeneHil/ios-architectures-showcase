import SwiftUI

@main
struct ArchitecturesShowcaseApp: App {
    /// One repository instance for the whole run; each sample receives it in `makeRoot`.
    private let repository: any TodoRepository = InMemoryTodoRepository()

    var body: some Scene {
        WindowGroup {
            ModuleMenuView(repository: repository)
        }
    }
}
