import UIKit

fileprivate enum LibraryShelfFilter: CaseIterable {
    case recommendation
    case done
    case wish
    case reading
    
    var title: String {
        switch self {
        case .recommendation:
            return "추천 책장"
        case .done:
            return "완독한 책장"
        case .wish:
            return "위시 책장"
        case .reading:
            return "읽는 중인 책장"
        }
    }
    
    var iconName: String {
        switch self {
        case .recommendation:
            return "books.vertical.fill"
        case .done:
            return "checkmark.circle.fill"
        case .wish:
            return "bookmark.fill"
        case .reading:
            return "book.fill"
        }
    }
    
    var emptyTitle: String {
        switch self {
        case .recommendation:
            return "추천 도서를 준비하고 있어요"
        case .done:
            return "완독한 책을 기다리고 있어요"
        case .wish:
            return "읽고 싶은 책을 기다리고 있어요"
        case .reading:
            return "책 추가를 기다리는 중"
        }
    }
    
    var emptyDescription: String {
        switch self {
        case .recommendation:
            return "잠시 후 추천 도서를 선반에 진열해둘게요."
        case .done:
            return "마지막 장까지 읽은 책은 이 선반에 꽂혀요."
        case .wish:
            return "찜한 책은 이 선반에 따로 꽂아둘게요."
        case .reading:
            return "읽기 시작한 책은 이 선반에서 이어볼 수 있어요."
        }
    }
}

final class LibraryViewController: UIViewController {
    private let store = BookStore.shared
    
    private let headerView = UIView()
    private let booklyLogoLabel = UILabel()
    private let booklySubtitleLabel = UILabel()
    private let headerTitleButton = UIButton(type: .system)
    
    private let headerCommentContainerView = UIView()
    private let headerCommentLabel = UILabel()
    
    private let headerDecorationShelfView = HeaderDecorationShelfView()
    
    private let contentPanelView = UIView()
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    
    private var selectedShelfFilter: LibraryShelfFilter?
    
    private var recommendedDocuments: [KakaoBookDocument] = []
    private var isLoadingRecommendations = false
    
    private let navyColor = UIColor(red: 0.02, green: 0.10, blue: 0.28, alpha: 1.0)
    private let backgroundColor = UIColor.systemBackground
    
    private let dailyKeywords = [
        "한국문학 소설",
        "세계문학 소설",
        "문학상 수상작",
        "에세이 베스트셀러",
        "힐링 에세이",
        "고전문학 소설",
        "감성 에세이",
        "산문집",
        "소설 베스트셀러",
        "한국 에세이",
        "오늘의 젊은 작가",
        "민음사 세계문학",
        "문학동네 소설",
        "창비 소설"
    ]
    
    private var doneBooks: [Book] {
        store.doneBooks
    }
    
    private var wishBooks: [Book] {
        store.wishBooks
    }
    
    private var readingBooks: [Book] {
        store.readingBooks
    }
    
    private var defaultShelfFilter: LibraryShelfFilter {
        doneBooks.isEmpty ? .recommendation : .done
    }
    
    private var currentShelfFilter: LibraryShelfFilter {
        selectedShelfFilter ?? defaultShelfFilter
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
        
        navigationController?.tabBarItem.title = "나의 서재"
        navigationController?.tabBarItem.image = UIImage(systemName: "books.vertical")
        navigationController?.tabBarItem.selectedImage = UIImage(systemName: "books.vertical.fill")
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
        configureScrollView()
    }
    
    private func configureHeaderView() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = navyColor
        
        booklyLogoLabel.translatesAutoresizingMaskIntoConstraints = false
        booklyLogoLabel.text = "Bookly"
        booklyLogoLabel.textColor = .white
        booklyLogoLabel.textAlignment = .left
        booklyLogoLabel.font = UIFont(name: "Georgia-BoldItalic", size: 36) ?? .italicSystemFont(ofSize: 36)
        booklyLogoLabel.numberOfLines = 1
        
        booklySubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        booklySubtitleLabel.text = "기록할수록 나의 독서가 완성된다 ✦"
        booklySubtitleLabel.font = .systemFont(ofSize: 11, weight: .medium)
        booklySubtitleLabel.textColor = UIColor.white.withAlphaComponent(0.78)
        booklySubtitleLabel.textAlignment = .left
        booklySubtitleLabel.numberOfLines = 1
        
        configureHeaderTitleButton()
        
        let titleStackView = UIStackView(arrangedSubviews: [
            headerTitleButton
        ])
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        titleStackView.axis = .horizontal
        titleStackView.alignment = .center
        titleStackView.spacing = 0
        
        headerCommentContainerView.translatesAutoresizingMaskIntoConstraints = false
        headerCommentContainerView.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        headerCommentContainerView.layer.cornerRadius = 16
        headerCommentContainerView.clipsToBounds = true
        
        headerCommentLabel.translatesAutoresizingMaskIntoConstraints = false
        headerCommentLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        headerCommentLabel.textColor = UIColor.white.withAlphaComponent(0.92)
        headerCommentLabel.textAlignment = .left
        headerCommentLabel.numberOfLines = 1
        headerCommentLabel.lineBreakMode = .byTruncatingTail
        
        headerCommentContainerView.addSubview(headerCommentLabel)
        
        let textStackView = UIStackView(arrangedSubviews: [
            booklyLogoLabel,
            booklySubtitleLabel,
            titleStackView,
            headerCommentContainerView
        ])
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        textStackView.axis = .vertical
        textStackView.alignment = .leading
        textStackView.spacing = 5
        textStackView.setCustomSpacing(18, after: booklySubtitleLabel)
        textStackView.setCustomSpacing(10, after: titleStackView)
        
