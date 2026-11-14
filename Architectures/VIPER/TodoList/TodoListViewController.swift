import UIKit

extension VIPER {
    /// Passive VIPER view: forwards events to the presenter, renders its view models.
    final class TodoListViewController: UIViewController, TodoListViewProtocol, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
        var presenter: (any TodoListPresenterProtocol)?

        private var rows: [TodoListPresenter.TodoRow] = []

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

            presenter?.viewDidLoad()
        }

        // MARK: TodoListViewProtocol

        func render(_ viewModel: TodoListPresenter.ViewModel) {
            rows = viewModel.rows
            tableView.reloadData()
            if let message = viewModel.emptyMessage {
                emptyLabel.text = message
                tableView.backgroundView = emptyLabel
            } else if rows.isEmpty == false {
                tableView.backgroundView = nil
            }
        }

        func showError(_ message: String) {
            let alert = UIAlertController(title: "Something went wrong", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }

        // MARK: User events → presenter

        @objc private func addTapped() {
            presenter?.addTapped()
        }

        // MARK: UISearchBarDelegate

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            presenter?.searchChanged(searchText)
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
            presenter?.editTapped(id: rows[indexPath.row].id)
        }

        func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let row = rows[indexPath.row]
            let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
                self?.presenter?.delete(id: row.id)
                completion(true)
            }
            return UISwipeActionsConfiguration(actions: [delete])
        }

        func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let row = rows[indexPath.row]
            let toggle = UIContextualAction(style: .normal, title: row.isDone ? "Undo" : "Done") { [weak self] _, _, completion in
                self?.presenter?.toggleDone(id: row.id)
                completion(true)
            }
            toggle.backgroundColor = .systemGreen
            return UISwipeActionsConfiguration(actions: [toggle])
        }

        private func configure(_ cell: UITableViewCell, with row: TodoListPresenter.TodoRow) {
            var configuration = UIListContentConfiguration.cell()
            configuration.attributedText = Self.title(for: row)
            configuration.secondaryText = row.subtitle
            cell.contentConfiguration = configuration
            cell.accessoryType = row.isDone ? .checkmark : .none
        }

        private static func title(for row: TodoListPresenter.TodoRow) -> NSAttributedString {
            guard row.isDone else { return NSAttributedString(string: row.title) }
            return NSAttributedString(
                string: row.title,
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
        }
    }
}
