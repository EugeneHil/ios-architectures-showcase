import UIKit

extension VIPER {
    final class AddEditTodoViewController: UIViewController, AddEditTodoViewProtocol, UITextViewDelegate, UITextFieldDelegate {
        var presenter: (any AddEditTodoPresenterProtocol)?

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
            presenter?.start()
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

        // MARK: AddEditTodoViewProtocol

        func render(_ viewModel: AddEditTodoPresenter.ViewModel) {
            // Fields already echo user input; only initial values and derived state re-render.
            if titleField.text == "" && viewModel.title.isEmpty == false {
                titleField.text = viewModel.title
            }
            if notesView.text == "" && viewModel.notes.isEmpty == false {
                notesView.text = viewModel.notes
            }
            priorityControl.selectedSegmentIndex = priorities.firstIndex(of: viewModel.priority) ?? 0
            navigationItem.rightBarButtonItem?.isEnabled = viewModel.isSaveEnabled
        }

        // MARK: User events → presenter

        @objc private func titleFieldChanged() {
            presenter?.titleChanged(titleField.text ?? "")
        }

        @objc private func priorityChanged() {
            guard priorities.indices.contains(priorityControl.selectedSegmentIndex) else { return }
            presenter?.priorityChanged(priorities[priorityControl.selectedSegmentIndex])
        }

        @objc private func saveTapped() {
            presenter?.saveTapped()
        }

        @objc private func cancelTapped() {
            presenter?.cancelTapped()
        }

        // MARK: UITextViewDelegate

        func textViewDidChange(_ textView: UITextView) {
            presenter?.notesChanged(textView.text)
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
