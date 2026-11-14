import Foundation

extension VIPER {
    /// Form presentation logic. Finishing means reporting through the module output —
    /// this module never dismisses itself; the presenting module's router does.
    @MainActor
    final class AddEditTodoPresenter: AddEditTodoPresenterProtocol {
        struct ViewModel: Equatable {
            var title = ""
            var notes = ""
            var priority: Todo.Priority = .medium
            var isSaveEnabled = false
        }

        weak var view: (any AddEditTodoViewProtocol)?
        var interactor: (any AddEditTodoInteractorProtocol)?
        private weak var moduleOutput: (any AddEditTodoModuleOutput)?

        private var viewModel: ViewModel
        private var didFinish = false

        init(existing: Todo?, moduleOutput: any AddEditTodoModuleOutput) {
            self.moduleOutput = moduleOutput
            self.viewModel = ViewModel(
                title: existing?.title ?? "",
                notes: existing?.notes ?? "",
                priority: existing?.priority ?? .medium,
                isSaveEnabled: existing != nil
            )
        }

        // MARK: AddEditTodoPresenterProtocol

        func start() {
            view?.render(viewModel)
        }

        func titleChanged(_ text: String) {
            viewModel.title = text
            viewModel.isSaveEnabled = interactor?.validateTitle(text) ?? false
            view?.render(viewModel)
        }

        func notesChanged(_ text: String) {
            viewModel.notes = text
        }

        func priorityChanged(_ priority: Todo.Priority) {
            viewModel.priority = priority
        }

        func saveTapped() {
            guard !didFinish, viewModel.isSaveEnabled else { return }
            guard let todo = interactor?.makeTodo(
                title: viewModel.title,
                notes: viewModel.notes,
                priority: viewModel.priority
            ) else { return }
            didFinish = true
            moduleOutput?.addEditTodoDidFinish(with: todo)
        }

        func cancelTapped() {
            moduleOutput?.addEditTodoDidCancel()
        }
    }
}
