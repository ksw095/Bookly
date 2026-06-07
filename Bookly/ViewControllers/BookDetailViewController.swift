import UIKit

final class BookDetailViewController: UIViewController {
    private var book: Book
    
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    
    private let thumbnailImageView = UIImageView()
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let publisherLabel = UILabel()
    private let dateLabel = UILabel()
    
    private let statusSegmentedControl = UISegmentedControl(items: BookStatus.allCases.map { $0.rawValue })
    
    private let progressContainerView = UIView()
    private let progressSlider = UISlider()
    private let progressValueLabel = UILabel()
    
    private var ratingButtons: [UIButton] = []
    private let memoTextView = UITextView()
    
    private let navyColor = UIColor(red: 0.02, green: 0.12, blue: 0.36, alpha: 1.0)
    
    init(book: Book) {
        self.book = book
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.book = Book(
            title: "",
            authors: [],
            publisher: "",
            isbn: "",
            datetime: "",
            thumbnail: "",
            status: .wish
        )
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "기록 작성"
        view.backgroundColor = .systemGroupedBackground
        configureUI()
        applyBookData()
    }
    
    private func configureUI() {
        configureNavigationButtons()
        configureScrollView()
        configureBookInfoSection()
        configureStatusSection()
        configureProgressSection()
        configureRatingSection()
        configureMemoSection()
        configureActionButtons()
    }
    
