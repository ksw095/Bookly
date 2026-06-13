import UIKit

final class BookDetailViewController: UIViewController {
    private var book: Book
    
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    
    private let topCardView = UIView()
    private let thumbnailImageView = UIImageView()
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let publisherLabel = UILabel()
    private let isbnLabel = UILabel()
    
    private let statusCardView = UIView()
    private let statusSegmentedControl = UISegmentedControl(items: [
        BookStatus.wish.rawValue,
        BookStatus.reading.rawValue,
        BookStatus.done.rawValue
    ])
    
    private let ratingView = HalfStarRatingView()
    private let ratingValueLabel = UILabel()
    
    private let periodCardView = UIView()
    private let startDatePicker = UIDatePicker()
    private let endDatePicker = UIDatePicker()
    private let periodSummaryLabel = UILabel()
    
    private let oneLineTextView = UITextView()
    private let memoTextView = UITextView()
    private let quoteTextView = UITextView()
    
    private let shareButton = UIButton(type: .system)
    private let deleteButton = UIButton(type: .system)
    
    private let navyColor = UIColor(red: 0.02, green: 0.10, blue: 0.28, alpha: 1.0)
    private let purpleColor = UIColor(red: 0.33, green: 0.25, blue: 0.94, alpha: 1.0)
    private let mutedTextColor = UIColor(red: 0.55, green: 0.56, blue: 0.62, alpha: 1.0)
    private let backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 0.99, alpha: 1.0)
    private let textColor = UIColor(red: 0.08, green: 0.09, blue: 0.12, alpha: 1.0)
    
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
            status: .done
        )
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "독서 기록"
        view.backgroundColor = backgroundColor
        
        configureNavigation()
        configureUI()
        configureKeyboardDismiss()
        applyBookData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dismissKeyboard()
    }
    
    private func configureNavigation() {
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 18)
        ]
        navigationController?.navigationBar.barTintColor = navyColor
        navigationController?.navigationBar.backgroundColor = navyColor
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "저장",
            style: .done,
            target: self,
            action: #selector(saveButtonTapped)
        )
    }
    
    private func configureUI() {
        configureScrollView()
        configureBookCard()
        configureStatusSection()
        configureRatingSection()
        configurePeriodSection()
        configureTextSections()
        configureActionButtons()
    }
    
    private func configureKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        
        scrollView.keyboardDismissMode = .interactive
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func configureScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.spacing = 16
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 18),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 18),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -18),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -32),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -36)
        ])
    }
    
    private func configureBookCard() {
        topCardView.backgroundColor = .white
        topCardView.layer.cornerRadius = 22
        topCardView.translatesAutoresizingMaskIntoConstraints = false
        
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.layer.cornerRadius = 10
        thumbnailImageView.backgroundColor = UIColor(red: 0.94, green: 0.95, blue: 0.98, alpha: 1.0)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .boldSystemFont(ofSize: 19)
        titleLabel.textColor = navyColor
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.font = .systemFont(ofSize: 14, weight: .medium)
        authorLabel.textColor = mutedTextColor
        authorLabel.numberOfLines = 1
        authorLabel.lineBreakMode = .byTruncatingTail
        
        publisherLabel.translatesAutoresizingMaskIntoConstraints = false
        publisherLabel.font = .systemFont(ofSize: 13, weight: .regular)
        publisherLabel.textColor = mutedTextColor
        publisherLabel.numberOfLines = 1
        publisherLabel.lineBreakMode = .byTruncatingTail
        
        isbnLabel.translatesAutoresizingMaskIntoConstraints = false
        isbnLabel.font = .systemFont(ofSize: 12, weight: .medium)
        isbnLabel.textColor = mutedTextColor
        isbnLabel.numberOfLines = 1
        isbnLabel.lineBreakMode = .byTruncatingTail
        
        topCardView.addSubview(thumbnailImageView)
        topCardView.addSubview(titleLabel)
        topCardView.addSubview(authorLabel)
        topCardView.addSubview(publisherLabel)
        topCardView.addSubview(isbnLabel)
        
        contentStackView.addArrangedSubview(topCardView)
        
        NSLayoutConstraint.activate([
            topCardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 150),
            
            thumbnailImageView.topAnchor.constraint(equalTo: topCardView.topAnchor, constant: 18),
            thumbnailImageView.leadingAnchor.constraint(equalTo: topCardView.leadingAnchor, constant: 18),
            thumbnailImageView.bottomAnchor.constraint(equalTo: topCardView.bottomAnchor, constant: -18),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 78),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 112),
            
            titleLabel.topAnchor.constraint(equalTo: thumbnailImageView.topAnchor, constant: 2),
            titleLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: topCardView.trailingAnchor, constant: -18),
            
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            authorLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            authorLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            publisherLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 6),
            publisherLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            publisherLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            isbnLabel.topAnchor.constraint(equalTo: publisherLabel.bottomAnchor, constant: 6),
            isbnLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            isbnLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            isbnLabel.bottomAnchor.constraint(lessThanOrEqualTo: topCardView.bottomAnchor, constant: -18)
        ])
    }
    
    private func configureStatusSection() {
        statusCardView.backgroundColor = .white
        statusCardView.layer.cornerRadius = 22
        statusCardView.translatesAutoresizingMaskIntoConstraints = false
        
        let sectionTitleLabel = makeSectionTitle("책 상태")
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = "현재 책의 독서 상태를 변경할 수 있어요."
        descriptionLabel.font = .systemFont(ofSize: 12, weight: .medium)
        descriptionLabel.textColor = mutedTextColor
        descriptionLabel.numberOfLines = 0
        
        statusSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        statusSegmentedControl.backgroundColor = backgroundColor
        statusSegmentedControl.selectedSegmentTintColor = purpleColor
        
        statusSegmentedControl.setTitleTextAttributes(
            [
                .foregroundColor: mutedTextColor,
                .font: UIFont.systemFont(ofSize: 13, weight: .semibold)
            ],
            for: .normal
        )
        
        statusSegmentedControl.setTitleTextAttributes(
            [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 13, weight: .bold)
            ],
            for: .selected
        )
        
        statusSegmentedControl.addTarget(
            self,
            action: #selector(statusSegmentChanged),
            for: .valueChanged
        )
        
        let textStack = UIStackView(arrangedSubviews: [
            sectionTitleLabel,
            descriptionLabel
        ])
        textStack.axis = .vertical
        textStack.spacing = 6
        
        let stack = UIStackView(arrangedSubviews: [
            textStack,
            statusSegmentedControl
        ])
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        statusCardView.addSubview(stack)
        contentStackView.addArrangedSubview(statusCardView)
        
        NSLayoutConstraint.activate([
            statusSegmentedControl.heightAnchor.constraint(equalToConstant: 40),
            
            stack.topAnchor.constraint(equalTo: statusCardView.topAnchor, constant: 18),
            stack.leadingAnchor.constraint(equalTo: statusCardView.leadingAnchor, constant: 18),
            stack.trailingAnchor.constraint(equalTo: statusCardView.trailingAnchor, constant: -18),
            stack.bottomAnchor.constraint(equalTo: statusCardView.bottomAnchor, constant: -18)
        ])
    }
    
    private func configureRatingSection() {
        let container = makeCardView()
        let sectionTitleLabel = makeSectionTitle("평점")
        
        ratingView.translatesAutoresizingMaskIntoConstraints = false
        ratingView.onRatingChanged = { [weak self] rating in
            guard let self else { return }
            self.book.ratingValue = rating
            self.book.rating = Int(rating.rounded())
            self.updateRatingValueLabel()
        }
        
        ratingValueLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingValueLabel.font = .systemFont(ofSize: 14, weight: .bold)
        ratingValueLabel.textColor = .systemOrange
        ratingValueLabel.textAlignment = .right
        
        let topStack = UIStackView(arrangedSubviews: [sectionTitleLabel, ratingValueLabel])
        topStack.axis = .horizontal
        topStack.alignment = .center
        topStack.distribution = .fillEqually
        
        let stack = UIStackView(arrangedSubviews: [topStack, ratingView])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(stack)
        contentStackView.addArrangedSubview(container)
        
        NSLayoutConstraint.activate([
            ratingView.heightAnchor.constraint(equalToConstant: 24),
            
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 14),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 18),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -18),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -14)
        ])
    }
    
    private func configurePeriodSection() {
        periodCardView.backgroundColor = .white
        periodCardView.layer.cornerRadius = 22
        periodCardView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = makeSectionTitle("읽은 기간")
        
        periodSummaryLabel.translatesAutoresizingMaskIntoConstraints = false
        periodSummaryLabel.font = .systemFont(ofSize: 13, weight: .bold)
        periodSummaryLabel.textColor = mutedTextColor
        periodSummaryLabel.textAlignment = .right
        periodSummaryLabel.numberOfLines = 1
        
        let topStack = UIStackView(arrangedSubviews: [titleLabel, periodSummaryLabel])
        topStack.axis = .horizontal
        topStack.alignment = .center
        topStack.distribution = .fillEqually
        
        let startRow = makeCompactDatePickerRow(title: "시작", picker: startDatePicker)
        let endRow = makeCompactDatePickerRow(title: "종료", picker: endDatePicker)
        
        let dateStack = UIStackView(arrangedSubviews: [startRow, endRow])
        dateStack.axis = .horizontal
        dateStack.spacing = 8
        dateStack.distribution = .fillEqually
        
        let stack = UIStackView(arrangedSubviews: [topStack, dateStack])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 9
        
        periodCardView.addSubview(stack)
        contentStackView.addArrangedSubview(periodCardView)
        
        NSLayoutConstraint.activate([
            startRow.heightAnchor.constraint(equalToConstant: 30),
            endRow.heightAnchor.constraint(equalToConstant: 30),
            
            stack.topAnchor.constraint(equalTo: periodCardView.topAnchor, constant: 14),
            stack.leadingAnchor.constraint(equalTo: periodCardView.leadingAnchor, constant: 18),
            stack.trailingAnchor.constraint(equalTo: periodCardView.trailingAnchor, constant: -18),
            stack.bottomAnchor.constraint(equalTo: periodCardView.bottomAnchor, constant: -14)
        ])
    }
    
    private func makeCompactDatePickerRow(title: String, picker: UIDatePicker) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = backgroundColor
        container.layer.cornerRadius = 11
        container.clipsToBounds = true
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = navyColor
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "ko_KR")
        picker.tintColor = navyColor
        picker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
        picker.transform = CGAffineTransform(scaleX: 0.82, y: 0.82)
        picker.setContentCompressionResistancePriority(.required, for: .horizontal)
        picker.setContentHuggingPriority(.required, for: .horizontal)
        
        container.addSubview(label)
        container.addSubview(picker)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            picker.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -2),
            picker.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            picker.leadingAnchor.constraint(greaterThanOrEqualTo: label.trailingAnchor, constant: 0)
        ])
        
        return container
    }
    
    private func configureTextSections() {
        contentStackView.addArrangedSubview(
            makeTextViewSection(
                title: "한줄평",
                description: "책을 읽고 가장 먼저 떠오른 문장을 적어보세요.",
                textView: oneLineTextView,
                height: 88
            )
        )
        
        contentStackView.addArrangedSubview(
            makeTextViewSection(
                title: "메모",
                description: "읽으면서 남기고 싶은 생각을 자유롭게 기록해보세요.",
                textView: memoTextView,
                height: 150
            )
        )
        
        contentStackView.addArrangedSubview(
            makeTextViewSection(
                title: "필사한 문구",
                description: "오래 기억하고 싶은 문장을 옮겨 적어보세요.",
                textView: quoteTextView,
                height: 86
            )
        )
    }
    
    private func configureActionButtons() {
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.setTitle("독서 카드 공유하기", for: .normal)
        shareButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        shareButton.setTitleColor(.white, for: .normal)
        shareButton.backgroundColor = purpleColor
        shareButton.layer.cornerRadius = 16
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.setTitle("삭제하기", for: .normal)
        deleteButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        deleteButton.setTitleColor(.systemRed, for: .normal)
        deleteButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.10)
        deleteButton.layer.cornerRadius = 16
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        
        contentStackView.addArrangedSubview(shareButton)
        contentStackView.addArrangedSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            shareButton.heightAnchor.constraint(equalToConstant: 52),
            deleteButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }
    
    private func applyBookData() {
        thumbnailImageView.setImage(from: book.thumbnail)
        titleLabel.text = book.title
        authorLabel.text = book.authorText
        publisherLabel.text = book.publisher.isEmpty ? "출판사 정보 없음" : "출판사 \(book.publisher)"
        
        let trimmedISBN = book.isbn.trimmingCharacters(in: .whitespacesAndNewlines)
        isbnLabel.text = trimmedISBN.isEmpty ? "ISBN 정보 없음" : "ISBN \(trimmedISBN)"
        
        statusSegmentedControl.selectedSegmentIndex = segmentIndex(for: book.status)
        
        ratingView.setRating(book.displayRating)
        updateRatingValueLabel()
        
        let startDate = book.readingStartedAt ?? book.createdAt
        let endDate = book.readingFinishedAt ?? Date()
        
        startDatePicker.date = startDate
        endDatePicker.date = maxDate(endDate, startDate)
        
        oneLineTextView.text = book.shortReviewText
        memoTextView.text = book.memoText
        quoteTextView.text = book.quoteText
        
        updateReadingPeriodSummary()
    }
    
    private func makeCardView() -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 22
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private func makeSectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .boldSystemFont(ofSize: 17)
        label.textColor = navyColor
        return label
    }
    
    private func makeTextViewSection(
        title: String,
        description: String,
        textView: UITextView,
        height: CGFloat
    ) -> UIView {
        let container = makeCardView()
        
        let titleLabel = makeSectionTitle(title)
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = description
        descriptionLabel.font = .systemFont(ofSize: 12, weight: .medium)
        descriptionLabel.textColor = mutedTextColor
        descriptionLabel.numberOfLines = 0
        
        textView.font = .systemFont(ofSize: 15, weight: .regular)
        textView.textColor = textColor
        textView.backgroundColor = backgroundColor
        textView.layer.cornerRadius = 14
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.keyboardDismissMode = .interactive
        
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            descriptionLabel,
            textView
        ])
        stack.axis = .vertical
        stack.spacing = 9
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(stack)
        
        NSLayoutConstraint.activate([
            textView.heightAnchor.constraint(equalToConstant: height),
            
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 18),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 18),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -18),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -18)
        ])
        
        return container
    }
    
    private func updateRatingValueLabel() {
        let rating = ratingView.rating
        
        if rating <= 0 {
            ratingValueLabel.text = "별점 없음"
        } else if rating.truncatingRemainder(dividingBy: 1) == 0 {
            ratingValueLabel.text = "\(Int(rating))점"
        } else {
            ratingValueLabel.text = String(format: "%.1f점", rating)
        }
    }
    
    private func updateReadingPeriodSummary() {
        if endDatePicker.date < startDatePicker.date {
            endDatePicker.date = startDatePicker.date
        }
        
        let start = Calendar.current.startOfDay(for: startDatePicker.date)
        let end = Calendar.current.startOfDay(for: endDatePicker.date)
        let days = Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
        
        periodSummaryLabel.text = "\(max(days + 1, 1))일"
    }
    
    @objc private func statusSegmentChanged() {
        guard let newStatus = statusForSelectedSegment() else {
            return
        }
        
        book.status = newStatus
        
        switch newStatus {
        case .wish:
            book.progress = nil
            book.readingStartedAt = nil
            book.readingFinishedAt = nil
            
        case .reading:
            book.readingStartedAt = book.readingStartedAt ?? Date()
            book.readingFinishedAt = nil
            book.progress = book.progress ?? 0.0
            startDatePicker.date = book.readingStartedAt ?? Date()
            endDatePicker.date = maxDate(Date(), startDatePicker.date)
            
        case .done:
            book.readingStartedAt = book.readingStartedAt ?? book.createdAt
            book.readingFinishedAt = Date()
            book.progress = 1.0
            startDatePicker.date = book.readingStartedAt ?? book.createdAt
            endDatePicker.date = maxDate(Date(), startDatePicker.date)
        }
        
        updateReadingPeriodSummary()
    }
    
    private func segmentIndex(for status: BookStatus) -> Int {
        switch status {
        case .wish:
            return 0
        case .reading:
            return 1
        case .done:
            return 2
        }
    }
    
    private func statusForSelectedSegment() -> BookStatus? {
        switch statusSegmentedControl.selectedSegmentIndex {
        case 0:
            return .wish
        case 1:
            return .reading
        case 2:
            return .done
        default:
            return nil
        }
    }
    
    private func saveCurrentInputs() {
        if let selectedStatus = statusForSelectedSegment() {
            book.status = selectedStatus
        }
        
        book.shortReview = oneLineTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        book.memo = memoTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        book.quote = quoteTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        book.ratingValue = ratingView.rating
        book.rating = Int(ratingView.rating.rounded())
        
        switch book.status {
        case .wish:
            book.progress = nil
            book.readingStartedAt = nil
            book.readingFinishedAt = nil
            
        case .reading:
            book.readingStartedAt = startDatePicker.date
            book.readingFinishedAt = nil
            book.progress = book.progress ?? 0.0
            
        case .done:
            book.readingStartedAt = startDatePicker.date
            book.readingFinishedAt = endDatePicker.date
            book.progress = 1.0
        }
        
        BookStore.shared.updateBook(book)
    }
    
    private func maxDate(_ lhs: Date, _ rhs: Date) -> Date {
        return lhs >= rhs ? lhs : rhs
    }
    
    @objc private func datePickerChanged() {
        updateReadingPeriodSummary()
    }
    
    @objc private func saveButtonTapped() {
        dismissKeyboard()
        saveCurrentInputs()
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func shareButtonTapped() {
        dismissKeyboard()
        saveCurrentInputs()
        
        let cardShareVC = CardShareViewController(book: book)
        navigationController?.pushViewController(cardShareVC, animated: true)
    }
    
    @objc private func deleteButtonTapped() {
        dismissKeyboard()
        
        let alert = UIAlertController(
            title: "독서 기록을 삭제할까요?",
            message: "삭제한 기록은 복구할 수 없습니다.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            guard let self else { return }
            BookStore.shared.deleteBook(self.book)
            self.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
}

extension BookDetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
    ) -> Bool {
        if touch.view is UIControl {
            return false
        }
        
        if touch.view is UITextView || touch.view is UITextField {
            return false
        }
        
        return true
    }
}

