import UIKit

extension CleanSwift {
    @MainActor
    protocol TodoListDisplayLogic: AnyObject {
        func displayFetchedTodos(viewModel: TodoListModels.FetchTodos.ViewModel)
        func displaySearchedTodos(viewModel: TodoListModels.SearchTodos.ViewModel)
        func displayFailure(viewModel: TodoListModels.Failure.ViewModel)
    }

    /// The V in the VIP cycle: sends requests to the interactor on user events,
    /// displays whatever the presenter formatted.
    final class TodoListViewController: UIViewController, TodoListDisplayLogic, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
        var interactor: (any TodoListBusinessLogic)?
        var router: (any TodoListRoutingLogic)?

        private var rows: [TodoListModels.Row] = []

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

        init() {
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
            tableView.dataSource = self
            tableView.delegate = self
            tableView.backgroundView = spinner
            tableView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(tableView)
            NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(equalTo: view.topAnchor),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])

            interactor?.fetchTodos(request: TodoListModels.FetchTodos.Request())
        }

        // MARK: TodoListDisplayLogic

        func displayFetchedTodos(viewModel: TodoListModels.FetchTodos.ViewModel) {
            render(rows: viewModel.rows, emptyMessage: viewModel.emptyMessage)
        }

        func displaySearchedTodos(viewModel: TodoListModels.SearchTodos.ViewModel) {
            render(rows: viewModel.rows, emptyMessage: viewModel.emptyMessage)
        }

        func displayFailure(viewModel: TodoListModels.Failure.ViewModel) {
            let alert = UIAlertController(title: "Something went wrong", message: viewModel.errorMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }

        // MARK: User events → requests

        @objc private func addTapped() {
            router?.navigateToAddEdit(todo: nil)
        }

        // MARK: UISearchBarDelegate

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            interactor?.searchTodos(request: TodoListModels.SearchTodos.Request(text: searchText))
        }

        // MARK: UITableViewDataSource

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            rows.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath)
            configure(cell, with: rows[indexPath.row])
            return cell
        }

        // MARK: UITableViewDelegate

        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            router?.navigateToAddEdit(todo: rows[indexPath.row].todo)
        }

        func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let row = rows[indexPath.row]
            let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
                self?.interactor?.deleteTodo(request: TodoListModels.DeleteTodo.Request(id: row.todo.id))
                completion(true)
            }
            return UISwipeActionsConfiguration(actions: [delete])
        }

        func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let row = rows[indexPath.row]
            let toggle = UIContextualAction(style: .normal, title: row.isDone ? "Undo" : "Done") { [weak self] _, _, completion in
                self?.interactor?.toggleDone(request: TodoListModels.ToggleDone.Request(id: row.todo.id))
                completion(true)
            }
            toggle.backgroundColor = .systemGreen
            return UISwipeActionsConfiguration(actions: [toggle])
        }

        // MARK: Privates

        private func render(rows: [TodoListModels.Row], emptyMessage: String?) {
            self.rows = rows
            tableView.reloadData()
            if let emptyMessage {
                self.emptyLabel.text = emptyMessage
                tableView.backgroundView = self.emptyLabel
            } else {
                tableView.backgroundView = nil
            }
        }

        private func configure(_ cell: UITableViewCell, with row: TodoListModels.Row) {
            var configuration = UIListContentConfiguration.cell()
            configuration.attributedText = Self.title(for: row)
            configuration.secondaryText = row.subtitle
            cell.contentConfiguration = configuration
            cell.accessoryType = row.isDone ? .checkmark : .none
        }

        private static func title(for row: TodoListModels.Row) -> NSAttributedString {
            guard row.isDone else { return NSAttributedString(string: row.title) }
            return NSAttributedString(
                string: row.title,
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
        }
    }
}