        headerDecorationShelfView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(headerView)
        headerView.addSubview(textStackView)
        headerView.addSubview(headerDecorationShelfView)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 335),
            
            textStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            textStackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 22),
            textStackView.trailingAnchor.constraint(lessThanOrEqualTo: headerView.trailingAnchor, constant: -24),
            
            booklyLogoLabel.heightAnchor.constraint(equalToConstant: 42),
            booklySubtitleLabel.heightAnchor.constraint(equalToConstant: 16),
            
            headerTitleButton.heightAnchor.constraint(equalToConstant: 36),
            
            headerCommentContainerView.heightAnchor.constraint(equalToConstant: 34),
            headerCommentContainerView.leadingAnchor.constraint(equalTo: textStackView.leadingAnchor),
            headerCommentContainerView.trailingAnchor.constraint(lessThanOrEqualTo: headerView.trailingAnchor, constant: -24),
            
            headerCommentLabel.leadingAnchor.constraint(equalTo: headerCommentContainerView.leadingAnchor, constant: 18),
            headerCommentLabel.trailingAnchor.constraint(equalTo: headerCommentContainerView.trailingAnchor, constant: -18),
            headerCommentLabel.centerYAnchor.constraint(equalTo: headerCommentContainerView.centerYAnchor),
            
            headerDecorationShelfView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 44),
            headerDecorationShelfView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -44),
            headerDecorationShelfView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -34),
            headerDecorationShelfView.heightAnchor.constraint(equalToConstant: 76)
        ])
    }
    
    private func configureHeaderTitleButton() {
        let chevronImage = UIImage(
            systemName: "chevron.down",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        )
        
        headerTitleButton.translatesAutoresizingMaskIntoConstraints = false
        headerTitleButton.setTitle(currentShelfFilter.title, for: .normal)
        headerTitleButton.setImage(chevronImage, for: .normal)
        headerTitleButton.tintColor = .white
        headerTitleButton.setTitleColor(.white, for: .normal)
        headerTitleButton.titleLabel?.font = .boldSystemFont(ofSize: 27)
        headerTitleButton.titleLabel?.lineBreakMode = .byClipping
        headerTitleButton.contentHorizontalAlignment = .left
        headerTitleButton.semanticContentAttribute = .forceRightToLeft
        headerTitleButton.imageEdgeInsets = UIEdgeInsets(top: 2, left: 8, bottom: -2, right: -8)
        headerTitleButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 2)
        headerTitleButton.showsMenuAsPrimaryAction = true
        headerTitleButton.menu = makeShelfFilterMenu()
    }
    
    private func makeShelfFilterMenu() -> UIMenu {
        let actions = LibraryShelfFilter.allCases.map { filter in
            UIAction(
                title: filter.title,
                image: UIImage(systemName: filter.iconName),
                state: currentShelfFilter == filter ? .on : .off
            ) { [weak self] _ in
                guard let self else {
                    return
                }
                
                self.selectedShelfFilter = filter
                self.reloadData()
            }
        }
        
        return UIMenu(title: "책장 선택", children: actions)
    }
    
    private func updateHeaderTitleButtonAppearance() {
        headerTitleButton.setTitle(currentShelfFilter.title, for: .normal)
        headerTitleButton.menu = makeShelfFilterMenu()
    }
    
    private func configureContentPanelView() {
        contentPanelView.translatesAutoresizingMaskIntoConstraints = false
        contentPanelView.backgroundColor = backgroundColor
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
    
    private func configureScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.alignment = .fill
        contentStackView.distribution = .fill
        contentStackView.spacing = 0
        
        contentPanelView.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: contentPanelView.topAnchor, constant: 36),
            scrollView.leadingAnchor.constraint(equalTo: contentPanelView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentPanelView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentPanelView.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -116),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }
    
    private func reloadData() {
        contentStackView.arrangedSubviews.forEach { view in
            contentStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        updateHeaderTitleButtonAppearance()
        
        switch currentShelfFilter {
        case .recommendation:
            configureHeaderForRecommendation()
            renderRecommendationShelf()
            loadRecommendationsIfNeeded()
            
        case .done:
            configureHeaderForDoneBooks()
            renderSavedShelf(books: doneBooks)
            
        case .wish:
            configureHeaderForWishBooks()
            renderSavedShelf(books: wishBooks)
            
        case .reading:
            configureHeaderForReadingBooks()
            renderSavedShelf(books: readingBooks)
        }
    }
    
    private func configureHeaderForRecommendation() {
        headerCommentLabel.text = "오늘의 추천 주제는 ‘\(dailyKeywordForToday())’예요."
    }
    
    private func configureHeaderForDoneBooks() {
        headerCommentLabel.text = "지금까지 \(doneBooks.count)권의 책이 이 책장에 꽂혔어요."
    }
    
    private func configureHeaderForWishBooks() {
        headerCommentLabel.text = "지금까지 \(wishBooks.count)권의 책이 위시 책장에 꽂혔어요."
    }
    
    private func configureHeaderForReadingBooks() {
        headerCommentLabel.text = "지금 \(readingBooks.count)권의 책을 읽고 있어요."
    }
    
    private func renderSavedShelf(books: [Book]) {
        guard !books.isEmpty else {
            let emptyShelfView = MinimalWallShelfView()
            emptyShelfView.configureEmptyState(
                filter: currentShelfFilter,
                tapHandler: { [weak self] in
                    self?.tabBarController?.selectedIndex = 1
                }
            )
            contentStackView.addArrangedSubview(emptyShelfView)
            return
        }
        
        let items = books.map { ShelfDisplayItem.saved($0) }
        
        let shelfView = MinimalWallShelfView()
        
        shelfView.configure(
            items: items,
            tapHandler: { [weak self] item in
                guard case let .saved(book) = item.kind else {
                    return
                }
                self?.pushRecordDetail(book: book)
            },
            longPressHandler: { [weak self] item in
                guard case let .saved(book) = item.kind else {
                    return
                }
                self?.showDeleteAlert(for: book)
            }
        )
        
        contentStackView.addArrangedSubview(shelfView)
    }
    
    private func renderRecommendationShelf() {
        if recommendedDocuments.isEmpty && isLoadingRecommendations {
            let emptyShelfView = MinimalWallShelfView()
            emptyShelfView.configureEmptyState(
                filter: .recommendation,
                tapHandler: nil
            )
            contentStackView.addArrangedSubview(emptyShelfView)
            return
        }
        
        if recommendedDocuments.isEmpty {
            let emptyShelfView = MinimalWallShelfView()
            emptyShelfView.configureEmptyState(
                filter: .recommendation,
                tapHandler: { [weak self] in
                    self?.tabBarController?.selectedIndex = 1
                }
            )
            contentStackView.addArrangedSubview(emptyShelfView)
            return
        }
        
        let items = recommendedDocuments.map { ShelfDisplayItem.recommendation($0) }
        
        let shelfView = MinimalWallShelfView()
        
        shelfView.configure(
            items: items,
            tapHandler: { [weak self] item in
                guard case let .recommendation(document) = item.kind else {
                    return
                }
                self?.pushSearchDetail(document: document)
            },
            longPressHandler: nil
        )
        
        contentStackView.addArrangedSubview(shelfView)
    }
    
    private func showDeleteAlert(for book: Book) {
        let alert = UIAlertController(
            title: "책을 삭제할까요?",
            message: "나의 서재에서 이 책이 삭제됩니다.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            BookStore.shared.deleteBook(book)
            self?.reloadData()
        })
        
        present(alert, animated: true)
    }
    
    private func loadRecommendationsIfNeeded() {
        guard currentShelfFilter == .recommendation else {
            return
        }
        
        guard !isLoadingRecommendations else {
            return
        }
        
        guard recommendedDocuments.isEmpty else {
            return
        }
        
        isLoadingRecommendations = true
        reloadData()
        
        Task {
            do {
                var finalDocuments: [KakaoBookDocument] = []
                var seenKeys = Set<String>()
                
                let rotatedKeywords = rotatedDailyKeywordsStartingFromToday()
                
                for keyword in rotatedKeywords {
                    let response = try await KakaoBookService.shared.searchBooks(
                        keyword: keyword,
                        page: 1,
                        size: 50,
                        target: nil,
                        sort: "accuracy"
                    )
                    
                    let metadataFilteredDocuments = response.documents.filter { document in
                        self.isValidRecommendation(document)
                    }
                    
                    for document in metadataFilteredDocuments {
                        let key = uniqueKey(for: document)
                        
                        guard !seenKeys.contains(key) else {
                            continue
                        }
                        
                        seenKeys.insert(key)
                        
                        let isValidThumbnail = await self.thumbnailLooksLikeCleanStandingBookCover(document.thumbnail)
                        
                        guard isValidThumbnail else {
                            continue
                        }
                        
                        finalDocuments.append(document)
                        
                        if finalDocuments.count >= 12 {
                            break
                        }
                    }
                    
                    if finalDocuments.count >= 12 {
                        break
                    }
                }
                
                await MainActor.run {
                    self.isLoadingRecommendations = false
                    self.recommendedDocuments = finalDocuments
                    self.reloadData()
                }
            } catch {
                await MainActor.run {
                    self.isLoadingRecommendations = false
                    print("Library recommendation load error:", error.localizedDescription)
                    self.reloadData()
                }
            }
        }
    }
    
    private func dailyKeywordForToday() -> String {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return dailyKeywords[day % dailyKeywords.count]
    }
    
    private func rotatedDailyKeywordsStartingFromToday() -> [String] {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let startIndex = day % dailyKeywords.count
        
        let firstPart = dailyKeywords[startIndex..<dailyKeywords.count]
        let secondPart = dailyKeywords[0..<startIndex]
        
        return Array(firstPart + secondPart)
    }
    
    private func uniqueKey(for document: KakaoBookDocument) -> String {
        let title = document.title.removingHTMLTags()
        let authors = document.authors.joined(separator: ",")
        let publisher = document.publisher
        
        return "\(title)-\(authors)-\(publisher)"
            .lowercased()
            .replacingOccurrences(of: " ", with: "")
    }
    
    private func isValidRecommendation(_ document: KakaoBookDocument) -> Bool {
        let title = document.title.removingHTMLTags()
        let authorText = document.authors.joined(separator: " ")
        let publisher = document.publisher
        let contents = document.contents.removingHTMLTags()
        
        let combinedText = "\(title) \(authorText) \(publisher) \(contents)"
        
        guard !document.thumbnail.isEmpty else {
            return false
        }
        
        guard !RecommendationFilter.containsBannedKeyword(in: combinedText) else {
            return false
        }
        
        let normalizedText = RecommendationFilter.normalized(combinedText)
        
        let extraBadThumbnailSignals = [
            "세트", "전집", "박스", "박스세트", "양장", "특별판", "한정판",
            "리커버", "리커버판", "개정판", "큰글자", "큰글씨", "합본",
            "전권", "패키지", "스페셜", "컬렉션", "미니북", "포켓북",
            "카드북", "워크북", "필사", "쓰기", "따라쓰기", "문고판",
            "문고본", "노트", "다이어리", "굿즈", "cd", "dvd",
            "오디오북", "전자책", "ebook"
        ]
        
        guard !extraBadThumbnailSignals.contains(where: {
            normalizedText.contains(RecommendationFilter.normalized($0))
        }) else {
            return false
        }
        
        return true
    }
    
    private func thumbnailLooksLikeCleanStandingBookCover(_ thumbnailURLString: String) async -> Bool {
        guard !thumbnailURLString.isEmpty else {
            return false
        }
        
        guard let url = URL(string: thumbnailURLString) else {
            return false
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            guard let image = UIImage(data: data) else {
                return false
            }
            
            return isCleanStandingBookCoverImage(image)
        } catch {
            return false
        }
    }
    
    private func isCleanStandingBookCoverImage(_ image: UIImage) -> Bool {
        guard let cgImage = image.cgImage else {
            return false
        }
        
        let width = cgImage.width
        let height = cgImage.height
        
        guard width >= 90, height >= 130 else {
            return false
        }
        
        let imageAspectRatio = CGFloat(height) / CGFloat(width)
        
        guard imageAspectRatio >= 1.38, imageAspectRatio <= 1.82 else {
            return false
        }
        
        let sampleWidth = 120
        let sampleHeight = max(1, Int(CGFloat(sampleWidth) * CGFloat(height) / CGFloat(width)))
        
        guard let sample = makeRGBASample(from: cgImage, width: sampleWidth, height: sampleHeight) else {
            return false
        }
        
        let borderWhiteRatio = whiteLikeBorderRatio(sample: sample)
        guard borderWhiteRatio < 0.72 else {
            return false
        }
        
        let centralContentRatio = nonWhiteRatioInCentralArea(sample: sample)
        guard centralContentRatio > 0.22 else {
            return false
        }
        
        let edgeContentRatio = nonWhiteRatioNearEdges(sample: sample)
        guard edgeContentRatio > 0.18 else {
            return false
        }
        
        let detectedCoverBox = foregroundBoundingBox(sample: sample)
        
        guard detectedCoverBox.widthRatio >= 0.78 else {
            return false
        }
        
        guard detectedCoverBox.heightRatio >= 0.86 else {
            return false
        }
        
        guard detectedCoverBox.areaRatio >= 0.46 else {
            return false
        }
        
        guard detectedCoverBox.aspectRatio >= 1.30, detectedCoverBox.aspectRatio <= 1.95 else {
            return false
        }
        
        return true
    }
    
    private struct ImageSample {
        let width: Int
        let height: Int
        let bytesPerRow: Int
        let bytesPerPixel: Int
        let data: [UInt8]
    }
    
    private struct CoverBoxMetrics {
        let widthRatio: CGFloat
        let heightRatio: CGFloat
        let areaRatio: CGFloat
        let aspectRatio: CGFloat
    }
    
    private func makeRGBASample(from cgImage: CGImage, width: Int, height: Int) -> ImageSample? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let bitsPerComponent = 8
        
        var pixelData = [UInt8](repeating: 0, count: height * bytesPerRow)
        
        guard let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return nil
        }
        
        context.interpolationQuality = .medium
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        return ImageSample(
            width: width,
            height: height,
            bytesPerRow: bytesPerRow,
            bytesPerPixel: bytesPerPixel,
            data: pixelData
        )
    }
    
    private func pixelAt(sample: ImageSample, x: Int, y: Int) -> (r: Int, g: Int, b: Int) {
        let safeX = max(0, min(sample.width - 1, x))
        let safeY = max(0, min(sample.height - 1, y))
        let index = safeY * sample.bytesPerRow + safeX * sample.bytesPerPixel
        
        return (
            Int(sample.data[index]),
            Int(sample.data[index + 1]),
            Int(sample.data[index + 2])
        )
    }
    
    private func isWhiteLike(_ pixel: (r: Int, g: Int, b: Int)) -> Bool {
        pixel.r > 232 && pixel.g > 232 && pixel.b > 232
    }
    
    private func isNearlyWhiteLike(_ pixel: (r: Int, g: Int, b: Int)) -> Bool {
        pixel.r > 218 && pixel.g > 218 && pixel.b > 218
    }
    
    private func whiteLikeBorderRatio(sample: ImageSample) -> CGFloat {
        var whiteCount = 0
        var totalCount = 0
        
        let borderThickness = max(3, sample.width / 12)
        
        for y in 0..<sample.height {
            for x in 0..<sample.width {
                let isBorder =
                    x < borderThickness ||
                    x >= sample.width - borderThickness ||
                    y < borderThickness ||
                    y >= sample.height - borderThickness
                
                guard isBorder else {
                    continue
                }
                
                let pixel = pixelAt(sample: sample, x: x, y: y)
                
                if isWhiteLike(pixel) {
                    whiteCount += 1
                }
                
                totalCount += 1
            }
        }
        
        guard totalCount > 0 else {
            return 1.0
        }
        
        return CGFloat(whiteCount) / CGFloat(totalCount)
    }
    
    private func nonWhiteRatioInCentralArea(sample: ImageSample) -> CGFloat {
        let startX = Int(CGFloat(sample.width) * 0.22)
        let endX = Int(CGFloat(sample.width) * 0.78)
        let startY = Int(CGFloat(sample.height) * 0.20)
        let endY = Int(CGFloat(sample.height) * 0.80)
        
        var nonWhiteCount = 0
        var totalCount = 0
        
        for y in startY..<endY {
            for x in startX..<endX {
                let pixel = pixelAt(sample: sample, x: x, y: y)
                
                if !isNearlyWhiteLike(pixel) {
                    nonWhiteCount += 1
                }
                
                totalCount += 1
            }
        }
        
        guard totalCount > 0 else {
            return 0
        }
        
        return CGFloat(nonWhiteCount) / CGFloat(totalCount)
    }
    
    private func nonWhiteRatioNearEdges(sample: ImageSample) -> CGFloat {
        var nonWhiteCount = 0
        var totalCount = 0
        
        let edgeThickness = max(4, sample.width / 10)
        
        for y in 0..<sample.height {
            for x in 0..<sample.width {
                let isNearEdge =
                    x < edgeThickness ||
                    x >= sample.width - edgeThickness ||
                    y < edgeThickness ||
                    y >= sample.height - edgeThickness
                
                guard isNearEdge else {
                    continue
                }
                
                let pixel = pixelAt(sample: sample, x: x, y: y)
                
                if !isNearlyWhiteLike(pixel) {
                    nonWhiteCount += 1
                }
                
                totalCount += 1
            }
        }
        
        guard totalCount > 0 else {
            return 0
        }
        
        return CGFloat(nonWhiteCount) / CGFloat(totalCount)
    }
    
    private func foregroundBoundingBox(sample: ImageSample) -> CoverBoxMetrics {
        let cornerPixels = [
            pixelAt(sample: sample, x: 0, y: 0),
            pixelAt(sample: sample, x: sample.width - 1, y: 0),
            pixelAt(sample: sample, x: 0, y: sample.height - 1),
            pixelAt(sample: sample, x: sample.width - 1, y: sample.height - 1)
        ]
        
        let backgroundR = cornerPixels.map { $0.r }.reduce(0, +) / cornerPixels.count
        let backgroundG = cornerPixels.map { $0.g }.reduce(0, +) / cornerPixels.count
        let backgroundB = cornerPixels.map { $0.b }.reduce(0, +) / cornerPixels.count
        
        func distanceFromBackground(_ pixel: (r: Int, g: Int, b: Int)) -> Int {
            abs(pixel.r - backgroundR) + abs(pixel.g - backgroundG) + abs(pixel.b - backgroundB)
        }
        
        var minX = sample.width
        var maxX = 0
        var minY = sample.height
        var maxY = 0
        var foregroundCount = 0
        
        for y in 0..<sample.height {
            for x in 0..<sample.width {
                let pixel = pixelAt(sample: sample, x: x, y: y)
                let distance = distanceFromBackground(pixel)
                
                if distance > 34 || !isNearlyWhiteLike(pixel) {
                    foregroundCount += 1
                    minX = min(minX, x)
                    maxX = max(maxX, x)
                    minY = min(minY, y)
                    maxY = max(maxY, y)
                }
            }
        }
        
        guard foregroundCount > 0 else {
            return CoverBoxMetrics(
                widthRatio: 0,
                heightRatio: 0,
                areaRatio: 0,
                aspectRatio: 0
            )
        }
        
        let foregroundWidth = maxX - minX + 1
        let foregroundHeight = maxY - minY + 1
        
        let widthRatio = CGFloat(foregroundWidth) / CGFloat(sample.width)
        let heightRatio = CGFloat(foregroundHeight) / CGFloat(sample.height)
        let areaRatio = CGFloat(foregroundCount) / CGFloat(sample.width * sample.height)
        let aspectRatio = CGFloat(foregroundHeight) / CGFloat(max(1, foregroundWidth))
        
        return CoverBoxMetrics(
            widthRatio: widthRatio,
            heightRatio: heightRatio,
            areaRatio: areaRatio,
            aspectRatio: aspectRatio
        )
    }
    
    private func pushRecordDetail(book: Book) {
        let detailVC = BookDetailViewController(book: book)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    private func pushSearchDetail(document: KakaoBookDocument) {
        let detailVC = SearchBookDetailViewController(document: document)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

private struct ShelfDisplayItem {
    enum Kind {
        case saved(Book)
        case recommendation(KakaoBookDocument)
    }
    
    let kind: Kind
    let thumbnail: String
    
    static func saved(_ book: Book) -> ShelfDisplayItem {
        ShelfDisplayItem(
            kind: .saved(book),
            thumbnail: book.thumbnail
        )
    }
    
    static func recommendation(_ document: KakaoBookDocument) -> ShelfDisplayItem {
        ShelfDisplayItem(
            kind: .recommendation(document),
            thumbnail: document.thumbnail
        )
    }
}

private final class MinimalWallShelfView: UIView {
    private let rowsStackView = UIStackView()
    private var tapHandler: ((ShelfDisplayItem) -> Void)?
    private var longPressHandler: ((ShelfDisplayItem) -> Void)?
    
    private let maxColumns = 4
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(
        items: [ShelfDisplayItem],
        tapHandler: @escaping (ShelfDisplayItem) -> Void,
        longPressHandler: ((ShelfDisplayItem) -> Void)?
    ) {
        self.tapHandler = tapHandler
        self.longPressHandler = longPressHandler
        clearRows()
        
        let rows = chunk(items, size: maxColumns)
        let rowCount = max(rows.count, 1)
        
        for rowIndex in 0..<rowCount {
            let rowItems = rowIndex < rows.count ? rows[rowIndex] : []
            
            let rowView = MinimalShelfRowView(
                items: rowItems,
                maxColumns: maxColumns
            )
            
            rowView.onTap = { [weak self] item in
                self?.tapHandler?(item)
            }
            
            rowView.onLongPress = { [weak self] item in
                self?.longPressHandler?(item)
            }
            
            rowsStackView.addArrangedSubview(rowView)
        }
    }
    
    func configureEmptyState(
        filter: LibraryShelfFilter,
        tapHandler: (() -> Void)?
    ) {
        clearRows()
        
        let rowView = MinimalShelfRowView(
            items: [],
            maxColumns: maxColumns
        )
        
        let emptyView = EmptyShelfHintView(
            iconName: filter.iconName,
            title: filter.emptyTitle,
            description: filter.emptyDescription,
            tapHandler: tapHandler
        )
        
        rowView.addEmptyHintView(emptyView)
        rowsStackView.addArrangedSubview(rowView)
    }
    
    func configureEmptyShelf() {
        clearRows()
        
        let rowView = MinimalShelfRowView(
            items: [],
            maxColumns: maxColumns
        )
        
        rowsStackView.addArrangedSubview(rowView)
    }
    
    private func configureUI() {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = true
        
        rowsStackView.translatesAutoresizingMaskIntoConstraints = false
        rowsStackView.axis = .vertical
        rowsStackView.spacing = 32
        rowsStackView.isUserInteractionEnabled = true
        
        addSubview(rowsStackView)
        
        NSLayoutConstraint.activate([
            rowsStackView.topAnchor.constraint(equalTo: topAnchor),
            rowsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            rowsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            rowsStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func clearRows() {
        rowsStackView.arrangedSubviews.forEach { view in
            rowsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
    
    private func chunk(_ items: [ShelfDisplayItem], size: Int) -> [[ShelfDisplayItem]] {
        guard size > 0 else {
            return [items]
        }
        
        var result: [[ShelfDisplayItem]] = []
        var index = 0
        
        while index < items.count {
            let endIndex = min(index + size, items.count)
            result.append(Array(items[index..<endIndex]))
            index += size
        }
        
        return result
    }
}

private final class MinimalShelfRowView: UIView {
    var onTap: ((ShelfDisplayItem) -> Void)?
    var onLongPress: ((ShelfDisplayItem) -> Void)?
    
    private let items: [ShelfDisplayItem]
    private let maxColumns: Int
    
    private let bookStackView = UIStackView()
    private let shelfDropShadowView = ShelfDropShadowView()
    private let shelfTopView = TexturedWoodShelfTopView()
    private let shelfSideView = TexturedWoodShelfSideView()
    
    private var bookTouchTargets: [(view: UIView, item: ShelfDisplayItem)] = []
    
    init(
        items: [ShelfDisplayItem],
        maxColumns: Int
    ) {
        self.items = items
        self.maxColumns = maxColumns
        super.init(frame: .zero)
        
        configureUI()
        configureBooks()
        configureGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addEmptyHintView(_ emptyView: UIView) {
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(emptyView)
        
        NSLayoutConstraint.activate([
            emptyView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 44),
            emptyView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -44),
            emptyView.bottomAnchor.constraint(equalTo: shelfTopView.topAnchor, constant: -6),
            emptyView.heightAnchor.constraint(equalToConstant: 68)
        ])
    }
    
    private func configureUI() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        isUserInteractionEnabled = true
        
        bookStackView.translatesAutoresizingMaskIntoConstraints = false
        bookStackView.axis = .horizontal
        bookStackView.distribution = .fillEqually
        bookStackView.alignment = .bottom
        bookStackView.spacing = 18
        bookStackView.isUserInteractionEnabled = false
        
        shelfDropShadowView.translatesAutoresizingMaskIntoConstraints = false
        shelfDropShadowView.isUserInteractionEnabled = false
        
        shelfTopView.translatesAutoresizingMaskIntoConstraints = false
        shelfSideView.translatesAutoresizingMaskIntoConstraints = false
        shelfTopView.isUserInteractionEnabled = false
        shelfSideView.isUserInteractionEnabled = false
        
        addSubview(bookStackView)
        addSubview(shelfDropShadowView)
        addSubview(shelfTopView)
        addSubview(shelfSideView)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 126),
            
            bookStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 26),
            bookStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -26),
            bookStackView.topAnchor.constraint(equalTo: topAnchor),
            bookStackView.bottomAnchor.constraint(equalTo: shelfTopView.topAnchor, constant: 9),
            
            shelfTopView.leadingAnchor.constraint(equalTo: leadingAnchor),
            shelfTopView.trailingAnchor.constraint(equalTo: trailingAnchor),
            shelfTopView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            shelfTopView.heightAnchor.constraint(equalToConstant: 14),
            
            shelfSideView.leadingAnchor.constraint(equalTo: leadingAnchor),
            shelfSideView.trailingAnchor.constraint(equalTo: trailingAnchor),
            shelfSideView.topAnchor.constraint(equalTo: shelfTopView.bottomAnchor, constant: -1),
            shelfSideView.heightAnchor.constraint(equalToConstant: 10),
            
            shelfDropShadowView.leadingAnchor.constraint(equalTo: leadingAnchor),
            shelfDropShadowView.trailingAnchor.constraint(equalTo: trailingAnchor),
            shelfDropShadowView.topAnchor.constraint(equalTo: shelfSideView.bottomAnchor, constant: -1),
            shelfDropShadowView.heightAnchor.constraint(equalToConstant: 14)
        ])
    }
    
    private func configureBooks() {
        bookTouchTargets.removeAll()
        
        for column in 0..<maxColumns {
            let item = column < items.count ? items[column] : nil
            
            let slotView = MinimalShelfBookSlotView(item: item)
            bookStackView.addArrangedSubview(slotView)
            
            if let item, let targetView = slotView.touchTargetView {
                bookTouchTargets.append((targetView, item))
            }
        }
    }
    
    private func configureGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleRowTap(_:)))
        tapGesture.cancelsTouchesInView = false
        addGestureRecognizer(tapGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleRowLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.45
        longPressGesture.cancelsTouchesInView = false
        addGestureRecognizer(longPressGesture)
    }
    
    @objc private func handleRowTap(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else {
            return
        }
        
        guard let item = itemAtGestureLocation(gesture) else {
            return
        }
        
        onTap?(item)
    }
    
    @objc private func handleRowLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else {
            return
        }
        
        guard let item = itemAtGestureLocation(gesture) else {
            return
        }
        
        onLongPress?(item)
    }
    
    private func itemAtGestureLocation(_ gesture: UIGestureRecognizer) -> ShelfDisplayItem? {
        layoutIfNeeded()
        bookStackView.layoutIfNeeded()
        
        let touchPoint = gesture.location(in: self)
        
        for target in bookTouchTargets.reversed() {
            let targetFrame = target.view.convert(target.view.bounds, to: self).insetBy(dx: -14, dy: -14)
            
            if targetFrame.contains(touchPoint) {
                return target.item
            }
        }
        
        return nil
    }
}

