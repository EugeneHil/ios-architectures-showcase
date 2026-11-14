import Combine
import UIKit

extension MVVMCombine {
    /// Binds `TodoListViewModel` outputs to the table view and forwards user intents back.
    /// Contains no presentation logic: everything it renders is prepared by the view model.
    final class TodoListViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate {
        private let viewModel: TodoListViewModel
        private var cancellables: Set<AnyCancellable> = []

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

        private lazy var dataSource = UITableViewDiffableDataSource<Int, TodoListViewModel.TodoRow>(
            tableView: tableView
        ) { [weak self] tableView, indexPath, row in
            let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath)
            self?.configure(cell, with: row)
            return cell
        }

        init(viewModel: TodoListViewModel) {
            self.viewModel = viewModel
            super.init(nibName: nil, bundle: nil)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) is not supported")
        }

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
            tableView.dataSource = dataSource
            tableView.delegate = self
            tableView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(tableView)
            NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(equalTo: view.topAnchor),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])

            bind()
            viewModel.viewDidLoad()
        }

        // MARK: Bindings

        private func bind() {
            viewModel.state
                .sink { [weak self] state in self?.render(state) }
                .store(in: &cancellables)

            viewModel.events
                .sink { [weak self] event in self?.handle(event) }
                .store(in: &cancellables)

            viewModel.errors
                .sink { [weak self] message in self?.showError(message) }
                .store(in: &cancellables)
        }

        private func render(_ state: TodoListViewModel.State) {
            var snapshot = NSDiffableDataSourceSnapshot<Int, TodoListViewModel.TodoRow>()
            snapshot.appendSections([0])
            snapshot.appendItems(state.todos)
            dataSource.apply(snapshot, animatingDifferences: true)

            if state.isLoading {
                tableView.backgroundView = spinner
            } else if let message = state.emptyMessage {
                emptyLabel.text = message
                tableView.backgroundView = emptyLabel
            } else {
                tableView.backgroundView = nil
            }
        }

        private func handle(_ event: TodoListViewModel.Event) {
            switch event {
            case .showAddTodo:
                presentAddEdit(existing: nil)
            case .showEditTodo(let todo):
                presentAddEdit(existing: todo)
            }
        }

        // MARK: User intents

        @objc private func addTapped() {
            viewModel.addTodoTapped()
        }

        private func presentAddEdit(existing: Todo?) {
            let addEditViewModel = AddEditTodoViewModel(existing: existing)
            // Plain MVVM wiring: the list screen listens to the form's output.
            // The Coordinator sample exists to move exactly this code elsewhere.
            addEditViewModel.finished
                .sink { [weak self] todo in
                    self?.dismiss(animated: true)
                    self?.viewModel.todoSaved(todo)
                }
                .store(in: &cancellables)

            let viewController = AddEditTodoViewController(viewModel: addEditViewModel)
            present(UINavigationController(rootViewController: viewController), animated: true)
        }

        private func showError(_ message: String) {
            let alert = UIAlertController(title: "Something went wrong", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }

        private func configure(_ cell: UITableViewCell, with row: TodoListViewModel.TodoRow) {
            var configuration = UIListContentConfiguration.cell()
            configuration.attributedText = Self.title(for: row)
            configuration.secondaryText = row.subtitle
            cell.contentConfiguration = configuration
            cell.accessoryType = row.isDone ? .checkmark : .none
        }

        private static func title(for row: TodoListViewModel.TodoRow) -> NSAttributedString {
            guard row.isDone else { return NSAttributedString(string: row.title) }
            return NSAttributedString(
                string: row.title,
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
        }

        // MARK: UISearchBarDelegate

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            viewModel.searchTextChanged(searchText)
        }

        // MARK: UITableViewDelegate

        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            guard let row = dataSource.itemIdentifier(for: indexPath) else { return }
            viewModel.editTodo(row)
        }

        func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            guard let row = dataSource.itemIdentifier(for: indexPath) else { return nil }
            let delete = UIContextualAction(style: .destructive, title: "Delete") { [viewModel] _, _, completion in
                viewModel.delete(row)
                completion(true)
            }
            return UISwipeActionsConfiguration(actions: [delete])
        }

        func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            guard let row = dataSource.itemIdentifier(for: indexPath) else { return nil }
            let toggle = UIContextualAction(style: .normal, title: row.isDone ? "Undo" : "Done") { [viewModel] _, _, completion in
                viewModel.toggleDone(row)
                completion(true)
            }
            toggle.backgroundColor = .systemGreen
            return UISwipeActionsConfiguration(actions: [toggle])
        }
    }
}
