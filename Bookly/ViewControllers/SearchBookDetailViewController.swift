import UIKit

final class SearchBookDetailViewController: UIViewController {
    private let document: KakaoBookDocument
    private var selectedStatus: BookStatus = .wish
    private var isContentsExpanded = false
    
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    
    private let thumbnailContainerView = UIView()
    private let thumbnailImageView = UIImageView()
    
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let publisherLabel = UILabel()
    private let dateLabel = UILabel()
    private let priceLabel = UILabel()
    private let isbnLabel = UILabel()
    
    private let contentsLabel = UILabel()
    private let contentsNoticeLabel = UILabel()
    private let contentsMoreButton = UIButton(type: .system)
    
    private let statusSegmentedControl = UISegmentedControl(items: BookStatus.allCases.map { $0.rawValue })
    private let addButton = UIButton(type: .system)
    
    private let navyColor = UIColor(red: 0.02, green: 0.12, blue: 0.36, alpha: 1.0)
    
    init(document: KakaoBookDocument) {
        self.document = document
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("SearchBookDetailViewController는 코드로만 생성됩니다.")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "도서 정보"
        view.backgroundColor = .systemGroupedBackground
        configureUI()
        applyDocumentData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        configureBackButton()
    }
    
    private func configureBackButton() {
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        
        backButton.tintColor = .white
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func configureUI() {
        configureScrollView()
        configureBookInfoSection()
        configureContentsSection()
        configureStatusSection()
        configureAddButton()
    }
    
    private func configureScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.spacing = 20
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -30),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32)
        ])
    }
    
    private func configureBookInfoSection() {
        let container = makeCardView()
        
        thumbnailContainerView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailContainerView.backgroundColor = .secondarySystemBackground
        thumbnailContainerView.layer.cornerRadius = 12
        thumbnailContainerView.clipsToBounds = true
        
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView.contentMode = .scaleAspectFit
        thumbnailImageView.clipsToBounds = true
        
        thumbnailContainerView.addSubview(thumbnailImageView)
        
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.numberOfLines = 3
        titleLabel.textAlignment = .left
        
        authorLabel.font = .systemFont(ofSize: 13)
        authorLabel.textColor = .secondaryLabel
        authorLabel.numberOfLines = 2
        authorLabel.textAlignment = .left
        
        publisherLabel.font = .systemFont(ofSize: 13)
        publisherLabel.textColor = .secondaryLabel
        publisherLabel.numberOfLines = 1
        publisherLabel.textAlignment = .left
        
        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = .secondaryLabel
        dateLabel.numberOfLines = 1
        dateLabel.textAlignment = .left
        
        priceLabel.font = .boldSystemFont(ofSize: 15)
        priceLabel.textColor = navyColor
        priceLabel.numberOfLines = 1
        priceLabel.textAlignment = .left
        
        isbnLabel.font = .systemFont(ofSize: 11)
        isbnLabel.textColor = .secondaryLabel
        isbnLabel.numberOfLines = 2
        isbnLabel.textAlignment = .left
        
        let infoStack = UIStackView(arrangedSubviews: [
            titleLabel,
            authorLabel,
            publisherLabel,
            dateLabel,
            isbnLabel,
            priceLabel
        ])
        infoStack.axis = .vertical
        infoStack.spacing = 7
        infoStack.alignment = .fill
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        
        let horizontalStack = UIStackView(arrangedSubviews: [
            thumbnailContainerView,
            infoStack
        ])
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 16
        horizontalStack.alignment = .top
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(horizontalStack)
        contentStackView.addArrangedSubview(container)
        
        NSLayoutConstraint.activate([
            thumbnailContainerView.widthAnchor.constraint(equalToConstant: 125),
            thumbnailContainerView.heightAnchor.constraint(equalToConstant: 180),
            
            thumbnailImageView.topAnchor.constraint(equalTo: thumbnailContainerView.topAnchor, constant: 8),
            thumbnailImageView.leadingAnchor.constraint(equalTo: thumbnailContainerView.leadingAnchor, constant: 8),
            thumbnailImageView.trailingAnchor.constraint(equalTo: thumbnailContainerView.trailingAnchor, constant: -8),
            thumbnailImageView.bottomAnchor.constraint(equalTo: thumbnailContainerView.bottomAnchor, constant: -8),
            
            horizontalStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 18),
            horizontalStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            horizontalStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            horizontalStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -18)
        ])
    }
    
    private func configureContentsSection() {
        let container = makeCardView()
        
        let sectionTitleLabel = makeSectionTitleLabel("책 소개")
        
        contentsLabel.font = .systemFont(ofSize: 15)
        contentsLabel.textColor = .label
        contentsLabel.numberOfLines = 3
        contentsLabel.lineBreakMode = .byTruncatingTail
        
        contentsNoticeLabel.text = "카카오 도서 API에서 제공하는 소개문입니다."
        contentsNoticeLabel.font = .systemFont(ofSize: 12)
        contentsNoticeLabel.textColor = .secondaryLabel
        contentsNoticeLabel.numberOfLines = 0
        
        contentsMoreButton.setTitle("… 더보기", for: .normal)
        contentsMoreButton.titleLabel?.font = .boldSystemFont(ofSize: 14)
        contentsMoreButton.setTitleColor(.systemIndigo, for: .normal)
        contentsMoreButton.contentHorizontalAlignment = .leading
        contentsMoreButton.addTarget(self, action: #selector(contentsMoreButtonTapped), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [
            sectionTitleLabel,
            contentsLabel,
            contentsMoreButton,
            contentsNoticeLabel
        ])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(stack)
        contentStackView.addArrangedSubview(container)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
    }
    
    private func configureStatusSection() {
        let container = makeCardView()
        
        let sectionTitleLabel = makeSectionTitleLabel("어느 서재에 담을까요?")
        
        statusSegmentedControl.selectedSegmentIndex = 0
        statusSegmentedControl.addTarget(self, action: #selector(statusChanged), for: .valueChanged)
        statusSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        let guideLabel = UILabel()
        guideLabel.text = "책 정보를 확인한 뒤 원하는 상태를 선택하세요."
        guideLabel.font = .systemFont(ofSize: 13)
        guideLabel.textColor = .secondaryLabel
        guideLabel.numberOfLines = 0
        
        let stack = UIStackView(arrangedSubviews: [
            sectionTitleLabel,
            guideLabel,
            statusSegmentedControl
        ])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(stack)
        contentStackView.addArrangedSubview(container)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
    }
    
    private func configureAddButton() {
        addButton.setTitle("서재에 담기", for: .normal)
        addButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        addButton.setTitleColor(.white, for: .normal)
        addButton.backgroundColor = .systemIndigo
        addButton.layer.cornerRadius = 14
        addButton.heightAnchor.constraint(equalToConstant: 54).isActive = true
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        contentStackView.addArrangedSubview(addButton)
    }
    
    private func applyDocumentData() {
        thumbnailImageView.setImage(from: document.thumbnail)
        titleLabel.text = document.title.removingHTMLTags()
        
        if document.authors.isEmpty {
            authorLabel.text = "저자: 정보 없음"
        } else {
            authorLabel.text = "저자: \(document.authors.joined(separator: ", "))"
        }
        
        publisherLabel.text = document.publisher.isEmpty
        ? "출판사: 정보 없음"
        : "출판사: \(document.publisher)"
        
        dateLabel.text = publishedDateText(from: document.datetime)
        priceLabel.text = formattedPrice(from: document)
        isbnLabel.text = document.isbn.isEmpty ? "ISBN 정보 없음" : "ISBN: \(document.isbn)"
        
        let cleanedContents = cleanBookContents(document.contents)
        let trimmedContents = trimIncompleteLastSentence(cleanedContents)
        
        let finalContents = trimmedContents.isEmpty ? "책 소개 정보가 없습니다." : trimmedContents
        contentsLabel.text = finalContents
        
        contentsMoreButton.isHidden = finalContents.count < 90
    }
    
    private func cleanBookContents(_ text: String) -> String {
        return text
            .removingHTMLTags()
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\r", with: " ")
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func trimIncompleteLastSentence(_ text: String) -> String {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedText.isEmpty else {
            return ""
        }
        
        let sentenceEndCharacters: Set<Character> = [".", "!", "?", "。", "！", "？"]
        
        if let lastCharacter = trimmedText.last,
           sentenceEndCharacters.contains(lastCharacter) {
            return trimmedText
        }
        
        var lastSentenceEndIndex: String.Index?
        
        for index in trimmedText.indices {
            let character = trimmedText[index]
            if sentenceEndCharacters.contains(character) {
                lastSentenceEndIndex = index
            }
        }
        
        guard let endIndex = lastSentenceEndIndex else {
            return trimmedText
        }
        
        let nextIndex = trimmedText.index(after: endIndex)
        return String(trimmedText[..<nextIndex])
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func publishedDateText(from datetime: String) -> String {
        if datetime.count >= 10 {
            return "출판일: \(String(datetime.prefix(10)))"
        }
        
        return datetime.isEmpty ? "출판일 정보 없음" : "출판일: \(datetime)"
    }
    
    private func formattedPrice(from document: KakaoBookDocument) -> String {
        let candidatePrice: Int
        
        if let salePrice = document.sale_price, salePrice > 0 {
            candidatePrice = salePrice
        } else if let price = document.price, price > 0 {
            candidatePrice = price
        } else {
            return "가격 정보 없음"
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        let formattedNumber = formatter.string(from: NSNumber(value: candidatePrice)) ?? "\(candidatePrice)"
        return "\(formattedNumber)원"
    }
    
    private func makeCardView() -> UIView {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        return view
    }
    
    private func makeSectionTitleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .boldSystemFont(ofSize: 17)
        return label
    }
    
    @objc private func contentsMoreButtonTapped() {
        isContentsExpanded.toggle()
        
        UIView.animate(withDuration: 0.25) {
            self.contentsLabel.numberOfLines = self.isContentsExpanded ? 0 : 3
            self.contentsMoreButton.setTitle(
                self.isContentsExpanded ? "접기" : "… 더보기",
                for: .normal
            )
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func statusChanged() {
        selectedStatus = BookStatus.allCases[statusSegmentedControl.selectedSegmentIndex]
    }
    
    @objc private func addButtonTapped() {
        let book = document.toBook(status: selectedStatus)
        
        if isAlreadySaved(book: book) {
            showAlert(
                title: "이미 추가된 책",
                message: "이 책은 이미 나의 서재에 담겨 있습니다."
            )
            return
        }
        
        BookStore.shared.addBook(book)
        
        let alert = UIAlertController(
            title: "서재에 담았습니다",
            message: "\(book.title)을 \(selectedStatus.rawValue)에 추가했습니다.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    private func isAlreadySaved(book: Book) -> Bool {
        if !book.isbn.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return BookStore.shared.books.contains { $0.isbn == book.isbn }
        }
        
        return BookStore.shared.books.contains {
            $0.title == book.title &&
            $0.authorText == book.authorText &&
            $0.publisher == book.publisher
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