private final class EmptyShelfHintView: UIView {
    private let iconContainerView = UIView()
    private let iconImageView = UIImageView()
    private let plusBadgeView = UIView()
    private let plusImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let tapHandler: (() -> Void)?
    
    init(
        iconName: String,
        title: String,
        description: String,
        tapHandler: (() -> Void)?
    ) {
        self.tapHandler = tapHandler
        super.init(frame: .zero)
        
        configureUI(
            iconName: iconName,
            title: title,
            description: description
        )
    }
    
    required init?(coder: NSCoder) {
        self.tapHandler = nil
        super.init(coder: coder)
        
        configureUI(
            iconName: "book.fill",
            title: "책 추가를 기다리는 중",
            description: "검색에서 책을 추가하면 이 선반에 진열돼요."
        )
    }
    
    private func configureUI(
        iconName: String,
        title: String,
        description: String
    ) {
        backgroundColor = .clear
        isUserInteractionEnabled = true
        
        iconContainerView.translatesAutoresizingMaskIntoConstraints = false
        iconContainerView.backgroundColor = UIColor(red: 0.02, green: 0.10, blue: 0.28, alpha: 0.08)
        iconContainerView.layer.cornerRadius = 23
        iconContainerView.clipsToBounds = false
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.tintColor = UIColor(red: 0.02, green: 0.10, blue: 0.28, alpha: 0.78)
        iconImageView.contentMode = .scaleAspectFit
        
        plusBadgeView.translatesAutoresizingMaskIntoConstraints = false
        plusBadgeView.backgroundColor = UIColor(red: 0.33, green: 0.25, blue: 0.94, alpha: 1.0)
        plusBadgeView.layer.cornerRadius = 9
        plusBadgeView.clipsToBounds = true
        
        plusImageView.translatesAutoresizingMaskIntoConstraints = false
        plusImageView.image = UIImage(systemName: "plus")
        plusImageView.tintColor = .white
        plusImageView.contentMode = .scaleAspectFit
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15, weight: .bold)
        titleLabel.textColor = UIColor(red: 0.02, green: 0.10, blue: 0.28, alpha: 0.92)
        titleLabel.numberOfLines = 1
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = description
        descriptionLabel.font = .systemFont(ofSize: 12, weight: .medium)
        descriptionLabel.textColor = UIColor.secondaryLabel.withAlphaComponent(0.86)
        descriptionLabel.numberOfLines = 1
        
