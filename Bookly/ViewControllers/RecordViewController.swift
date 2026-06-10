import UIKit

final class RecordViewController: UIViewController {
    private enum RecordFilter: Int, CaseIterable {
        case wish
        case reading
        case done
        
        var title: String {
            switch self {
            case .wish:
                return "WISH"
            case .reading:
                return "READING"
            case .done:
                return "DONE"
            }
        }
        
        var status: BookStatus {
            switch self {
            case .wish:
                return .wish
            case .reading:
                return .reading
            case .done:
                return .done
            }
        }
        
        var emptyTitle: String {
            switch self {
            case .wish:
                return "아직 WISH 기록이 없어요"
            case .reading:
                return "아직 READING 기록이 없어요"
            case .done:
                return "아직 DONE 기록이 없어요"
            }
        }
        
        var emptyDescription: String {
            switch self {
            case .wish:
                return "읽고 싶은 책을 저장하면 이곳에서 기록할 수 있어요."
            case .reading:
                return "읽기 시작한 책을 저장하면 이곳에서 기록을 이어갈 수 있어요."
            case .done:
                return "완독한 책을 눌러 한줄평과 별점을 남겨보세요."
            }
        }
    }
    
    private let store = BookStore.shared
    
    private let headerView = UIView()
    private let logoLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let pageTitleLabel = UILabel()
    
    private let countBadgeView = UIView()
    private let countBadgeIconImageView = UIImageView()
    private let countBadgeLabel = UILabel()
    
    private let filterSegmentedControl = UISegmentedControl(
        items: RecordFilter.allCases.map { $0.title }
    )
    
    private let contentPanelView = UIView()
    private let tableView = UITableView()
    
    private let emptyContainerView = UIView()
    private let emptyIconImageView = UIImageView()
    private let emptyTitleLabel = UILabel()
    private let emptyDescriptionLabel = UILabel()
    
    private var selectedFilter: RecordFilter = .wish
    
    private let navyColor = UIColor(red: 0.02, green: 0.10, blue: 0.28, alpha: 1.0)
    private let purpleColor = UIColor(red: 0.33, green: 0.25, blue: 0.94, alpha: 1.0)
    private let mutedTextColor = UIColor(red: 0.55, green: 0.56, blue: 0.62, alpha: 1.0)
    
