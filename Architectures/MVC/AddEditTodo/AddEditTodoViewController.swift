import UIKit

extension MVC {
    /// The form screen in MVC: owns its fields, validation and the save flow,
    /// and reports the result back through a closure.
    final class AddEditTodoViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
        private let existing: Todo?
        private let onSave: (Todo) -> Void
        private var didSave = false

        private let priorities = Todo.Priority.allCases.sorted { $0.rawValue < $1.rawValue }
        private let titleField = UITextField()
        private let notesView = UITextView()
        private let priorityControl = UISegmentedControl()

        init(existing: Todo?, onSave: @escaping (Todo) -> Void) {
            self.existing = existing
            self.onSave = onSave
            super.init(nibName: nil, bundle: nil)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) is not supported")
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .systemGroupedBackground
            title = existing == nil ? "New Todo" : "Edit Todo"

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
            validate()
        }

        // MARK: Form

        private func buildForm() {
            titleField.placeholder = "Title"
            titleField.borderStyle = .roundedRect
            titleField.returnKeyType = .done
            titleField.delegate = self
            titleField.addTarget(self, action: #selector(fieldsChanged), for: .editingChanged)

            notesView.font = .preferredFont(forTextStyle: .body)
            notesView.backgroundColor = .secondarySystemGroupedBackground
            notesView.layer.cornerRadius = 8
            notesView.delegate = self

            for (index, priority) in priorities.enumerated() {
                priorityControl.insertSegment(withTitle: priority.title, at: index, animated: false)
            }
            priorityControl.addTarget(self, action: #selector(fieldsChanged), for: .valueChanged)

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

        private func populateFields() {
            titleField.text = existing?.title ?? ""
            notesView.text = existing?.notes ?? ""
            priorityControl.selectedSegmentIndex = priorities.firstIndex(of: existing?.priority ?? .medium) ?? 0
        }

        /// Validation is a view concern here — there is nowhere else to put it.
        private func validate() {
            let title = (titleField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            navigationItem.rightBarButtonItem?.isEnabled = !title.isEmpty
        }

        // MARK: Actions

        @objc private func fieldsChanged() {
            validate()
        }

        @objc private func saveTapped() {
            guard !didSave, let barButton = navigationItem.rightBarButtonItem, barButton.isEnabled else { return }
            didSave = true

            var todo = existing ?? Todo(title: "")
            todo.title = (titleField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            todo.notes = (notesView.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard priorities.indices.contains(priorityControl.selectedSegmentIndex) else { return }
            todo.priority = priorities[priorityControl.selectedSegmentIndex]
            onSave(todo)
        }

        @objc private func cancelTapped() {
            dismiss(animated: true)
        }

        // MARK: UITextViewDelegate

        func textViewDidChange(_ textView: UITextView) {
            validate()
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