        let textStackView = UIStackView(arrangedSubviews: [
            titleLabel,
            descriptionLabel
        ])
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        textStackView.axis = .vertical
        textStackView.spacing = 4
        textStackView.alignment = .leading
        
        addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        iconContainerView.addSubview(plusBadgeView)
        plusBadgeView.addSubview(plusImageView)
        addSubview(textStackView)
        
        NSLayoutConstraint.activate([
            iconContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            iconContainerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconContainerView.widthAnchor.constraint(equalToConstant: 46),
            iconContainerView.heightAnchor.constraint(equalToConstant: 46),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            plusBadgeView.trailingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 3),
            plusBadgeView.bottomAnchor.constraint(equalTo: iconContainerView.bottomAnchor, constant: 3),
            plusBadgeView.widthAnchor.constraint(equalToConstant: 18),
            plusBadgeView.heightAnchor.constraint(equalToConstant: 18),
            
            plusImageView.centerXAnchor.constraint(equalTo: plusBadgeView.centerXAnchor),
            plusImageView.centerYAnchor.constraint(equalTo: plusBadgeView.centerYAnchor),
            plusImageView.widthAnchor.constraint(equalToConstant: 10),
            plusImageView.heightAnchor.constraint(equalToConstant: 10),
            
            textStackView.leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 14),
            textStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            textStackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        if tapHandler != nil {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            addGestureRecognizer(tapGesture)
        }
    }
    
    @objc private func handleTap() {
        tapHandler?()
    }
}

