import Foundation

extension MVI {
    /// Everything that can happen: user intents and system intents —
    /// results of side effects re-enter the system as intents too.
    enum TodoListIntent: Equatable {
        // Lifecycle
        case onAppear

        // User: list
        case searchChanged(String)
        case toggleDone(UUID)
        case delete(UUID)
        case addTapped
        case editTapped(UUID)

        // User: edit form
        case editTitleChanged(String)
        case editNotesChanged(String)
        case editPriorityChanged(Todo.Priority)
        case editSaveTapped
        case editDismissed

        // System (effect results)
        case todosLoaded([Todo])
        case failed(String)
        case errorDismissed
    }

    /// Side effects declared by the reducer, executed by the store.
    enum TodoListEffect: Equatable {
        case fetchAll
        case persist(Todo)
        case delete(UUID)
    }
}
