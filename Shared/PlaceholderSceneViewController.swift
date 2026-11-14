import UIKit

/// Temporary root scene shown until the architecture sample is implemented.
final class PlaceholderSceneViewController: UIViewController {
    private let meta: ArchitectureMeta

    init(meta: ArchitectureMeta) {
        self.meta = meta
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = meta.name

        let titleLabel = UILabel()
        titleLabel.text = "\(meta.name) — not implemented yet"
        titleLabel.font = .preferredFont(forTextStyle: .title2)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 0

        let summaryLabel = UILabel()
        summaryLabel.text = meta.summary
        summaryLabel.font = .preferredFont(forTextStyle: .body)
        summaryLabel.adjustsFontForContentSizeCategory = true
        summaryLabel.textColor = .secondaryLabel
        summaryLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [titleLabel, summaryLabel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: stack.trailingAnchor, multiplier: 2),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}