private final class MinimalShelfBookSlotView: UIView {
    private let item: ShelfDisplayItem?
    private(set) var touchTargetView: UIView?
    
    init(item: ShelfDisplayItem?) {
        self.item = item
        super.init(frame: .zero)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let touchTargetView else {
            return
        }
        
        touchTargetView.layer.shadowPath = UIBezierPath(
            roundedRect: touchTargetView.bounds,
            cornerRadius: 2
        ).cgPath
    }
    
    private func configureUI() {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
        
        guard let item else {
            return
        }
        
        let shadowContainerView = UIView()
        shadowContainerView.translatesAutoresizingMaskIntoConstraints = false
        shadowContainerView.backgroundColor = .clear
        shadowContainerView.isUserInteractionEnabled = false
        shadowContainerView.layer.shadowColor = UIColor.black.cgColor
        shadowContainerView.layer.shadowOpacity = 0.18
        shadowContainerView.layer.shadowRadius = 9
        shadowContainerView.layer.shadowOffset = CGSize(width: 0, height: 5)
        shadowContainerView.layer.masksToBounds = false
        
        let bookImageView = UIImageView()
        bookImageView.translatesAutoresizingMaskIntoConstraints = false
        bookImageView.contentMode = .scaleAspectFill
        bookImageView.backgroundColor = .clear
        bookImageView.clipsToBounds = true
        bookImageView.layer.cornerRadius = 1.5
        bookImageView.setImage(from: item.thumbnail)
        bookImageView.isUserInteractionEnabled = false
        
        shadowContainerView.addSubview(bookImageView)
        addSubview(shadowContainerView)
        
        self.touchTargetView = shadowContainerView
        
        NSLayoutConstraint.activate([
            shadowContainerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            shadowContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            shadowContainerView.widthAnchor.constraint(equalToConstant: 72),
            shadowContainerView.heightAnchor.constraint(equalToConstant: 108),
            
            bookImageView.topAnchor.constraint(equalTo: shadowContainerView.topAnchor),
            bookImageView.leadingAnchor.constraint(equalTo: shadowContainerView.leadingAnchor),
            bookImageView.trailingAnchor.constraint(equalTo: shadowContainerView.trailingAnchor),
            bookImageView.bottomAnchor.constraint(equalTo: shadowContainerView.bottomAnchor)
        ])
    }
}

