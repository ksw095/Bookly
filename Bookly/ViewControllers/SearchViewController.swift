import UIKit

final class SearchViewController: UIViewController {
    private enum SearchTarget: Int, CaseIterable {
        case title
        case author
        case publisher
        
        var title: String {
            switch self {
            case .title:
                return "제목"
            case .author:
                return "저자"
            case .publisher:
                return "출판사"
            }
        }
        
        var kakaoTarget: String {
            switch self {
            case .title:
                return "title"
            case .author:
                return "person"
            case .publisher:
                return "publisher"
            }
        }
    }
    
    private enum SearchSort: String {
        case accuracy
        case recency
        
        var title: String {
            switch self {
            case .accuracy:
                return "정확도순"
            case .recency:
                return "최신순"
            }
        }
    }
    
    private let headerView = UIView()
    private let logoLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let pageTitleLabel = UILabel()
    
    private let searchContainerView = UIView()
    private let searchIconImageView = UIImageView()
    private let searchTextField = UITextField()
    
    private let targetSegmentedControl = UISegmentedControl(items: SearchTarget.allCases.map { $0.title })
    
    private let resultContainerView = UIView()
    private let resultHeaderStackView = UIStackView()
    private let resultCountLabel = UILabel()
    private let sortButton = UIButton(type: .system)
    
    private let tableView = UITableView()
    private let emptyLabel = UILabel()
    private let footerLoadingView = UIActivityIndicatorView(style: .medium)
    
    private var searchResults: [KakaoBookDocument] = []
    
    private var currentKeyword: String = ""
    private var currentPage: Int = 1
    private var isEnd: Bool = true
    private var isLoading: Bool = false
    private var totalResultCount: Int = 0
    
    private var selectedTarget: SearchTarget = .title
    private var selectedSort: SearchSort = .accuracy
    
    private let pageSize: Int = 50
    
    private let navyColor = UIColor(red: 0.02, green: 0.10, blue: 0.28, alpha: 1.0)
    private let navyLightColor = UIColor(red: 0.18, green: 0.24, blue: 0.45, alpha: 1.0)
    private let purpleColor = UIColor(red: 0.33, green: 0.25, blue: 0.94, alpha: 1.0)
    private let mutedTextColor = UIColor(red: 0.55, green: 0.56, blue: 0.62, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = ""
        view.backgroundColor = navyColor
        navigationController?.setNavigationBarHidden(true, animated: false)
        configureUI()
        updateEmptyState(message: "검색어를 입력해 도서를 찾아보세요.")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        navigationController?.tabBarItem.title = "검색"
        navigationController?.tabBarItem.image = UIImage(systemName: "magnifyingglass")
        navigationController?.tabBarItem.selectedImage = UIImage(systemName: "magnifyingglass")
        navigationController?.tabBarItem.imageInsets = .zero
        navigationController?.tabBarItem.titlePositionAdjustment = .zero
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchTextField.resignFirstResponder()
    }
    
    private func configureUI() {
        configureHeader()
        configureSearchArea()
        configureResultArea()
        configureLayout()
    }
    
    private func configureHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = navyColor
        
        logoLabel.text = "Bookly"
        logoLabel.textColor = .white
        logoLabel.translatesAutoresizingMaskIntoConstraints = false
        logoLabel.textAlignment = .left
        logoLabel.font = UIFont(name: "Georgia-BoldItalic", size: 36) ?? .italicSystemFont(ofSize: 36)
        