    private func configureNavigationButtons() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "저장",
            style: .done,
            target: self,
            action: #selector(saveButtonTapped)
        )
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
        
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView.layer.cornerRadius = 10
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.contentMode = .scaleAspectFit
        thumbnailImageView.backgroundColor = .secondarySystemBackground
        
        titleLabel.font = .boldSystemFont(ofSize: 22)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        authorLabel.font = .systemFont(ofSize: 14)
        authorLabel.textColor = .secondaryLabel
        authorLabel.textAlignment = .center
        authorLabel.numberOfLines = 0
        
        publisherLabel.font = .systemFont(ofSize: 13)
        publisherLabel.textColor = .secondaryLabel
        publisherLabel.textAlignment = .center
        
        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = .secondaryLabel
        dateLabel.textAlignment = .center
        
        let infoStack = UIStackView(arrangedSubviews: [
            thumbnailImageView,
            titleLabel,
            authorLabel,
            publisherLabel,
            dateLabel
        ])
        infoStack.axis = .vertical
        infoStack.spacing = 10
        infoStack.alignment = .center
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(infoStack)
        contentStackView.addArrangedSubview(container)
        
        NSLayoutConstraint.activate([
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 120),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 170),
            
            infoStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            infoStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            infoStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            infoStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20)
        ])
    }
    
    private func configureStatusSection() {
        let container = makeCardView()
        
        let label = makeSectionLabel("독서 상태")
        statusSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        statusSegmentedControl.addTarget(self, action: #selector(statusChanged), for: .valueChanged)
        
        let stack = UIStackView(arrangedSubviews: [label, statusSegmentedControl])
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
    
    private func configureProgressSection() {
        progressContainerView.backgroundColor = .systemBackground
        progressContainerView.layer.cornerRadius = 16
        
        let label = makeSectionLabel("독서 진행률")
        
        progressValueLabel.font = .boldSystemFont(ofSize: 15)
        progressValueLabel.textColor = navyColor
        progressValueLabel.textAlignment = .right
        
        progressSlider.minimumValue = 0
        progressSlider.maximumValue = 100
        progressSlider.value = Float(book.progressValue)
        progressSlider.minimumTrackTintColor = navyColor
        progressSlider.maximumTrackTintColor = .systemGray5
        progressSlider.addTarget(self, action: #selector(progressSliderChanged), for: .valueChanged)
        
        let topStack = UIStackView(arrangedSubviews: [label, progressValueLabel])
        topStack.axis = .horizontal
        topStack.distribution = .fillEqually
        
        let guideLabel = UILabel()
        guideLabel.text = "현재 읽은 정도를 0%부터 100%까지 기록할 수 있습니다."
        guideLabel.font = .systemFont(ofSize: 12)
        guideLabel.textColor = .secondaryLabel
        guideLabel.numberOfLines = 0
        
        let stack = UIStackView(arrangedSubviews: [
            topStack,
            progressSlider,
            guideLabel
        ])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        progressContainerView.addSubview(stack)
        contentStackView.addArrangedSubview(progressContainerView)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: progressContainerView.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: progressContainerView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: progressContainerView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: progressContainerView.bottomAnchor, constant: -16)
        ])
    }
    
    private func configureRatingSection() {
        let container = makeCardView()
        
        let label = makeSectionLabel("평점")
        
        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.spacing = 8
        buttonStack.distribution = .fillEqually
        
        for score in 1...5 {
            let button = UIButton(type: .system)
            button.tag = score
            button.setImage(UIImage(systemName: "star"), for: .normal)
            button.tintColor = .systemOrange
            button.addTarget(self, action: #selector(ratingButtonTapped(_:)), for: .touchUpInside)
            ratingButtons.append(button)
            buttonStack.addArrangedSubview(button)
        }
        
        let stack = UIStackView(arrangedSubviews: [label, buttonStack])
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
    
    private func configureMemoSection() {
        let container = makeCardView()
        
        let label = makeSectionLabel("한 줄 소감 / 메모")
        
        memoTextView.font = .systemFont(ofSize: 15)
        memoTextView.backgroundColor = .secondarySystemBackground
        memoTextView.layer.cornerRadius = 10
        memoTextView.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        memoTextView.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView(arrangedSubviews: [label, memoTextView])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(stack)
        contentStackView.addArrangedSubview(container)
        
        NSLayoutConstraint.activate([
            memoTextView.heightAnchor.constraint(equalToConstant: 150),
            
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
    }
    
    private func configureActionButtons() {
        let shareButton = UIButton(type: .system)
        shareButton.setTitle("독서 기록 공유하기", for: .normal)
        shareButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        shareButton.backgroundColor = .secondarySystemBackground
        shareButton.layer.cornerRadius = 12
        shareButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        
        let deleteButton = UIButton(type: .system)
        deleteButton.setTitle("삭제하기", for: .normal)
        deleteButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        deleteButton.setTitleColor(.systemRed, for: .normal)
        deleteButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        deleteButton.layer.cornerRadius = 12
        deleteButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        
        contentStackView.addArrangedSubview(shareButton)
        contentStackView.addArrangedSubview(deleteButton)
    }
    
    private func applyBookData() {
        thumbnailImageView.setImage(from: book.thumbnail)
        titleLabel.text = book.title
        authorLabel.text = book.authorText
        publisherLabel.text = book.publisher.isEmpty ? "출판사 정보 없음" : book.publisher
        dateLabel.text = book.publishedDateText
        
        if let index = BookStatus.allCases.firstIndex(of: book.status) {
            statusSegmentedControl.selectedSegmentIndex = index
        }
        
        memoTextView.text = book.memo
        
        progressSlider.value = Float(book.progressValue)
        updateProgressLabel()
        updateProgressSectionVisibility()
        
        updateRatingButtons()
    }
    
    private func makeCardView() -> UIView {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        return view
    }
    
    private func makeSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .boldSystemFont(ofSize: 17)
        return label
    }
    
    private func updateRatingButtons() {
        for button in ratingButtons {
            let imageName = button.tag <= book.rating ? "star.fill" : "star"
            button.setImage(UIImage(systemName: imageName), for: .normal)
        }
    }
    
    private func updateProgressSectionVisibility() {
        progressContainerView.isHidden = book.status != .reading
    }
    
    private func updateProgressLabel() {
        progressValueLabel.text = "\(Int(book.progressValue))%"
    }
    
    @objc private func statusChanged() {
        book.status = BookStatus.allCases[statusSegmentedControl.selectedSegmentIndex]
        
        if book.status == .reading {
            book.readingStartedAt = book.readingStartedAt ?? Date()
            book.progress = book.progress ?? 0.0
            progressSlider.value = Float(book.progressValue)
        }
        
        if book.status == .done {
            book.progress = 100.0
            progressSlider.value = 100
        }
        
        updateProgressLabel()
        updateProgressSectionVisibility()
    }
    
    @objc private func progressSliderChanged() {
        book.progress = Double(Int(progressSlider.value))
        updateProgressLabel()
    }
    
    @objc private func ratingButtonTapped(_ sender: UIButton) {
        book.rating = sender.tag
        updateRatingButtons()
    }
    
    @objc private func saveButtonTapped() {
        book.memo = memoTextView.text ?? ""
        
        if book.status == .reading {
            book.readingStartedAt = book.readingStartedAt ?? Date()
            book.progress = Double(Int(progressSlider.value))
        }
        
        if book.status == .done {
            book.progress = 100.0
        }
        
        BookStore.shared.updateBook(book)
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func shareButtonTapped() {
        book.memo = memoTextView.text ?? ""
        
        let progressText: String
        if book.status == .reading {
            progressText = "\n진행률: \(Int(book.progressValue))%"
        } else {
            progressText = ""
        }
        
        let shareText = """
        📚 Bookly 독서 기록

        제목: \(book.title)
        저자: \(book.authorText)
        출판사: \(book.publisher.isEmpty ? "정보 없음" : book.publisher)
        상태: \(book.status.rawValue)\(progressText)
        평점: \(book.rating) / 5

        한 줄 소감:
        \(book.memo.isEmpty ? "아직 메모가 없습니다." : book.memo)
        """
        
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    @objc private func deleteButtonTapped() {
        let alert = UIAlertController(
            title: "책을 삭제할까요?",
            message: "삭제한 독서 기록은 복구할 수 없습니다.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { _ in
            BookStore.shared.deleteBook(self.book)
            self.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
}