private final class HeaderDecorationShelfView: UIView {
    private let lampView = MiniLampView()
    private let booksView = MiniBookStackView()
    private let plantView = MiniPlantView()
    private let shelfLineView = UIView()
    private let shelfShadowView = ShelfDropShadowView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }
    
    private func configureUI() {
        backgroundColor = .clear
        isUserInteractionEnabled = false
        
        lampView.translatesAutoresizingMaskIntoConstraints = false
        booksView.translatesAutoresizingMaskIntoConstraints = false
        plantView.translatesAutoresizingMaskIntoConstraints = false
        shelfLineView.translatesAutoresizingMaskIntoConstraints = false
        shelfShadowView.translatesAutoresizingMaskIntoConstraints = false
        
        shelfLineView.backgroundColor = UIColor(red: 0.78, green: 0.60, blue: 0.42, alpha: 1.0)
        shelfLineView.layer.cornerRadius = 2
        shelfLineView.clipsToBounds = true
        
        addSubview(lampView)
        addSubview(booksView)
        addSubview(plantView)
        addSubview(shelfShadowView)
        addSubview(shelfLineView)
        
        NSLayoutConstraint.activate([
            shelfLineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            shelfLineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            shelfLineView.bottomAnchor.constraint(equalTo: bottomAnchor),
            shelfLineView.heightAnchor.constraint(equalToConstant: 6),
            
            shelfShadowView.leadingAnchor.constraint(equalTo: shelfLineView.leadingAnchor),
            shelfShadowView.trailingAnchor.constraint(equalTo: shelfLineView.trailingAnchor),
            shelfShadowView.topAnchor.constraint(equalTo: shelfLineView.bottomAnchor, constant: -1),
            shelfShadowView.heightAnchor.constraint(equalToConstant: 12),
            
            lampView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            lampView.bottomAnchor.constraint(equalTo: shelfLineView.topAnchor, constant: 3),
            lampView.widthAnchor.constraint(equalToConstant: 46),
            lampView.heightAnchor.constraint(equalToConstant: 58),
            
            booksView.leadingAnchor.constraint(equalTo: lampView.trailingAnchor, constant: 10),
            booksView.bottomAnchor.constraint(equalTo: shelfLineView.topAnchor, constant: 3),
            booksView.widthAnchor.constraint(equalToConstant: 62),
            booksView.heightAnchor.constraint(equalToConstant: 32),
            
            plantView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            plantView.bottomAnchor.constraint(equalTo: shelfLineView.topAnchor, constant: 3),
            plantView.widthAnchor.constraint(equalToConstant: 50),
            plantView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

private final class MiniLampView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        context.saveGState()
        
        let scaleX = rect.width / 34
        let scaleY = rect.height / 44
        context.scaleBy(x: scaleX, y: scaleY)
        
        context.setLineCap(.round)
        context.setLineJoin(.round)
        
        let shadeColor = UIColor(red: 0.92, green: 0.72, blue: 0.48, alpha: 1.0)
        let darkShadeColor = UIColor(red: 0.66, green: 0.45, blue: 0.27, alpha: 1.0)
        let standColor = UIColor(red: 0.83, green: 0.68, blue: 0.52, alpha: 1.0)
        
        let midX: CGFloat = 17
        
        let shadePath = UIBezierPath()
        shadePath.move(to: CGPoint(x: midX - 10, y: 4))
        shadePath.addLine(to: CGPoint(x: midX + 10, y: 4))
        shadePath.addLine(to: CGPoint(x: midX + 14, y: 19))
        shadePath.addLine(to: CGPoint(x: midX - 14, y: 19))
        shadePath.close()
        shadeColor.setFill()
        shadePath.fill()
        
        darkShadeColor.setStroke()
        shadePath.lineWidth = 1
        shadePath.stroke()
        
        standColor.setStroke()
        context.setLineWidth(2)
        context.move(to: CGPoint(x: midX, y: 19))
        context.addLine(to: CGPoint(x: midX, y: 39))
        context.strokePath()
        
        let basePath = UIBezierPath(
            roundedRect: CGRect(x: midX - 12, y: 39, width: 24, height: 5),
            cornerRadius: 2.5
        )
        standColor.setFill()
        basePath.fill()
        
        context.restoreGState()
    }
}

private final class MiniBookStackView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        context.saveGState()
        
        let scaleX = rect.width / 48
        let scaleY = rect.height / 24
        context.scaleBy(x: scaleX, y: scaleY)
        
        drawBook(x: 2, y: 18, width: 42, height: 6, color: UIColor(red: 0.90, green: 0.82, blue: 0.70, alpha: 1.0))
        drawBook(x: 8, y: 11, width: 34, height: 6, color: UIColor(red: 0.76, green: 0.67, blue: 0.55, alpha: 1.0))
        drawBook(x: 14, y: 4, width: 28, height: 6, color: UIColor(red: 0.96, green: 0.88, blue: 0.74, alpha: 1.0))
        
        context.restoreGState()
    }
    
    private func drawBook(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, color: UIColor) {
        let path = UIBezierPath(
            roundedRect: CGRect(x: x, y: y, width: width, height: height),
            cornerRadius: 1.5
        )
        color.setFill()
        path.fill()
        
        UIColor.black.withAlphaComponent(0.12).setStroke()
        path.lineWidth = 0.7
        path.stroke()
    }
}