final class HalfStarRatingView: UIView {
    private var starImageViews: [UIImageView] = []
    private let stackView = UIStackView()
    
    private(set) var rating: Double = 0.0
    
    var onRatingChanged: ((Double) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }
    
    func setRating(_ value: Double) {
        rating = max(0, min(5, round(value * 2) / 2))
        updateStars()
    }
    
    private func configureUI() {
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = true
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.isUserInteractionEnabled = false
        
        addSubview(stackView)
        
        for _ in 0..<5 {
            let imageView = UIImageView()
            imageView.tintColor = .systemOrange
            imageView.contentMode = .scaleAspectFit
            imageView.image = UIImage(systemName: "star")
            
            starImageViews.append(imageView)
            stackView.addArrangedSubview(imageView)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleRatingGesture(_:)))
        addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleRatingGesture(_:)))
        addGestureRecognizer(panGesture)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        updateStars()
    }
    
    @objc private func handleRatingGesture(_ gesture: UIGestureRecognizer) {
        let location = gesture.location(in: self)
        let width = max(bounds.width, 1)
        let clampedX = min(max(location.x, 0), width)
        
        let rawValue = (clampedX / width) * 5.0
        let halfStepValue = ceil(rawValue * 2.0) / 2.0
        let newRating = max(0.5, min(5.0, halfStepValue))
        
        rating = newRating
        updateStars()
        onRatingChanged?(rating)
    }
    
    private func updateStars() {
        for index in 0..<starImageViews.count {
            let starNumber = Double(index + 1)
            let imageName: String
            
            if rating >= starNumber {
                imageName = "star.fill"
            } else if rating >= starNumber - 0.5 {
                imageName = "star.leadinghalf.filled"
            } else {
                imageName = "star"
            }
            
            starImageViews[index].image = UIImage(systemName: imageName)
        }
    }
}
