import UIKit

extension MVC {
    /// Apple-flavoured MVC: one object is the view owner, input handler, formatter,
    /// navigator and data loader at once. This file *is* the pattern — compare its
    /// size and the number of its responsibilities with any other sample.
    final class TodoListViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
        private let repository: any TodoRepository
        private var todos: [Todo] = []
        private var searchText = ""

        private lazy var tableView = UITableView(frame: .zero, style: .insetGrouped)
        private lazy var searchBar = UISearchBar()
        private lazy var spinner: UIActivityIndicatorView = {
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.startAnimating()
            return spinner
        }()
        private lazy var emptyLabel: UILabel = {
            let label = UILabel()
            label.font = .preferredFont(forTextStyle: .subheadline)
            label.textColor = .secondaryLabel
            label.textAlignment = .center
            label.numberOfLines = 0
            return label
        }()

        init(repository: any TodoRepository) {
            self.repository = repository
            super.init(nibName: nil, bundle: nil)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) is not supported")
        }

        // MARK: Lifecycle — view setup, because who else

        override func viewDidLoad() {
            super.viewDidLoad()
            title = "Todos"

            navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .add,
                target: self,
                action: #selector(addTapped)
            )

            searchBar.placeholder = "Search"
            searchBar.delegate = self
            searchBar.sizeToFit()
            tableView.tableHeaderView = searchBar

            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TodoCell")
            tableView.dataSource = self
            tableView.delegate = self
            tableView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(tableView)
            NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(equalTo: view.topAnchor),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])

            Task { await reload() }
        }

        // MARK: Data loading — also us

        private func reload() async {
            do {
                todos = try await repository.fetchAll()
            } catch {
                showError(Self.message(for: error))
            }
            tableView.reloadData()
            updateBackgroundView()
        }

        /// Insert-or-update by id, then refresh — business rules in the view controller.
        private func save(_ todo: Todo) async {
            do {
                if todos.contains(where: { $0.id == todo.id }) {
                    try await repository.update(todo)
                } else {
                    try await repository.add(todo)
                }
                await reload()
            } catch {
                showError(Self.message(for: error))
            }
        }

        private func toggle(_ todo: Todo) {
            var updated = todo
            updated.isDone.toggle()
            Task { await save(updated) }
        }

        // MARK: Presentation logic — formatting lives here too

        private var filteredTodos: [Todo] {
            let query = searchText.trimmingCharacters(in: .whitespaces)
            guard !query.isEmpty else { return todos }
            return todos.filter {
                $0.title.localizedCaseInsensitiveContains(query)
                    || $0.notes.localizedCaseInsensitiveContains(query)
            }
        }

        private func updateBackgroundView() {
            let visible = filteredTodos
            if visible.isEmpty && !searchText.isEmpty {
                emptyLabel.text = "Nothing matches \"\(searchText)\"."
                tableView.backgroundView = emptyLabel
            } else if visible.isEmpty {
                emptyLabel.text = "No todos yet — tap + to add one."
                tableView.backgroundView = emptyLabel
            } else {
                tableView.backgroundView = nil
            }
        }

        // MARK: Actions and navigation — us again

        @objc private func addTapped() {
            presentAddEdit(existing: nil)
        }

        private func presentAddEdit(existing: Todo?) {
            let viewController = AddEditTodoViewController(existing: existing) { [weak self] todo in
                self?.dismiss(animated: true)
                Task { await self?.save(todo) }
            }
            present(UINavigationController(rootViewController: viewController), animated: true)
        }

        private func showError(_ message: String) {
            let alert = UIAlertController(title: "Something went wrong", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }

        // MARK: UISearchBarDelegate

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            self.searchText = searchText
            tableView.reloadData()
            updateBackgroundView()
        }

        // MARK: UITableViewDataSource — classic, no diffable

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            filteredTodos.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath)
            let todo = filteredTodos[indexPath.row]
            var configuration = UIListContentConfiguration.cell()
            configuration.attributedText = Self.title(for: todo)
            configuration.secondaryText = Self.subtitle(for: todo)
            cell.contentConfiguration = configuration
            cell.accessoryType = todo.isDone ? .checkmark : .none
            return cell
        }

        // MARK: UITableViewDelegate — and input handling

        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            presentAddEdit(existing: filteredTodos[indexPath.row])
        }

        func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let todo = filteredTodos[indexPath.row]
            let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
                Task {
                    do {
                        try await self?.repository.delete(id: todo.id)
                        await self?.reload()
                    } catch {
                        self?.showError(Self.message(for: error))
                    }
                    completion(true)
                }
            }
            return UISwipeActionsConfiguration(actions: [delete])
        }

        func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let todo = filteredTodos[indexPath.row]
            let toggle = UIContextualAction(style: .normal, title: todo.isDone ? "Undo" : "Done") { [weak self] _, _, completion in
                self?.toggle(todo)
                completion(true)
            }
            toggle.backgroundColor = .systemGreen
            return UISwipeActionsConfiguration(actions: [toggle])
        }

        // MARK: Formatting helpers

        private static func subtitle(for todo: Todo) -> String {
            [todo.priority.title, todo.notes.isEmpty ? nil : todo.notes]
                .compactMap(\.self)
                .joined(separator: " · ")
        }

        private static func title(for todo: Todo) -> NSAttributedString {
            guard todo.isDone else { return NSAttributedString(string: todo.title) }
            return NSAttributedString(
                string: todo.title,
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
        }

        private static func message(for error: Error) -> String {
            if let repositoryError = error as? TodoRepositoryError {
                switch repositoryError {
                case .notFound: return "This todo no longer exists."
                case .storageFailed(let reason): return reason
                }
            }
            return error.localizedDescription
        }
    }
}