private final class MiniPlantView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        context.saveGState()
        
        let scaleX = rect.width / 38
        let scaleY = rect.height / 46
        context.scaleBy(x: scaleX, y: scaleY)
        
        let stemColor = UIColor(red: 0.39, green: 0.66, blue: 0.35, alpha: 1.0)
        let leafColor = UIColor(red: 0.34, green: 0.74, blue: 0.38, alpha: 1.0)
        let potColor = UIColor(red: 0.82, green: 0.56, blue: 0.32, alpha: 1.0)
        let potDarkColor = UIColor(red: 0.61, green: 0.37, blue: 0.20, alpha: 1.0)
        
        let midX: CGFloat = 19
        
        stemColor.setStroke()
        context.setLineWidth(2)
        context.setLineCap(.round)
        context.move(to: CGPoint(x: midX, y: 29))
        context.addLine(to: CGPoint(x: midX, y: 9))
        context.strokePath()
        
        drawLeaf(center: CGPoint(x: midX - 8, y: 15), angle: -0.7, color: leafColor)
        drawLeaf(center: CGPoint(x: midX + 8, y: 12), angle: 0.7, color: leafColor)
        drawLeaf(center: CGPoint(x: midX - 6, y: 22), angle: -0.7, color: leafColor)
        drawLeaf(center: CGPoint(x: midX + 7, y: 21), angle: 0.7, color: leafColor)
        
        let potPath = UIBezierPath()
        potPath.move(to: CGPoint(x: midX - 12, y: 29))
        potPath.addLine(to: CGPoint(x: midX + 12, y: 29))
        potPath.addLine(to: CGPoint(x: midX + 9, y: 46))
        potPath.addLine(to: CGPoint(x: midX - 9, y: 46))
        potPath.close()
        potColor.setFill()
        potPath.fill()
        
        potDarkColor.setStroke()
        potPath.lineWidth = 1
        potPath.stroke()
        
        context.restoreGState()
    }
    
    private func drawLeaf(center: CGPoint, angle: CGFloat, color: UIColor) {
        let leafPath = UIBezierPath(
            ovalIn: CGRect(x: center.x - 5, y: center.y - 3, width: 10, height: 6)
        )
        
        let transform = CGAffineTransform(translationX: center.x, y: center.y)
            .rotated(by: angle)
            .translatedBy(x: -center.x, y: -center.y)
        
        leafPath.apply(transform)
        color.setFill()
        leafPath.fill()
    }
}