    private var filteredBooks: [Book] {
        store.books
            .filter { $0.status == selectedFilter.status }
            .sorted { first, second in
                if first.displayRating == second.displayRating {
                    return first.createdAt > second.createdAt
                }
                return first.displayRating > second.displayRating
            }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = ""
        view.backgroundColor = navyColor
        
        configureUI()
        configureNotification()
        reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        navigationController?.tabBarItem.title = "독서 기록"
        navigationController?.tabBarItem.image = UIImage(systemName: "star")
        navigationController?.tabBarItem.selectedImage = UIImage(systemName: "star.fill")
        navigationController?.tabBarItem.imageInsets = .zero
        navigationController?.tabBarItem.titlePositionAdjustment = .zero
        
        tabBarController?.tabBar.items?[0].title = "Bookly"
        tabBarController?.tabBar.items?[1].title = "검색"
        tabBarController?.tabBar.items?[2].title = "나의 서재"
        tabBarController?.tabBar.items?[3].title = "독서 기록"
        
        reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func configureNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBookStoreChange),
            name: .bookStoreDidChange,
            object: nil
        )
    }
    
    @objc private func handleBookStoreChange() {
        reloadData()
    }
    
    private func configureUI() {
        configureHeaderView()
        configureContentPanelView()
        configureTableView()
        configureEmptyView()
    }
    
    private func configureHeaderView() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = navyColor
        
        logoLabel.translatesAutoresizingMaskIntoConstraints = false
        logoLabel.text = "Bookly"
        logoLabel.font = UIFont(name: "Georgia-BoldItalic", size: 36) ?? .italicSystemFont(ofSize: 36)
        logoLabel.textColor = .white
        logoLabel.textAlignment = .left
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "기록할수록 나의 독서가 완성된다 ✦"
        subtitleLabel.font = .systemFont(ofSize: 11, weight: .medium)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.78)
        
        pageTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        pageTitleLabel.text = "독서 기록"
        pageTitleLabel.font = .boldSystemFont(ofSize: 32)
        pageTitleLabel.textColor = .white
        
        countBadgeView.translatesAutoresizingMaskIntoConstraints = false
        countBadgeView.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        countBadgeView.layer.cornerRadius = 17
        countBadgeView.clipsToBounds = true
        
        countBadgeIconImageView.translatesAutoresizingMaskIntoConstraints = false
        countBadgeIconImageView.image = UIImage(systemName: "quote.bubble.fill")
        countBadgeIconImageView.tintColor = UIColor.white.withAlphaComponent(0.92)
        countBadgeIconImageView.contentMode = .scaleAspectFit
        
        countBadgeLabel.translatesAutoresizingMaskIntoConstraints = false
        countBadgeLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        countBadgeLabel.textColor = UIColor.white.withAlphaComponent(0.92)
        countBadgeLabel.numberOfLines = 1
        
        countBadgeView.addSubview(countBadgeIconImageView)
        countBadgeView.addSubview(countBadgeLabel)
        
        filterSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        filterSegmentedControl.selectedSegmentIndex = selectedFilter.rawValue
        filterSegmentedControl.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        filterSegmentedControl.selectedSegmentTintColor = purpleColor
        filterSegmentedControl.setTitleTextAttributes(
            [
                .foregroundColor: UIColor.white.withAlphaComponent(0.82),
                .font: UIFont.systemFont(ofSize: 13, weight: .semibold)
            ],
            for: .normal
        )
        filterSegmentedControl.setTitleTextAttributes(
            [
                .foregroundColor: UIColor.white,
                .font: UIFont.boldSystemFont(ofSize: 13)
            ],
            for: .selected
        )
        filterSegmentedControl.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        
        view.addSubview(headerView)
        headerView.addSubview(logoLabel)
        headerView.addSubview(subtitleLabel)
        headerView.addSubview(pageTitleLabel)
        headerView.addSubview(countBadgeView)
        headerView.addSubview(filterSegmentedControl)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 356),
            
            logoLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            logoLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 22),
            logoLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -22),
            
            subtitleLabel.topAnchor.constraint(equalTo: logoLabel.bottomAnchor, constant: 5),
            subtitleLabel.leadingAnchor.constraint(equalTo: logoLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: logoLabel.trailingAnchor),
            
            pageTitleLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            pageTitleLabel.leadingAnchor.constraint(equalTo: logoLabel.leadingAnchor),
            pageTitleLabel.trailingAnchor.constraint(equalTo: logoLabel.trailingAnchor),
            
            countBadgeView.topAnchor.constraint(equalTo: pageTitleLabel.bottomAnchor, constant: 10),
            countBadgeView.leadingAnchor.constraint(equalTo: logoLabel.leadingAnchor),
            countBadgeView.heightAnchor.constraint(equalToConstant: 34),
            countBadgeView.trailingAnchor.constraint(lessThanOrEqualTo: headerView.trailingAnchor, constant: -22),
            
            countBadgeIconImageView.leadingAnchor.constraint(equalTo: countBadgeView.leadingAnchor, constant: 14),
            countBadgeIconImageView.centerYAnchor.constraint(equalTo: countBadgeView.centerYAnchor),
            countBadgeIconImageView.widthAnchor.constraint(equalToConstant: 16),
            countBadgeIconImageView.heightAnchor.constraint(equalToConstant: 16),
            
            countBadgeLabel.leadingAnchor.constraint(equalTo: countBadgeIconImageView.trailingAnchor, constant: 9),
            countBadgeLabel.trailingAnchor.constraint(equalTo: countBadgeView.trailingAnchor, constant: -14),
            countBadgeLabel.centerYAnchor.constraint(equalTo: countBadgeView.centerYAnchor),
            
            filterSegmentedControl.topAnchor.constraint(equalTo: countBadgeView.bottomAnchor, constant: 22),
            filterSegmentedControl.leadingAnchor.constraint(equalTo: logoLabel.leadingAnchor),
            filterSegmentedControl.trailingAnchor.constraint(equalTo: logoLabel.trailingAnchor),
            filterSegmentedControl.heightAnchor.constraint(equalToConstant: 42),
            filterSegmentedControl.bottomAnchor.constraint(lessThanOrEqualTo: headerView.bottomAnchor, constant: -44)
        ])
    }
    
    private func configureContentPanelView() {
        contentPanelView.translatesAutoresizingMaskIntoConstraints = false
        contentPanelView.backgroundColor = .white
        contentPanelView.layer.cornerRadius = 34
        contentPanelView.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
        contentPanelView.clipsToBounds = true
        
        view.addSubview(contentPanelView)
        
        NSLayoutConstraint.activate([
            contentPanelView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -34),
            contentPanelView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentPanelView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentPanelView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = 158
        tableView.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 120, right: 0)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(RecordBookCell.self, forCellReuseIdentifier: RecordBookCell.identifier)
        
        contentPanelView.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: contentPanelView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: contentPanelView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentPanelView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: contentPanelView.bottomAnchor)
        ])
    }
    
    private func configureEmptyView() {
        emptyContainerView.translatesAutoresizingMaskIntoConstraints = false
        emptyContainerView.isHidden = true
        
        emptyIconImageView.translatesAutoresizingMaskIntoConstraints = false
        emptyIconImageView.image = UIImage(systemName: "books.vertical.fill")
        emptyIconImageView.tintColor = navyColor.withAlphaComponent(0.75)
        emptyIconImageView.contentMode = .scaleAspectFit
        
        emptyTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyTitleLabel.font = .boldSystemFont(ofSize: 19)
        emptyTitleLabel.textColor = navyColor
        emptyTitleLabel.textAlignment = .center
        
        emptyDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyDescriptionLabel.font = .systemFont(ofSize: 13, weight: .medium)
        emptyDescriptionLabel.textColor = mutedTextColor
        emptyDescriptionLabel.textAlignment = .center
        emptyDescriptionLabel.numberOfLines = 0
        
        contentPanelView.addSubview(emptyContainerView)
        emptyContainerView.addSubview(emptyIconImageView)
        emptyContainerView.addSubview(emptyTitleLabel)
        emptyContainerView.addSubview(emptyDescriptionLabel)
        
        NSLayoutConstraint.activate([
            emptyContainerView.centerXAnchor.constraint(equalTo: contentPanelView.centerXAnchor),
            emptyContainerView.centerYAnchor.constraint(equalTo: contentPanelView.centerYAnchor, constant: -34),
            emptyContainerView.leadingAnchor.constraint(equalTo: contentPanelView.leadingAnchor, constant: 32),
            emptyContainerView.trailingAnchor.constraint(equalTo: contentPanelView.trailingAnchor, constant: -32),
            
            emptyIconImageView.topAnchor.constraint(equalTo: emptyContainerView.topAnchor),
            emptyIconImageView.centerXAnchor.constraint(equalTo: emptyContainerView.centerXAnchor),
            emptyIconImageView.widthAnchor.constraint(equalToConstant: 44),
            emptyIconImageView.heightAnchor.constraint(equalToConstant: 44),
            
            emptyTitleLabel.topAnchor.constraint(equalTo: emptyIconImageView.bottomAnchor, constant: 16),
            emptyTitleLabel.leadingAnchor.constraint(equalTo: emptyContainerView.leadingAnchor),
            emptyTitleLabel.trailingAnchor.constraint(equalTo: emptyContainerView.trailingAnchor),
            
            emptyDescriptionLabel.topAnchor.constraint(equalTo: emptyTitleLabel.bottomAnchor, constant: 8),
            emptyDescriptionLabel.leadingAnchor.constraint(equalTo: emptyContainerView.leadingAnchor),
            emptyDescriptionLabel.trailingAnchor.constraint(equalTo: emptyContainerView.trailingAnchor),
            emptyDescriptionLabel.bottomAnchor.constraint(equalTo: emptyContainerView.bottomAnchor)
        ])
    }
    
    @objc private func filterChanged() {
        selectedFilter = RecordFilter(rawValue: filterSegmentedControl.selectedSegmentIndex) ?? .wish
        reloadData()
    }
    
    private func reloadData() {
        let count = filteredBooks.count
        
        countBadgeLabel.text = count == 0
        ? "\(selectedFilter.title) 기록이 아직 없어요."
        : "\(selectedFilter.title) 기록 \(count)권이 모였어요."
        
        emptyTitleLabel.text = selectedFilter.emptyTitle
        emptyDescriptionLabel.text = selectedFilter.emptyDescription
        
        tableView.reloadData()
        emptyContainerView.isHidden = !filteredBooks.isEmpty
        tableView.isHidden = filteredBooks.isEmpty
    }
}

