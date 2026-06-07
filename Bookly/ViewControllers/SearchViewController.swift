import UIKit

final class SearchViewController: UIViewController {
    private let searchBar = UISearchBar()
    private let searchButton = UIButton(type: .system)
    private let searchContainerView = UIView()
    private let tableView = UITableView()
    private let emptyLabel = UILabel()
    private let footerLoadingView = UIActivityIndicatorView(style: .medium)
    
    private var searchResults: [KakaoBookDocument] = []
    
    private var currentKeyword: String = ""
    private var currentPage: Int = 1
    private var isEnd: Bool = true
    private var isLoading: Bool = false
    
    private let pageSize: Int = 50
    private let navyColor = UIColor(red: 0.02, green: 0.12, blue: 0.36, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "도서 검색"
        view.backgroundColor = .systemBackground
        configureUI()
    }
    
    private func configureUI() {
        searchContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        searchBar.placeholder = "책 제목, 저자, 출판사 키워드 입력"
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.backgroundColor = .clear
        searchButton.tintColor = navyColor
        searchButton.layer.cornerRadius = 0
        searchButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(BookTableViewCell.self, forCellReuseIdentifier: BookTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.keyboardDismissMode = .onDrag
        
        footerLoadingView.hidesWhenStopped = true
        
        emptyLabel.text = "검색어를 입력해 도서를 찾아보세요."
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(searchContainerView)
        searchContainerView.addSubview(searchBar)
        searchContainerView.addSubview(searchButton)
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        
        NSLayoutConstraint.activate([
            searchContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            searchContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            searchContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            searchContainerView.heightAnchor.constraint(equalToConstant: 50),
            
            searchBar.topAnchor.constraint(equalTo: searchContainerView.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor),
            searchBar.bottomAnchor.constraint(equalTo: searchContainerView.bottomAnchor),
            searchBar.trailingAnchor.constraint(equalTo: searchButton.leadingAnchor, constant: -4),
            
            searchButton.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor),
            searchButton.centerYAnchor.constraint(equalTo: searchContainerView.centerYAnchor),
            searchButton.widthAnchor.constraint(equalToConstant: 36),
            searchButton.heightAnchor.constraint(equalToConstant: 36),
            
            tableView.topAnchor.constraint(equalTo: searchContainerView.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }
    
    @objc private func searchButtonTapped() {
        searchBar.resignFirstResponder()
        startNewSearch(keyword: searchBar.text ?? "")
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
        searchResults = []
        tableView.reloadData()
        
        emptyLabel.text = "검색 중..."
        emptyLabel.isHidden = false
        
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
                    target: nil,
                    sort: "accuracy"
                )
                
                await MainActor.run {
                    let newDocuments = response.documents
                    self.isEnd = response.meta.is_end || page >= 50
                    
                    if isNewSearch {
                        self.searchResults = self.removeDuplicates(from: newDocuments)
                    } else {
                        self.searchResults = self.removeDuplicates(from: self.searchResults + newDocuments)
                    }
                    
                    self.tableView.reloadData()
                    self.emptyLabel.isHidden = !self.searchResults.isEmpty
                    self.emptyLabel.text = self.searchResults.isEmpty ? "검색 결과가 없습니다." : ""
                    
                    self.isLoading = false
                    self.updateFooterLoading(isLoading: false)
                }
            } catch {
                await MainActor.run {
                    if isNewSearch {
                        self.searchResults = []
                        self.tableView.reloadData()
                        self.emptyLabel.isHidden = false
                        self.emptyLabel.text = "검색 중 오류가 발생했습니다.\nAPI 키 또는 네트워크 상태를 확인하세요."
                    }
                    
                    self.isLoading = false
                    self.updateFooterLoading(isLoading: false)
                }
            }
        }
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
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        startNewSearch(keyword: searchBar.text ?? "")
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        let document = searchResults[indexPath.row]
        let detailVC = SearchBookDetailViewController(document: document)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