private final class ShelfDropShadowView: UIView {
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    private func configureUI() {
        backgroundColor = .clear
        isUserInteractionEnabled = false
        clipsToBounds = true
        
        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.13).cgColor,
            UIColor.black.withAlphaComponent(0.045).cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.locations = [0.0, 0.42, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        layer.addSublayer(gradientLayer)
    }
}

private final class TexturedWoodShelfTopView: UIView {
    private let imageView = UIImageView()
    private let lightOverlayLayer = CAGradientLayer()
    private let depthOverlayLayer = CAGradientLayer()
    private let topHighlightView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        lightOverlayLayer.frame = bounds
        depthOverlayLayer.frame = bounds
    }
    
    private func configureUI() {
        backgroundColor = UIColor(red: 0.78, green: 0.56, blue: 0.34, alpha: 1.0)
        clipsToBounds = true
        layer.cornerRadius = 2
        isUserInteractionEnabled = false
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "wood")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.alpha = imageView.image == nil ? 0.0 : 0.88
        imageView.isUserInteractionEnabled = false
        
        lightOverlayLayer.colors = [
            UIColor.white.withAlphaComponent(0.28).cgColor,
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.08).cgColor
        ]
        lightOverlayLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        lightOverlayLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        depthOverlayLayer.colors = [
            UIColor(red: 1.00, green: 0.82, blue: 0.55, alpha: 0.24).cgColor,
            UIColor(red: 0.46, green: 0.27, blue: 0.12, alpha: 0.26).cgColor
        ]
        depthOverlayLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        depthOverlayLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        topHighlightView.translatesAutoresizingMaskIntoConstraints = false
        topHighlightView.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        topHighlightView.isUserInteractionEnabled = false
        
        addSubview(imageView)
        layer.addSublayer(lightOverlayLayer)
        layer.addSublayer(depthOverlayLayer)
        addSubview(topHighlightView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            topHighlightView.topAnchor.constraint(equalTo: topAnchor),
            topHighlightView.leadingAnchor.constraint(equalTo: leadingAnchor),
            topHighlightView.trailingAnchor.constraint(equalTo: trailingAnchor),
            topHighlightView.heightAnchor.constraint(equalToConstant: 2)
        ])
    }
}

private final class TexturedWoodShelfSideView: UIView {
    private let imageView = UIImageView()
    private let darkOverlayLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        darkOverlayLayer.frame = bounds
    }
    
    private func configureUI() {
        backgroundColor = UIColor(red: 0.54, green: 0.34, blue: 0.18, alpha: 1.0)
        clipsToBounds = true
        isUserInteractionEnabled = false
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "wood")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.alpha = imageView.image == nil ? 0.0 : 0.64
        imageView.isUserInteractionEnabled = false
        
        darkOverlayLayer.colors = [
            UIColor.black.withAlphaComponent(0.08).cgColor,
            UIColor.black.withAlphaComponent(0.38).cgColor
        ]
        darkOverlayLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        darkOverlayLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        addSubview(imageView)
        layer.addSublayer(darkOverlayLayer)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
