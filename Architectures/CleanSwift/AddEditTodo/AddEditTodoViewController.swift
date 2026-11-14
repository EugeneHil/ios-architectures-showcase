import UIKit

extension CleanSwift {
    final class AddEditTodoViewController: UIViewController, AddEditTodoDisplayLogic, UITextViewDelegate, UITextFieldDelegate {
        var interactor: (any AddEditTodoBusinessLogic)?
        var router: (any AddEditTodoRoutingLogic)?
        var onSave: ((Todo) -> Void)?

        private let priorities = Todo.Priority.allCases.sorted { $0.rawValue < $1.rawValue }
        private let titleField = UITextField()
        private let notesView = UITextView()
        private let priorityControl = UISegmentedControl()

        init() {
            super.init(nibName: nil, bundle: nil)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) is not supported")
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .systemGroupedBackground
            title = "Todo"

            navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .cancel,
                target: self,
                action: #selector(cancelTapped)
            )
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .done,
                target: self,
                action: #selector(saveTapped)
            )

            buildForm()
            interactor?.initializeForm(request: AddEditTodoModels.InitializeForm.Request())
        }

        // MARK: Form

        private func buildForm() {
            titleField.placeholder = "Title"
            titleField.borderStyle = .roundedRect
            titleField.returnKeyType = .done
            titleField.delegate = self
            titleField.addTarget(self, action: #selector(titleFieldChanged), for: .editingChanged)

            notesView.font = .preferredFont(forTextStyle: .body)
            notesView.backgroundColor = .secondarySystemGroupedBackground
            notesView.layer.cornerRadius = 8
            notesView.delegate = self

            for (index, priority) in priorities.enumerated() {
                priorityControl.insertSegment(withTitle: priority.title, at: index, animated: false)
            }
            priorityControl.addTarget(self, action: #selector(priorityChanged), for: .valueChanged)

            let stack = UIStackView(arrangedSubviews: [
                Self.fieldLabel("TITLE"),
                titleField,
                Self.fieldLabel("NOTES"),
                notesView,
                Self.fieldLabel("PRIORITY"),
                priorityControl,
            ])
            stack.axis = .vertical
            stack.spacing = 12
            stack.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(stack)

            NSLayoutConstraint.activate([
                stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
                stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
                stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
                notesView.heightAnchor.constraint(equalToConstant: 120),
            ])
        }

        // MARK: AddEditTodoDisplayLogic

        func displayInitializeForm(viewModel: AddEditTodoModels.InitializeForm.ViewModel) {
            titleField.text = viewModel.title
            notesView.text = viewModel.notes
            priorityControl.selectedSegmentIndex = priorities.firstIndex(of: viewModel.priority) ?? 0
            navigationItem.rightBarButtonItem?.isEnabled = viewModel.isSaveEnabled
        }

        func displayTitleValidation(viewModel: AddEditTodoModels.UpdateTitle.ViewModel) {
            navigationItem.rightBarButtonItem?.isEnabled = viewModel.isSaveEnabled
        }

        func displaySaveResult(viewModel: AddEditTodoModels.SaveTodo.ViewModel) {
            guard let todo = viewModel.todo else { return }
            router?.navigateBack()
            onSave?(todo)
        }

        // MARK: User events → requests

        @objc private func titleFieldChanged() {
            interactor?.updateTitle(request: AddEditTodoModels.UpdateTitle.Request(text: titleField.text ?? ""))
        }

        @objc private func priorityChanged() {
            guard priorities.indices.contains(priorityControl.selectedSegmentIndex) else { return }
            interactor?.updatePriority(
                request: AddEditTodoModels.UpdatePriority.Request(priority: priorities[priorityControl.selectedSegmentIndex])
            )
        }

        @objc private func saveTapped() {
            interactor?.saveTodo(request: AddEditTodoModels.SaveTodo.Request())
        }

        @objc private func cancelTapped() {
            router?.navigateBack()
        }

        // MARK: UITextViewDelegate

        func textViewDidChange(_ textView: UITextView) {
            interactor?.updateNotes(request: AddEditTodoModels.UpdateNotes.Request(text: textView.text))
        }

        // MARK: UITextFieldDelegate

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }

        private static func fieldLabel(_ text: String) -> UILabel {
            let label = UILabel()
            label.text = text
            label.font = .systemFont(ofSize: 13, weight: .semibold)
            label.textColor = .secondaryLabel
            return label
        }
    }
}