        subtitleLabel.text = "기록할수록 나의 독서가 완성된다 ✦"
        subtitleLabel.font = .systemFont(ofSize: 11, weight: .medium)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.78)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.textAlignment = .left
        
        pageTitleLabel.text = "도서 검색"
        pageTitleLabel.font = .boldSystemFont(ofSize: 27)
        pageTitleLabel.textColor = .white
        pageTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        pageTitleLabel.textAlignment = .left
        
        view.addSubview(headerView)
        headerView.addSubview(logoLabel)
        headerView.addSubview(subtitleLabel)
        headerView.addSubview(pageTitleLabel)
    }
    
    private func configureSearchArea() {
        searchContainerView.translatesAutoresizingMaskIntoConstraints = false
        searchContainerView.backgroundColor = navyLightColor
        searchContainerView.layer.cornerRadius = 10
        
        searchIconImageView.image = UIImage(systemName: "magnifyingglass")
        searchIconImageView.tintColor = UIColor.white.withAlphaComponent(0.65)
        searchIconImageView.contentMode = .scaleAspectFit
        searchIconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        searchTextField.placeholder = "책 제목, 저자, 출판사로 검색해 보세요"
        searchTextField.textColor = .white
        searchTextField.tintColor = .white
        searchTextField.font = .systemFont(ofSize: 14, weight: .medium)
        searchTextField.returnKeyType = .search
        searchTextField.delegate = self
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.textAlignment = .left
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: "책 제목, 저자, 출판사로 검색해 보세요",
            attributes: [
                .foregroundColor: UIColor.white.withAlphaComponent(0.55)
            ]
        )
        
        searchContainerView.addSubview(searchIconImageView)
        searchContainerView.addSubview(searchTextField)
        
        targetSegmentedControl.selectedSegmentIndex = SearchTarget.title.rawValue
        targetSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        targetSegmentedControl.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        targetSegmentedControl.selectedSegmentTintColor = purpleColor
        targetSegmentedControl.setTitleTextAttributes(
            [
                .foregroundColor: UIColor.white.withAlphaComponent(0.82),
                .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
            ],
            for: .normal
        )
        targetSegmentedControl.setTitleTextAttributes(
            [
                .foregroundColor: UIColor.white,
                .font: UIFont.boldSystemFont(ofSize: 14)
            ],
            for: .selected
        )
        targetSegmentedControl.addTarget(self, action: #selector(targetChanged), for: .valueChanged)
        
        headerView.addSubview(searchContainerView)
        headerView.addSubview(targetSegmentedControl)
    }
    
    private func configureResultArea() {
        resultContainerView.translatesAutoresizingMaskIntoConstraints = false
        resultContainerView.backgroundColor = .white
        resultContainerView.layer.cornerRadius = 26
        resultContainerView.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
        resultContainerView.clipsToBounds = true
        
        resultCountLabel.text = "검색 결과 0권"
        resultCountLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        resultCountLabel.textColor = mutedTextColor
        
        configureSortButton()
        
        resultHeaderStackView.axis = .horizontal
        resultHeaderStackView.distribution = .equalSpacing
        resultHeaderStackView.alignment = .center
        resultHeaderStackView.translatesAutoresizingMaskIntoConstraints = false
        resultHeaderStackView.addArrangedSubview(resultCountLabel)
        resultHeaderStackView.addArrangedSubview(sortButton)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(BookTableViewCell.self, forCellReuseIdentifier: BookTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.keyboardDismissMode = .onDrag
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.rowHeight = 142
        tableView.showsVerticalScrollIndicator = false
        
        footerLoadingView.hidesWhenStopped = true
        
        emptyLabel.textColor = mutedTextColor
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        emptyLabel.font = .systemFont(ofSize: 14, weight: .medium)
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(resultContainerView)
        resultContainerView.addSubview(resultHeaderStackView)
        resultContainerView.addSubview(tableView)
        resultContainerView.addSubview(emptyLabel)
    }
    
    private func configureSortButton() {
        sortButton.setTitle(selectedSort.title, for: .normal)
        
        let chevronImage = UIImage(
            systemName: "chevron.down",
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: 10,
                weight: .semibold
            )
        )
        
        sortButton.setImage(chevronImage, for: .normal)
        sortButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        sortButton.setTitleColor(mutedTextColor, for: .normal)
        sortButton.tintColor = mutedTextColor
        sortButton.contentHorizontalAlignment = .right
        
        sortButton.imageEdgeInsets = UIEdgeInsets(
            top: 1,
            left: 4,
            bottom: -1,
            right: -4
        )
        
        sortButton.titleEdgeInsets = UIEdgeInsets(
            top: 0,
            left: -2,
            bottom: 0,
            right: 2
        )
        
        sortButton.showsMenuAsPrimaryAction = true
        sortButton.menu = makeSortMenu()
    }
    
    private func configureLayout() {
        let sideInset: CGFloat = 22
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 315),
            
            logoLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            logoLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: sideInset),
            logoLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -sideInset),
            
            subtitleLabel.topAnchor.constraint(equalTo: logoLabel.bottomAnchor, constant: 5),
            subtitleLabel.leadingAnchor.constraint(equalTo: logoLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -sideInset),
            
            pageTitleLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            pageTitleLabel.leadingAnchor.constraint(equalTo: logoLabel.leadingAnchor),
            pageTitleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -sideInset),
            
            searchContainerView.topAnchor.constraint(equalTo: pageTitleLabel.bottomAnchor, constant: 14),
            searchContainerView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: sideInset),
            searchContainerView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -sideInset),
            searchContainerView.heightAnchor.constraint(equalToConstant: 38),
            
            searchIconImageView.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor, constant: 14),
            searchIconImageView.centerYAnchor.constraint(equalTo: searchContainerView.centerYAnchor),
            searchIconImageView.widthAnchor.constraint(equalToConstant: 17),
            searchIconImageView.heightAnchor.constraint(equalToConstant: 17),
            
            searchTextField.leadingAnchor.constraint(equalTo: searchIconImageView.trailingAnchor, constant: 10),
            searchTextField.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor, constant: -12),
            searchTextField.topAnchor.constraint(equalTo: searchContainerView.topAnchor),
            searchTextField.bottomAnchor.constraint(equalTo: searchContainerView.bottomAnchor),
            
            targetSegmentedControl.topAnchor.constraint(equalTo: searchContainerView.bottomAnchor, constant: 13),
            targetSegmentedControl.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor),
            targetSegmentedControl.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor),
            targetSegmentedControl.heightAnchor.constraint(equalToConstant: 40),
            
            resultContainerView.topAnchor.constraint(equalTo: targetSegmentedControl.bottomAnchor, constant: 14),
            resultContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            resultHeaderStackView.topAnchor.constraint(equalTo: resultContainerView.topAnchor, constant: 22),
            resultHeaderStackView.leadingAnchor.constraint(equalTo: resultContainerView.leadingAnchor, constant: 28),
            resultHeaderStackView.trailingAnchor.constraint(equalTo: resultContainerView.trailingAnchor, constant: -28),
            resultHeaderStackView.heightAnchor.constraint(equalToConstant: 24),
            
            tableView.topAnchor.constraint(equalTo: resultHeaderStackView.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: resultContainerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: resultContainerView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: resultContainerView.bottomAnchor),
            
            emptyLabel.centerXAnchor.constraint(equalTo: resultContainerView.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: resultContainerView.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: resultContainerView.leadingAnchor, constant: 32),
            emptyLabel.trailingAnchor.constraint(equalTo: resultContainerView.trailingAnchor, constant: -32)
        ])
    }
    
    private func makeSortMenu() -> UIMenu {
        let accuracyAction = UIAction(
            title: "정확도순",
            state: selectedSort == .accuracy ? .on : .off
        ) { [weak self] _ in
            guard let self else {
                return
            }
            
            self.selectedSort = .accuracy
            self.configureSortButton()
            
            if !self.currentKeyword.isEmpty {
                self.startNewSearch(keyword: self.currentKeyword)
            }
        }
        
        let recencyAction = UIAction(
            title: "최신순",
            state: selectedSort == .recency ? .on : .off
        ) { [weak self] _ in
            guard let self else {
                return
            }
            
            self.selectedSort = .recency
            self.configureSortButton()
            
            if !self.currentKeyword.isEmpty {
                self.startNewSearch(keyword: self.currentKeyword)
            }
        }
        
        return UIMenu(title: "정렬", children: [accuracyAction, recencyAction])
    }
    
    @objc private func targetChanged() {
        selectedTarget = SearchTarget(rawValue: targetSegmentedControl.selectedSegmentIndex) ?? .title
        
        guard !currentKeyword.isEmpty else {
            return
        }
        
        startNewSearch(keyword: currentKeyword)
    }
    
    private func startNewSearch(keyword: String) {
        let trimmedKeyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedKeyword.isEmpty else {
            return
        }
        
        currentKeyword = trimmedKeyword
        currentPage = 1
        isEnd = false
        isLoading = false
        totalResultCount = 0
        searchResults = []
        tableView.reloadData()
        
        updateEmptyState(message: "검색 중...")
        resultCountLabel.text = "검색 결과 0권"
        
        loadBooks(page: currentPage, isNewSearch: true)
    }
    
    private func loadNextPageIfNeeded(currentIndex: Int) {
        let thresholdIndex = searchResults.count - 8
        
        guard currentIndex >= thresholdIndex else {
            return
        }
        
        guard !isLoading, !isEnd, currentPage < 50 else {
            return
        }
        
        currentPage += 1
        loadBooks(page: currentPage, isNewSearch: false)
    }
    
    private func loadBooks(page: Int, isNewSearch: Bool) {
        guard !isLoading else {
            return
        }
        
        isLoading = true
        updateFooterLoading(isLoading: true)
        
        Task {
            do {
                let response = try await KakaoBookService.shared.searchBooks(
                    keyword: currentKeyword,
                    page: page,
                    size: pageSize,
                    target: selectedTarget.kakaoTarget,
                    sort: selectedSort.rawValue
                )
                
                await MainActor.run {
                    let filteredDocuments = self.filterDocumentsBySelectedTarget(response.documents)
                    
                    self.isEnd = response.meta.is_end || page >= 50
                    
                    if isNewSearch {
                        self.searchResults = self.removeDuplicates(from: filteredDocuments)
                    } else {
                        self.searchResults = self.removeDuplicates(from: self.searchResults + filteredDocuments)
                    }
                    
                    if self.selectedSort == .recency {
                        self.searchResults = self.sortByLatestPublicationDate(self.searchResults)
                    }
                    
                    self.totalResultCount = self.searchResults.count
                    self.resultCountLabel.text = "검색 결과 \(self.totalResultCount)권"
                    self.tableView.reloadData()
                    
                    if self.searchResults.isEmpty {
                        self.updateEmptyState(message: "검색 결과가 없습니다.")
                    } else {
                        self.emptyLabel.isHidden = true
                    }
                    
                    self.isLoading = false
                    self.updateFooterLoading(isLoading: false)
                }
            } catch {
                await MainActor.run {
                    if isNewSearch {
                        self.searchResults = []
                        self.tableView.reloadData()
                        self.resultCountLabel.text = "검색 결과 0권"
                        self.updateEmptyState(message: "검색 중 오류가 발생했습니다.\nAPI 키 또는 네트워크 상태를 확인하세요.")
                    }
                    
                    self.isLoading = false
                    self.updateFooterLoading(isLoading: false)
                }
            }
        }
    }
    
    private func filterDocumentsBySelectedTarget(_ documents: [KakaoBookDocument]) -> [KakaoBookDocument] {
        let normalizedKeyword = normalizeSearchText(currentKeyword)
        
        guard !normalizedKeyword.isEmpty else {
            return documents
        }
        
        return documents.filter { document in
            switch selectedTarget {
            case .title:
                let title = normalizeSearchText(document.title)
                return title.contains(normalizedKeyword)
                
            case .author:
                return document.authors.contains { author in
                    normalizeSearchText(author).contains(normalizedKeyword)
                }
                
            case .publisher:
                let publisher = normalizeSearchText(document.publisher)
                return publisher.contains(normalizedKeyword)
            }
        }
    }
    
    private func normalizeSearchText(_ text: String) -> String {
        text
            .removingHTMLTags()
            .lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\t", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "_", with: "")
    }
    
    private func updateEmptyState(message: String) {
        emptyLabel.text = message
        emptyLabel.isHidden = false
    }
    
    private func updateFooterLoading(isLoading: Bool) {
        if isLoading && !searchResults.isEmpty {
            let footerContainer = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 56))
            footerLoadingView.center = footerContainer.center
            footerContainer.addSubview(footerLoadingView)
            tableView.tableFooterView = footerContainer
            footerLoadingView.startAnimating()
        } else {
            footerLoadingView.stopAnimating()
            tableView.tableFooterView = nil
        }
    }
    
    private func removeDuplicates(from documents: [KakaoBookDocument]) -> [KakaoBookDocument] {
        var seenKeys = Set<String>()
        var uniqueDocuments: [KakaoBookDocument] = []
        
        for document in documents {
            let normalizedISBN = document.isbn.trimmingCharacters(in: .whitespacesAndNewlines)
            let key: String
            
            if !normalizedISBN.isEmpty {
                key = normalizedISBN
            } else {
                key = "\(document.title)-\(document.authors.joined(separator: ","))-\(document.publisher)"
            }
            
            if !seenKeys.contains(key) {
                seenKeys.insert(key)
                uniqueDocuments.append(document)
            }
        }
        
        return uniqueDocuments
    }
    
    private func sortByLatestPublicationDate(_ documents: [KakaoBookDocument]) -> [KakaoBookDocument] {
        return documents.sorted { first, second in
            let firstDate = normalizedDateValue(from: first.datetime)
            let secondDate = normalizedDateValue(from: second.datetime)
            return firstDate > secondDate
        }
    }
    
    private func normalizedDateValue(from datetime: String) -> String {
        let trimmed = datetime.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            return "0000-00-00"
        }
        
        if trimmed.count >= 10 {
            return String(trimmed.prefix(10))
        }
        
        return trimmed
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        startNewSearch(keyword: textField.text ?? "")
        return true
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchResults.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let document = searchResults[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: BookTableViewCell.identifier,
            for: indexPath
        ) as! BookTableViewCell
        
        cell.configureSearchResult(with: document)
        loadNextPageIfNeeded(currentIndex: indexPath.row)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchTextField.resignFirstResponder()
        
        let document = searchResults[indexPath.row]
        let detailVC = SearchBookDetailViewController(document: document)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
