import UIKit

final class HomeViewController: UIViewController {
    private let store = BookStore.shared
    
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    
    private var todayCollectionView: UICollectionView!
    private var readingCollectionView: UICollectionView!
    
    private let libraryShortcutView = UIView()
    private let readingSectionTitleLabel = UILabel()
    private let readingSectionSubtitleLabel = UILabel()
    
    private let chartContainerView = UIView()
    
    private var todayBooks: [KakaoBookDocument] = []
    
    private var readingBooks: [Book] {
        store.readingBooks
    }
    
    private let navyColor = UIColor(red: 0.02, green: 0.12, blue: 0.36, alpha: 1.0)
    
    private let dailyKeywords = [
        "인문학",
        "경제",
        "자기계발",
        "소설",
        "과학",
        "역사",
        "철학",
        "에세이",
        "심리",
        "기술"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Bookly"
        view.backgroundColor = .systemGroupedBackground
        configureUI()
        configureNotification()
        loadTodayBooks()
        reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
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
        configureScrollView()
        configureTodayBooksSection()
        configureLibraryShortcut()
        configureReadingSection()
        configureChartSection()
    }
    
    private func configureScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.spacing = 14
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 10),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32)
        ])
    }
    
    private func configureTodayBooksSection() {
        let titleLabel = makeSectionTitleLabel("오늘의 도서")
        let subtitleLabel = makeSectionSubtitleLabel("매일 새로운 주제의 책을 추천해드려요.")
        
        let titleStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        titleStack.axis = .vertical
        titleStack.spacing = 1
        
        contentStackView.addArrangedSubview(titleStack)
        contentStackView.setCustomSpacing(6, after: titleStack)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 130, height: 190)
        layout.minimumLineSpacing = 12
        
        todayCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        todayCollectionView.heightAnchor.constraint(equalToConstant: 198).isActive = true
        todayCollectionView.backgroundColor = .clear
        todayCollectionView.showsHorizontalScrollIndicator = false
        todayCollectionView.dataSource = self
        todayCollectionView.delegate = self
        todayCollectionView.register(BookCollectionViewCell.self, forCellWithReuseIdentifier: BookCollectionViewCell.identifier)
        
        contentStackView.addArrangedSubview(todayCollectionView)
    }
    
    private func configureLibraryShortcut() {
        libraryShortcutView.backgroundColor = .systemBackground
        libraryShortcutView.layer.cornerRadius = 18
        libraryShortcutView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconContainer = UIView()
        iconContainer.backgroundColor = navyColor.withAlphaComponent(0.1)
        iconContainer.layer.cornerRadius = 22
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let iconImageView = UIImageView(image: UIImage(systemName: "books.vertical.fill"))
        iconImageView.tintColor = navyColor
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        iconContainer.addSubview(iconImageView)
        
        let titleLabel = UILabel()
        titleLabel.text = "내 서재 보기"
        titleLabel.font = .boldSystemFont(ofSize: 18)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "찜한 책, 읽는 중인 책, 완독한 책을 확인하세요."
        subtitleLabel.font = .systemFont(ofSize: 13)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
        
        let arrowImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrowImageView.tintColor = .tertiaryLabel
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false
        
        libraryShortcutView.addSubview(iconContainer)
        libraryShortcutView.addSubview(textStack)
        libraryShortcutView.addSubview(arrowImageView)
        
        NSLayoutConstraint.activate([
            libraryShortcutView.heightAnchor.constraint(equalToConstant: 92),
            
            iconContainer.leadingAnchor.constraint(equalTo: libraryShortcutView.leadingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: libraryShortcutView.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 44),
            iconContainer.heightAnchor.constraint(equalToConstant: 44),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            textStack.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 14),
            textStack.centerYAnchor.constraint(equalTo: libraryShortcutView.centerYAnchor),
            textStack.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -12),
            
            arrowImageView.trailingAnchor.constraint(equalTo: libraryShortcutView.trailingAnchor, constant: -16),
            arrowImageView.centerYAnchor.constraint(equalTo: libraryShortcutView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 12)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(libraryShortcutTapped))
        libraryShortcutView.addGestureRecognizer(tapGesture)
        libraryShortcutView.isUserInteractionEnabled = true
        
        contentStackView.addArrangedSubview(libraryShortcutView)
    }
    
    private func configureReadingSection() {
        readingSectionTitleLabel.text = "읽고 있는 책"
        readingSectionTitleLabel.font = .boldSystemFont(ofSize: 20)
        
        readingSectionSubtitleLabel.text = "진행률과 읽기 시작일을 확인하세요."
        readingSectionSubtitleLabel.font = .systemFont(ofSize: 13)
        readingSectionSubtitleLabel.textColor = .secondaryLabel
        
        let titleStack = UIStackView(arrangedSubviews: [readingSectionTitleLabel, readingSectionSubtitleLabel])
        titleStack.axis = .vertical
        titleStack.spacing = 1
        titleStack.tag = 901
        
        contentStackView.addArrangedSubview(titleStack)
        contentStackView.setCustomSpacing(6, after: titleStack)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 140, height: 218)
        layout.minimumLineSpacing = 12
        
        readingCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        readingCollectionView.heightAnchor.constraint(equalToConstant: 224).isActive = true
        readingCollectionView.backgroundColor = .clear
        readingCollectionView.showsHorizontalScrollIndicator = false
        readingCollectionView.dataSource = self
        readingCollectionView.delegate = self
        readingCollectionView.register(BookCollectionViewCell.self, forCellWithReuseIdentifier: BookCollectionViewCell.identifier)
        
        contentStackView.addArrangedSubview(readingCollectionView)
    }
    
    private func configureChartSection() {
        chartContainerView.backgroundColor = .systemBackground
        chartContainerView.layer.cornerRadius = 18
        chartContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        contentStackView.addArrangedSubview(chartContainerView)
    }
    
    private func reloadData() {
        todayCollectionView?.reloadData()
        readingCollectionView?.reloadData()
        updateReadingSectionVisibility()
        updateChart()
    }
    
    private func updateReadingSectionVisibility() {
        let shouldShow = !readingBooks.isEmpty
        
        for view in contentStackView.arrangedSubviews {
            if view.tag == 901 {
                view.isHidden = !shouldShow
            }
        }
        
        readingCollectionView?.isHidden = !shouldShow
    }
    
    private func updateChart() {
        chartContainerView.subviews.forEach { $0.removeFromSuperview() }
        
        let wishCount = store.count(for: .wish)
        let readingCount = store.count(for: .reading)
        let doneCount = store.count(for: .done)
        let totalCount = wishCount + readingCount + doneCount
        
        let averageProgress = calculateAverageReadingProgress()
        let completionRate = calculateCompletionRate(
            doneCount: doneCount,
            totalCount: totalCount
        )
        
        let titleLabel = makeSectionTitleLabel("독서 추이 분석")
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "현재 서재 상태를 간단하게 정리했어요."
        subtitleLabel.font = .systemFont(ofSize: 13)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
        
        let statusSummaryStack = UIStackView(arrangedSubviews: [
            makeCompactStatusCard(title: "찜", count: wishCount, iconName: "bookmark.fill"),
            makeCompactStatusCard(title: "읽는 중", count: readingCount, iconName: "book.fill"),
            makeCompactStatusCard(title: "완독", count: doneCount, iconName: "checkmark.seal.fill")
        ])
        statusSummaryStack.axis = .horizontal
        statusSummaryStack.spacing = 8
        statusSummaryStack.distribution = .fillEqually
        
        let compositionTitleLabel = makeSmallTitleLabel("서재 구성")
        
        let compositionStack = UIStackView(arrangedSubviews: [
            makeCompositionRow(
                title: "찜한 책",
                count: wishCount,
                total: totalCount,
                iconName: "bookmark.fill",
                alpha: 0.35
            ),
            makeCompositionRow(
                title: "읽는 중",
                count: readingCount,
                total: totalCount,
                iconName: "book.fill",
                alpha: 0.65
            ),
            makeCompositionRow(
                title: "완독",
                count: doneCount,
                total: totalCount,
                iconName: "checkmark.seal.fill",
                alpha: 1.0
            )
        ])
        compositionStack.axis = .vertical
        compositionStack.spacing = 10
        
        let progressTitleLabel = makeSmallTitleLabel("독서 진행")
        
        let progressStack = UIStackView(arrangedSubviews: [
            makeProgressRow(
                title: "평균 진행률",
                value: averageProgress,
                iconName: "chart.line.uptrend.xyaxis"
            ),
            makeProgressRow(
                title: "완독률",
                value: completionRate,
                iconName: "checkmark.circle.fill"
            )
        ])
        progressStack.axis = .vertical
        progressStack.spacing = 10
        
        let commentTitleLabel = makeSmallTitleLabel("Bookly 코멘트")
        let commentView = makeCommentView(
            analysisComment(
                wishCount: wishCount,
                readingCount: readingCount,
                doneCount: doneCount,
                averageProgress: averageProgress
            )
        )
        
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel,
            statusSummaryStack,
            compositionTitleLabel,
            compositionStack,
            progressTitleLabel,
            progressStack,
            commentTitleLabel,
            commentView
        ])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        chartContainerView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: chartContainerView.topAnchor, constant: 18),
            stack.leadingAnchor.constraint(equalTo: chartContainerView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: chartContainerView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: chartContainerView.bottomAnchor, constant: -18)
        ])
    }
    
    private func makeCompactStatusCard(title: String, count: Int, iconName: String) -> UIView {
        let container = UIView()
        container.backgroundColor = navyColor.withAlphaComponent(0.06)
        container.layer.cornerRadius = 12
        
        let iconImageView = UIImageView(image: UIImage(systemName: iconName))
        iconImageView.tintColor = navyColor
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let countLabel = UILabel()
        countLabel.text = "\(count)"
        countLabel.font = .boldSystemFont(ofSize: 18)
        countLabel.textColor = navyColor
        countLabel.textAlignment = .center
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 10, weight: .semibold)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        
        let stack = UIStackView(arrangedSubviews: [
            iconImageView,
            countLabel,
            titleLabel
        ])
        stack.axis = .vertical
        stack.spacing = 3
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(stack)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 78),
            
            iconImageView.widthAnchor.constraint(equalToConstant: 16),
            iconImageView.heightAnchor.constraint(equalToConstant: 16),
            
            stack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
    
    private func makeCompositionRow(
        title: String,
        count: Int,
        total: Int,
        iconName: String,
        alpha: CGFloat
    ) -> UIView {
        let container = UIView()
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 12
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let iconBackgroundView = UIView()
        iconBackgroundView.backgroundColor = navyColor.withAlphaComponent(0.08)
        iconBackgroundView.layer.cornerRadius = 14
        iconBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconImageView = UIImageView(image: UIImage(systemName: iconName))
        iconImageView.tintColor = navyColor.withAlphaComponent(alpha)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        iconBackgroundView.addSubview(iconImageView)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .label
        
        let percent = total == 0 ? 0 : Int((Double(count) / Double(total)) * 100.0)
        
        let countLabel = UILabel()
        countLabel.text = "\(count)권 · \(percent)%"
        countLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        countLabel.textColor = navyColor
        countLabel.textAlignment = .right
        
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progress = total == 0 ? 0 : Float(Double(count) / Double(total))
        progressView.progressTintColor = navyColor.withAlphaComponent(alpha)
        progressView.trackTintColor = .systemGray5
        
        let topStack = UIStackView(arrangedSubviews: [titleLabel, countLabel])
        topStack.axis = .horizontal
        topStack.distribution = .fillEqually
        
        let textStack = UIStackView(arrangedSubviews: [topStack, progressView])
        textStack.axis = .vertical
        textStack.spacing = 8
        textStack.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(iconBackgroundView)
        container.addSubview(textStack)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 58),
            
            iconBackgroundView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            iconBackgroundView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconBackgroundView.widthAnchor.constraint(equalToConstant: 28),
            iconBackgroundView.heightAnchor.constraint(equalToConstant: 28),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconBackgroundView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconBackgroundView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 15),
            iconImageView.heightAnchor.constraint(equalToConstant: 15),
            
            textStack.leadingAnchor.constraint(equalTo: iconBackgroundView.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            textStack.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
    
    private func makeProgressRow(
        title: String,
        value: Int,
        iconName: String
    ) -> UIView {
        let container = UIView()
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 12
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let iconBackgroundView = UIView()
        iconBackgroundView.backgroundColor = navyColor.withAlphaComponent(0.08)
        iconBackgroundView.layer.cornerRadius = 14
        iconBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconImageView = UIImageView(image: UIImage(systemName: iconName))
        iconImageView.tintColor = navyColor
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        iconBackgroundView.addSubview(iconImageView)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .label
        
        let valueLabel = UILabel()
        valueLabel.text = "\(value)%"
        valueLabel.font = .boldSystemFont(ofSize: 16)
        valueLabel.textColor = navyColor
        valueLabel.textAlignment = .right
        
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progress = Float(value) / 100.0
        progressView.progressTintColor = navyColor
        progressView.trackTintColor = .systemGray5
        
        let topStack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        topStack.axis = .horizontal
        topStack.distribution = .fillEqually
        
        let textStack = UIStackView(arrangedSubviews: [topStack, progressView])
        textStack.axis = .vertical
        textStack.spacing = 8
        textStack.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(iconBackgroundView)
        container.addSubview(textStack)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 58),
            
            iconBackgroundView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            iconBackgroundView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconBackgroundView.widthAnchor.constraint(equalToConstant: 28),
            iconBackgroundView.heightAnchor.constraint(equalToConstant: 28),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconBackgroundView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconBackgroundView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 15),
            iconImageView.heightAnchor.constraint(equalToConstant: 15),
            
            textStack.leadingAnchor.constraint(equalTo: iconBackgroundView.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            textStack.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
    
    private func makeSmallTitleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .boldSystemFont(ofSize: 16)
        return label
    }
    
    private func makeCommentView(_ text: String) -> UIView {
        let container = UIView()
        container.backgroundColor = navyColor.withAlphaComponent(0.06)
        container.layer.cornerRadius = 12
        
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 54),
            
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])
        
        return container
    }
    
    private func calculateAverageReadingProgress() -> Int {
        let readingBooks = store.readingBooks
        
        guard !readingBooks.isEmpty else {
            return 0
        }
        
        let totalProgress = readingBooks.reduce(0.0) { result, book in
            result + book.progressValue
        }
        
        return Int(totalProgress / Double(readingBooks.count))
    }
    
    private func calculateCompletionRate(doneCount: Int, totalCount: Int) -> Int {
        guard totalCount > 0 else {
            return 0
        }
        
        return Int((Double(doneCount) / Double(totalCount)) * 100.0)
    }
    
    private func analysisComment(
        wishCount: Int,
        readingCount: Int,
        doneCount: Int,
        averageProgress: Int
    ) -> String {
        let total = wishCount + readingCount + doneCount
        
        if total == 0 {
            return "아직 독서 기록이 없습니다. 관심 있는 책을 검색해서 서재에 담아보세요."
        }
        
        if readingCount == 0 && wishCount > 0 {
            return "읽고 싶은 책이 쌓여 있어요. 위시리스트에서 한 권을 골라 읽기 시작해보세요."
        }
        
        if readingCount >= 3 {
            return "읽는 중인 책이 여러 권 있어요. 진행률이 높은 책부터 완독하면 관리가 쉬워집니다."
        }
        
        if doneCount > wishCount && doneCount > readingCount {
            return "완독 기록이 잘 쌓이고 있어요. 지금처럼 꾸준히 독서 흐름을 유지해보세요."
        }
        
        if averageProgress >= 70 {
            return "읽고 있는 책의 평균 진행률이 높아요. 곧 완독 기록으로 이어질 수 있습니다."
        }
        
        if averageProgress > 0 {
            return "현재 읽는 책의 흐름이 시작됐어요. 진행률을 꾸준히 기록해보세요."
        }
        
        return "서재 구성이 시작됐어요. 책을 읽기 시작하면 진행률과 완독률이 함께 분석됩니다."
    }
    
    private func loadTodayBooks() {
        let keyword = todayKeyword()
        
        Task {
            do {
                let response = try await KakaoBookService.shared.searchBooks(
                    keyword: keyword,
                    page: 1,
                    size: 10,
                    target: nil,
                    sort: "accuracy"
                )
                
                await MainActor.run {
                    self.todayBooks = Array(response.documents.prefix(8))
                    self.todayCollectionView.reloadData()
                }
            } catch {
                print("Today books load error:", error.localizedDescription)
            }
        }
    }
    
    private func todayKeyword() -> String {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return dailyKeywords[day % dailyKeywords.count]
    }
    
    @objc private func libraryShortcutTapped() {
        tabBarController?.selectedIndex = 2
    }
    
    private func makeSectionTitleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }
    
    private func makeSectionSubtitleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }
    
    private func pushDetail(book: Book) {
        let detailVC = BookDetailViewController(book: book)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    private func pushSearchDetail(document: KakaoBookDocument) {
        let detailVC = SearchBookDetailViewController(document: document)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == todayCollectionView {
            return todayBooks.count
        } else {
            return readingBooks.count
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BookCollectionViewCell.identifier,
            for: indexPath
        ) as! BookCollectionViewCell
        
        if collectionView == todayCollectionView {
            cell.configureToday(with: todayBooks[indexPath.item])
        } else {
            cell.configureReading(with: readingBooks[indexPath.item])
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == todayCollectionView {
            pushSearchDetail(document: todayBooks[indexPath.item])
        } else {
            pushDetail(book: readingBooks[indexPath.item])
        }
    }
}
