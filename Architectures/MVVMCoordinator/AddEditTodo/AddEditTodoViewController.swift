import Combine
import UIKit

extension MVVMCoordinator {
    final class AddEditTodoViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
        private let viewModel: AddEditTodoViewModel
        private var cancellables: Set<AnyCancellable> = []

        private let priorities = Todo.Priority.allCases.sorted { $0.rawValue < $1.rawValue }
        private let titleField = UITextField()
        private let notesView = UITextView()
        private let priorityControl = UISegmentedControl()

        init(viewModel: AddEditTodoViewModel) {
            self.viewModel = viewModel
            super.init(nibName: nil, bundle: nil)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) is not supported")
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .systemGroupedBackground
            title = viewModel.screenTitle

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
            populateFields()
            bind()
        }

        // MARK: Form

        private func buildForm() {
            titleField.placeholder = "Title"
            titleField.borderStyle = .roundedRect
            titleField.returnKeyType = .done
            titleField.delegate = self

            notesView.font = .preferredFont(forTextStyle: .body)
            notesView.backgroundColor = .secondarySystemGroupedBackground
            notesView.layer.cornerRadius = 8
            notesView.delegate = self

            for (index, priority) in priorities.enumerated() {
                priorityControl.insertSegment(withTitle: priority.title, at: index, animated: false)
            }

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

            titleField.addTarget(self, action: #selector(titleFieldChanged), for: .editingChanged)
            priorityControl.addTarget(self, action: #selector(priorityChanged), for: .valueChanged)
        }

        /// One-time render from the current state; afterwards the fields push changes up.
        private func populateFields() {
            let state = viewModel.state.value
            titleField.text = state.title
            notesView.text = state.notes
            priorityControl.selectedSegmentIndex = priorities.firstIndex(of: state.priority) ?? 0
        }

        private func bind() {
            viewModel.state
                .map(\.isSaveEnabled)
                .removeDuplicates()
                .sink { [weak self] isEnabled in
                    self?.navigationItem.rightBarButtonItem?.isEnabled = isEnabled
                }
                .store(in: &cancellables)
        }

        // MARK: User intents

        @objc private func titleFieldChanged() {
            viewModel.titleChanged(titleField.text ?? "")
        }

        @objc private func priorityChanged() {
            guard priorities.indices.contains(priorityControl.selectedSegmentIndex) else { return }
            viewModel.priorityChanged(priorities[priorityControl.selectedSegmentIndex])
        }

        @objc private func saveTapped() {
            viewModel.saveTapped()
            // Dismissal happens in AddEditTodoCoordinator on `finished`.
        }

        @objc private func cancelTapped() {
            dismiss(animated: true)
        }

        // MARK: UITextViewDelegate

        func textViewDidChange(_ textView: UITextView) {
            viewModel.notesChanged(textView.text)
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