extension RecordViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredBooks.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: RecordBookCell.identifier,
            for: indexPath
        ) as! RecordBookCell
        
        cell.configure(with: filteredBooks[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let book = filteredBooks[indexPath.row]
        let detailVC = BookDetailViewController(book: book)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

private final class RecordBookCell: UITableViewCell {
    static let identifier = "RecordBookCell"
    
    private let cardView = UIView()
    private let thumbnailImageView = UIImageView()
    
    private let textStackView = UIStackView()
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let ratingLabel = UILabel()
    
    private let detailButtonContainerView = UIView()
    private let detailButtonImageView = UIImageView()
    
    private let navyColor = UIColor(red: 0.02, green: 0.10, blue: 0.28, alpha: 1.0)
    private let mutedTextColor = UIColor(red: 0.55, green: 0.56, blue: 0.62, alpha: 1.0)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
        titleLabel.text = nil
        authorLabel.text = nil
        ratingLabel.text = nil
    }
    
    func configure(with book: Book) {
        thumbnailImageView.setImage(from: book.thumbnail)
        titleLabel.text = book.title
        authorLabel.text = book.authorText
        ratingLabel.text = makeRatingText(book.displayRating)
    }
    
    private func configureUI() {
        selectionStyle = .none
        backgroundColor = .white
        contentView.backgroundColor = .white
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = UIColor(red: 0.97, green: 0.98, blue: 1.0, alpha: 1.0)
        cardView.layer.cornerRadius = 20
        cardView.clipsToBounds = true
        
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView.backgroundColor = .secondarySystemBackground
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.layer.cornerRadius = 8
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .boldSystemFont(ofSize: 17)
        titleLabel.textColor = navyColor
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.font = .systemFont(ofSize: 13, weight: .medium)
        authorLabel.textColor = mutedTextColor
        authorLabel.numberOfLines = 1
        authorLabel.lineBreakMode = .byTruncatingTail
        authorLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        ratingLabel.textColor = .systemOrange
        ratingLabel.numberOfLines = 1
        ratingLabel.lineBreakMode = .byTruncatingTail
        ratingLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        textStackView.axis = .vertical
        textStackView.alignment = .leading
        textStackView.distribution = .fill
        textStackView.spacing = 8
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(authorLabel)
        textStackView.addArrangedSubview(ratingLabel)
        
        detailButtonContainerView.translatesAutoresizingMaskIntoConstraints = false
        detailButtonContainerView.backgroundColor = navyColor.withAlphaComponent(0.08)
        detailButtonContainerView.layer.cornerRadius = 19
        detailButtonContainerView.clipsToBounds = true
        
        detailButtonImageView.translatesAutoresizingMaskIntoConstraints = false
        detailButtonImageView.image = UIImage(systemName: "square.and.pencil")
        detailButtonImageView.tintColor = navyColor
        detailButtonImageView.contentMode = .scaleAspectFit
        
        contentView.addSubview(cardView)
        cardView.addSubview(thumbnailImageView)
        cardView.addSubview(textStackView)
        cardView.addSubview(detailButtonContainerView)
        detailButtonContainerView.addSubview(detailButtonImageView)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            thumbnailImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            thumbnailImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 72),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 104),
            
            detailButtonContainerView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            detailButtonContainerView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            detailButtonContainerView.widthAnchor.constraint(equalToConstant: 38),
            detailButtonContainerView.heightAnchor.constraint(equalToConstant: 38),
            
            detailButtonImageView.centerXAnchor.constraint(equalTo: detailButtonContainerView.centerXAnchor),
            detailButtonImageView.centerYAnchor.constraint(equalTo: detailButtonContainerView.centerYAnchor),
            detailButtonImageView.widthAnchor.constraint(equalToConstant: 17),
            detailButtonImageView.heightAnchor.constraint(equalToConstant: 17),
            
            textStackView.leadingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: 16),
            textStackView.trailingAnchor.constraint(equalTo: detailButtonContainerView.leadingAnchor, constant: -14),
            textStackView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            textStackView.topAnchor.constraint(greaterThanOrEqualTo: cardView.topAnchor, constant: 16),
            textStackView.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -16)
        ])
    }
    
    private func makeRatingText(_ rating: Double) -> String {
        if rating <= 0 {
            return "별점 없음"
        }
        
        if rating.truncatingRemainder(dividingBy: 1) == 0 {
            return "★ \(Int(rating))"
        }
        
        return "★ \(String(format: "%.1f", rating))"
    }
}
