import UIKit

fileprivate enum CardShareStyle: Int, CaseIterable {
    case paper
    case mood
    case night
    case forest
    case mono
    
    var title: String {
        switch self {
        case .paper: return "PAPER"
        case .mood: return "MOOD"
        case .night: return "NIGHT"
        case .forest: return "FOREST"
        case .mono: return "MONO"
        }
    }
}

final class CardShareViewController: UIViewController {
    private var book: Book
    private var selectedStyle: CardShareStyle = .paper
    
    private let maxReviewCharacterCount = 70
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let styleSegmentedControl = UISegmentedControl(items: CardShareStyle.allCases.map { $0.title })
    
    private let previewContainerView = UIView()
    private let cardPreviewView = ReadingCardPreviewView()
    
    private let reviewEditContainerView = UIView()
    private let reviewHeaderStackView = UIStackView()
    private let reviewEditTitleLabel = UILabel()
    private let reviewCountLabel = UILabel()
    private let reviewTextView = UITextView()
    
    private let shareButton = UIButton(type: .system)
    
    private let navyColor = UIColor(red: 0.02, green: 0.10, blue: 0.28, alpha: 1.0)
    private let backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 0.99, alpha: 1.0)
    
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
        view.backgroundColor = backgroundColor
        
        configureNavigation()
        configureUI()
        configureKeyboardDismiss()
        applyData()
    }
    
    private func configureNavigation() {
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 18)
        ]
        navigationController?.navigationBar.barTintColor = navyColor
        navigationController?.navigationBar.backgroundColor = navyColor
    }
    
    private func configureUI() {
        configureScrollView()
        configureHeader()
        configureStyleSegment()
        configurePreview()
        configureReviewEditor()
        configureShareButton()
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
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -28),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }
    
    private func configureHeader() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "나만의 독서 카드"
        titleLabel.font = .boldSystemFont(ofSize: 28)
        titleLabel.textColor = navyColor
        titleLabel.numberOfLines = 1
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "책 표지, 별점, 한줄평을 감성 카드로 만들어 공유해보세요."
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        subtitleLabel.textColor = UIColor(red: 0.48, green: 0.49, blue: 0.54, alpha: 1.0)
        subtitleLabel.numberOfLines = 0
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 22),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 22),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -22),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
    }
    
    private func configureStyleSegment() {
        styleSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        styleSegmentedControl.selectedSegmentIndex = selectedStyle.rawValue
        styleSegmentedControl.backgroundColor = UIColor(red: 0.88, green: 0.90, blue: 0.95, alpha: 1.0)
        styleSegmentedControl.selectedSegmentTintColor = navyColor
        
        styleSegmentedControl.setTitleTextAttributes(
            [
                .foregroundColor: UIColor(red: 0.48, green: 0.49, blue: 0.54, alpha: 1.0),
                .font: UIFont.systemFont(ofSize: 11, weight: .bold)
            ],
            for: .normal
        )
        
        styleSegmentedControl.setTitleTextAttributes(
            [
                .foregroundColor: UIColor.white,
                .font: UIFont.boldSystemFont(ofSize: 11)
            ],
            for: .selected
        )
        
        styleSegmentedControl.addTarget(self, action: #selector(styleChanged), for: .valueChanged)
        
        contentView.addSubview(styleSegmentedControl)
        
        NSLayoutConstraint.activate([
            styleSegmentedControl.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 18),
            styleSegmentedControl.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            styleSegmentedControl.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            styleSegmentedControl.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func configurePreview() {
        previewContainerView.translatesAutoresizingMaskIntoConstraints = false
        previewContainerView.backgroundColor = .white
        previewContainerView.layer.cornerRadius = 30
        previewContainerView.layer.shadowColor = UIColor.black.cgColor
        previewContainerView.layer.shadowOpacity = 0.08
        previewContainerView.layer.shadowRadius = 18
        previewContainerView.layer.shadowOffset = CGSize(width: 0, height: 10)
        
        cardPreviewView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(previewContainerView)
        previewContainerView.addSubview(cardPreviewView)
        
        NSLayoutConstraint.activate([
            previewContainerView.topAnchor.constraint(equalTo: styleSegmentedControl.bottomAnchor, constant: 22),
            previewContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 22),
            previewContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -22),
            
            cardPreviewView.topAnchor.constraint(equalTo: previewContainerView.topAnchor, constant: 16),
            cardPreviewView.leadingAnchor.constraint(equalTo: previewContainerView.leadingAnchor, constant: 16),
            cardPreviewView.trailingAnchor.constraint(equalTo: previewContainerView.trailingAnchor, constant: -16),
            cardPreviewView.bottomAnchor.constraint(equalTo: previewContainerView.bottomAnchor, constant: -16),
            cardPreviewView.heightAnchor.constraint(equalTo: cardPreviewView.widthAnchor, multiplier: 1.42)
        ])
    }
    
    private func configureReviewEditor() {
        reviewEditContainerView.translatesAutoresizingMaskIntoConstraints = false
        reviewEditContainerView.backgroundColor = .white
        reviewEditContainerView.layer.cornerRadius = 22
        
        reviewHeaderStackView.translatesAutoresizingMaskIntoConstraints = false
        reviewHeaderStackView.axis = .horizontal
        reviewHeaderStackView.alignment = .center
        reviewHeaderStackView.distribution = .fill
        reviewHeaderStackView.spacing = 10
        
        reviewEditTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        reviewEditTitleLabel.text = "카드 한줄평 수정"
        reviewEditTitleLabel.font = .boldSystemFont(ofSize: 17)
        reviewEditTitleLabel.textColor = navyColor
        
        reviewCountLabel.translatesAutoresizingMaskIntoConstraints = false
        reviewCountLabel.font = .systemFont(ofSize: 12, weight: .bold)
        reviewCountLabel.textAlignment = .right
        reviewCountLabel.setContentHuggingPriority(.required, for: .horizontal)
        reviewCountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        reviewHeaderStackView.addArrangedSubview(reviewEditTitleLabel)
        reviewHeaderStackView.addArrangedSubview(reviewCountLabel)
        
        reviewTextView.translatesAutoresizingMaskIntoConstraints = false
        reviewTextView.font = .systemFont(ofSize: 15, weight: .medium)
        reviewTextView.textColor = UIColor(red: 0.08, green: 0.09, blue: 0.12, alpha: 1.0)
        reviewTextView.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 0.99, alpha: 1.0)
        reviewTextView.layer.cornerRadius = 14
        reviewTextView.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        reviewTextView.delegate = self
        reviewTextView.keyboardDismissMode = .interactive
        
        contentView.addSubview(reviewEditContainerView)
        reviewEditContainerView.addSubview(reviewHeaderStackView)
        reviewEditContainerView.addSubview(reviewTextView)
        
        NSLayoutConstraint.activate([
            reviewEditContainerView.topAnchor.constraint(equalTo: previewContainerView.bottomAnchor, constant: 18),
            reviewEditContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 22),
            reviewEditContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -22),
            
            reviewHeaderStackView.topAnchor.constraint(equalTo: reviewEditContainerView.topAnchor, constant: 18),
            reviewHeaderStackView.leadingAnchor.constraint(equalTo: reviewEditContainerView.leadingAnchor, constant: 18),
            reviewHeaderStackView.trailingAnchor.constraint(equalTo: reviewEditContainerView.trailingAnchor, constant: -18),
            
            reviewTextView.topAnchor.constraint(equalTo: reviewHeaderStackView.bottomAnchor, constant: 12),
            reviewTextView.leadingAnchor.constraint(equalTo: reviewEditContainerView.leadingAnchor, constant: 18),
            reviewTextView.trailingAnchor.constraint(equalTo: reviewEditContainerView.trailingAnchor, constant: -18),
            reviewTextView.heightAnchor.constraint(equalToConstant: 108),
            reviewTextView.bottomAnchor.constraint(equalTo: reviewEditContainerView.bottomAnchor, constant: -18)
        ])
    }
    
    private func configureShareButton() {
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        
        var configuration = UIButton.Configuration.filled()
        configuration.title = "공유하기"
        configuration.image = UIImage(systemName: "square.and.arrow.up.fill")
        configuration.imagePadding = 8
        configuration.baseForegroundColor = .white
        configuration.baseBackgroundColor = navyColor
        configuration.cornerStyle = .large
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        
        shareButton.configuration = configuration
        shareButton.backgroundColor = navyColor
        shareButton.layer.cornerRadius = 16
        shareButton.clipsToBounds = true
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        
        contentView.addSubview(shareButton)
        
        NSLayoutConstraint.activate([
            shareButton.topAnchor.constraint(equalTo: reviewEditContainerView.bottomAnchor, constant: 18),
            shareButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 22),
            shareButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -22),
            shareButton.heightAnchor.constraint(equalToConstant: 52),
            shareButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -28)
        ])
    }
    
    private func applyData() {
        let reviewText = limitedReviewText(book.shortReviewText)
        reviewTextView.text = reviewText
        updateReviewCountLabel()
        updatePreviewFromEditor()
    }
    
    private func limitedReviewText(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return String(trimmed.prefix(maxReviewCharacterCount))
    }
    
    private func updateReviewCountLabel() {
        let count = reviewTextView.text.count
        reviewCountLabel.text = "\(count)/\(maxReviewCharacterCount)자"
        reviewCountLabel.textColor = count >= maxReviewCharacterCount
            ? .systemOrange
            : UIColor(red: 0.55, green: 0.56, blue: 0.62, alpha: 1.0)
    }
    
    private func updatePreviewFromEditor() {
        cardPreviewView.configure(
            book: book,
            review: reviewTextView.text ?? "",
            style: selectedStyle
        )
    }
    
    private func makeCardImage() -> UIImage {
        dismissKeyboard()
        cardPreviewView.layoutIfNeeded()
        return cardPreviewView.makeShareImage()
    }
    
    @objc private func styleChanged() {
        selectedStyle = CardShareStyle(rawValue: styleSegmentedControl.selectedSegmentIndex) ?? .paper
        updatePreviewFromEditor()
    }
    
    @objc private func shareButtonTapped() {
        let image = makeCardImage()
        
        let instagramStoryActivity = InstagramStoryActivity(
            presenter: self,
            image: image
        )
        
        let saveImageActivity = SaveImageActivity(
            presenter: self,
            image: image
        )
        
        let activityVC = UIActivityViewController(
            activityItems: [image],
            applicationActivities: [
                instagramStoryActivity,
                saveImageActivity
            ]
        )
        
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = shareButton
            popover.sourceRect = shareButton.bounds
        }
        
        present(activityVC, animated: true)
    }
}

extension CardShareViewController: UITextViewDelegate, UIGestureRecognizerDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count > maxReviewCharacterCount {
            textView.text = String(textView.text.prefix(maxReviewCharacterCount))
        }
        
        updateReviewCountLabel()
        updatePreviewFromEditor()
    }
    
    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        guard let currentText = textView.text,
              let textRange = Range(range, in: currentText) else {
            return true
        }
        
        let updatedText = currentText.replacingCharacters(in: textRange, with: text)
        
        if updatedText.count <= maxReviewCharacterCount {
            return true
        }
        
        textView.text = String(updatedText.prefix(maxReviewCharacterCount))
        updateReviewCountLabel()
        updatePreviewFromEditor()
        
        return false
    }
    
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

final class InstagramStoryActivity: UIActivity {
    private weak var presenter: UIViewController?
    private let image: UIImage
    
    init(presenter: UIViewController, image: UIImage) {
        self.presenter = presenter
        self.image = image
        super.init()
    }
    
    override var activityTitle: String? {
        return "인스타 스토리"
    }
    
    override var activityImage: UIImage? {
        return UIImage(systemName: "camera.fill")
    }
    
    override var activityType: UIActivity.ActivityType? {
        return UIActivity.ActivityType("com.bookly.instagramStory")
    }
    
    override class var activityCategory: UIActivity.Category {
        return .share
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        guard let instagramURL = URL(string: "instagram-stories://share") else {
            return false
        }
        return UIApplication.shared.canOpenURL(instagramURL)
    }
    
    override func perform() {
        guard let imageData = image.pngData(),
              let instagramURL = URL(string: "instagram-stories://share"),
              UIApplication.shared.canOpenURL(instagramURL) else {
            activityDidFinish(false)
            showInstagramNotInstalledAlert()
            return
        }
        
        let pasteboardItems: [[String: Any]] = [
            [
                "com.instagram.sharedSticker.backgroundImage": imageData
            ]
        ]
        
        let pasteboardOptions: [UIPasteboard.OptionsKey: Any] = [
            .expirationDate: Date().addingTimeInterval(60 * 5)
        ]
        
        UIPasteboard.general.setItems(pasteboardItems, options: pasteboardOptions)
        UIApplication.shared.open(instagramURL)
        activityDidFinish(true)
    }
    
    private func showInstagramNotInstalledAlert() {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(
                title: "인스타그램을 열 수 없어요",
                message: "인스타그램 앱이 설치되어 있는지 확인해주세요.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            self?.presenter?.present(alert, animated: true)
        }
    }
}

final class SaveImageActivity: UIActivity {
    private weak var presenter: UIViewController?
    private let image: UIImage
    
    init(presenter: UIViewController, image: UIImage) {
        self.presenter = presenter
        self.image = image
        super.init()
    }
    
    override var activityTitle: String? {
        return "이미지 저장"
    }
    
    override var activityImage: UIImage? {
        return UIImage(systemName: "square.and.arrow.down.fill")
    }
    
    override var activityType: UIActivity.ActivityType? {
        return UIActivity.ActivityType("com.bookly.saveImage")
    }
    
    override class var activityCategory: UIActivity.Category {
        return .action
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    override func perform() {
        UIImageWriteToSavedPhotosAlbum(
            image,
            self,
            #selector(imageSaveCompleted(_:didFinishSavingWithError:contextInfo:)),
            nil
        )
    }
    
    @objc private func imageSaveCompleted(
        _ image: UIImage,
        didFinishSavingWithError error: Error?,
        contextInfo: UnsafeRawPointer
    ) {
        if let error {
            activityDidFinish(false)
            showAlert(title: "저장 실패", message: error.localizedDescription)
        } else {
            activityDidFinish(true)
            showAlert(title: "저장 완료", message: "독서 카드 이미지가 사진 앱에 저장되었어요.")
        }
    }
    
    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            self?.presenter?.present(alert, animated: true)
        }
    }
}

private final class ReadingCardPreviewView: UIView {
    private let outerCardView = UIView()
    private let backgroundGradientLayer = CAGradientLayer()
    private let innerCardView = UIView()
    
    private let decoCircleView = UIView()
    private let decoSmallCircleView = UIView()
    
    private let booklyLabel = UILabel()
    private let brandSubtitleLabel = UILabel()
    
    private let bookInfoContainerView = UIView()
    private let coverImageView = UIImageView()
    private let infoStackView = UIStackView()
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let ratingLabel = UILabel()
    
    private let reviewContainerView = UIView()
    private let leftQuoteImageView = UIImageView()
    private let reviewLabel = UILabel()
    private let rightQuoteImageView = UIImageView()
    
    private let periodLabel = UILabel()
    
    private var outerCardHeightConstraint: NSLayoutConstraint?
    private var innerCardHeightConstraint: NSLayoutConstraint?
    private var reviewContainerHeightConstraint: NSLayoutConstraint?
    private var reviewContainerWidthConstraint: NSLayoutConstraint?
    private var reviewTopConstraint: NSLayoutConstraint?
    
    private let navyColor = UIColor(red: 0.02, green: 0.10, blue: 0.28, alpha: 1.0)
    private let inkColor = UIColor(red: 0.13, green: 0.12, blue: 0.10, alpha: 1.0)
    private let mutedGray = UIColor(red: 0.50, green: 0.52, blue: 0.58, alpha: 1.0)
    private let placeholderColor = UIColor(red: 0.67, green: 0.68, blue: 0.72, alpha: 1.0)
    
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
        backgroundGradientLayer.frame = outerCardView.bounds
    }
    
    func configure(book: Book, review: String, style: CardShareStyle) {
        coverImageView.setImage(from: book.thumbnail)
        titleLabel.text = book.title
        authorLabel.text = book.authorText
        ratingLabel.text = makeRatingText(book.displayRating)
        periodLabel.text = makeReadingPeriodText(book)
        
        let trimmedReview = review.trimmingCharacters(in: .whitespacesAndNewlines)
        let isPlaceholder = trimmedReview.isEmpty
        
        reviewLabel.text = isPlaceholder ? "한줄평을 입력해보세요" : trimmedReview
        reviewLabel.font = isPlaceholder
            ? .systemFont(ofSize: 14, weight: .semibold)
            : .systemFont(ofSize: 14, weight: .bold)
        
        updateCardMetrics(for: reviewLabel.text ?? "")
        adjustTextSizing(title: book.title, author: book.authorText)
        applyStyle(style, isPlaceholder: isPlaceholder)
        
        UIView.performWithoutAnimation {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
    func makeShareImage() -> UIImage {
        layoutIfNeeded()
        
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        return renderer.image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
    }
    
    private func configureUI() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        clipsToBounds = false
        
        outerCardView.translatesAutoresizingMaskIntoConstraints = false
        outerCardView.layer.cornerRadius = 28
        outerCardView.clipsToBounds = true
        
        backgroundGradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        backgroundGradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        outerCardView.layer.insertSublayer(backgroundGradientLayer, at: 0)
        
        decoCircleView.translatesAutoresizingMaskIntoConstraints = false
        decoCircleView.layer.cornerRadius = 76
        decoCircleView.clipsToBounds = true
        
        decoSmallCircleView.translatesAutoresizingMaskIntoConstraints = false
        decoSmallCircleView.layer.cornerRadius = 36
        decoSmallCircleView.clipsToBounds = true
        
        innerCardView.translatesAutoresizingMaskIntoConstraints = false
        innerCardView.layer.cornerRadius = 28
        innerCardView.clipsToBounds = false
        
        booklyLabel.translatesAutoresizingMaskIntoConstraints = false
        booklyLabel.text = "Bookly"
        booklyLabel.font = UIFont(name: "Georgia-BoldItalic", size: 28) ?? .italicSystemFont(ofSize: 28)
        booklyLabel.numberOfLines = 1
        
        brandSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        brandSubtitleLabel.text = "기록할수록 나의 독서가 완성된다 ✦"
        brandSubtitleLabel.font = .systemFont(ofSize: 10, weight: .semibold)
        brandSubtitleLabel.numberOfLines = 1
        brandSubtitleLabel.adjustsFontSizeToFitWidth = true
        brandSubtitleLabel.minimumScaleFactor = 0.78
        
        bookInfoContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        coverImageView.layer.cornerRadius = 15
        coverImageView.backgroundColor = UIColor(red: 0.94, green: 0.95, blue: 0.98, alpha: 1.0)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 20, weight: .heavy)
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.68
        
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        authorLabel.numberOfLines = 0
        authorLabel.lineBreakMode = .byWordWrapping
        authorLabel.adjustsFontSizeToFitWidth = true
        authorLabel.minimumScaleFactor = 0.70
        
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.font = .systemFont(ofSize: 13, weight: .heavy)
        ratingLabel.numberOfLines = 1
        ratingLabel.adjustsFontSizeToFitWidth = true
        ratingLabel.minimumScaleFactor = 0.75
        
        infoStackView.translatesAutoresizingMaskIntoConstraints = false
        infoStackView.axis = .vertical
        infoStackView.alignment = .fill
        infoStackView.distribution = .fill
        infoStackView.spacing = 7
        infoStackView.addArrangedSubview(titleLabel)
        infoStackView.addArrangedSubview(authorLabel)
        infoStackView.addArrangedSubview(ratingLabel)
        
        reviewContainerView.translatesAutoresizingMaskIntoConstraints = false
        reviewContainerView.clipsToBounds = false
        
        leftQuoteImageView.translatesAutoresizingMaskIntoConstraints = false
        leftQuoteImageView.image = UIImage(systemName: "quote.opening")?.withRenderingMode(.alwaysTemplate)
        leftQuoteImageView.contentMode = .scaleAspectFit
        leftQuoteImageView.alpha = 0.62
        
        rightQuoteImageView.translatesAutoresizingMaskIntoConstraints = false
        rightQuoteImageView.image = UIImage(systemName: "quote.closing")?.withRenderingMode(.alwaysTemplate)
        rightQuoteImageView.contentMode = .scaleAspectFit
        rightQuoteImageView.alpha = 0.62
        
        reviewLabel.translatesAutoresizingMaskIntoConstraints = false
        reviewLabel.numberOfLines = 0
        reviewLabel.lineBreakMode = .byCharWrapping
        reviewLabel.textAlignment = .center
        reviewLabel.clipsToBounds = false
        
        periodLabel.translatesAutoresizingMaskIntoConstraints = false
        periodLabel.font = .systemFont(ofSize: 10, weight: .bold)
        periodLabel.numberOfLines = 1
        periodLabel.textAlignment = .right
        periodLabel.adjustsFontSizeToFitWidth = true
        periodLabel.minimumScaleFactor = 0.70
        
        addSubview(outerCardView)
        
        outerCardView.addSubview(decoCircleView)
        outerCardView.addSubview(decoSmallCircleView)
        outerCardView.addSubview(innerCardView)
        
        innerCardView.addSubview(booklyLabel)
        innerCardView.addSubview(brandSubtitleLabel)
        innerCardView.addSubview(bookInfoContainerView)
        innerCardView.addSubview(reviewContainerView)
        innerCardView.addSubview(periodLabel)
        
        bookInfoContainerView.addSubview(coverImageView)
        bookInfoContainerView.addSubview(infoStackView)
        
        reviewContainerView.addSubview(leftQuoteImageView)
        reviewContainerView.addSubview(reviewLabel)
        reviewContainerView.addSubview(rightQuoteImageView)
        
        outerCardHeightConstraint = outerCardView.heightAnchor.constraint(equalToConstant: 384)
        innerCardHeightConstraint = innerCardView.heightAnchor.constraint(equalToConstant: 336)
        reviewContainerHeightConstraint = reviewContainerView.heightAnchor.constraint(equalToConstant: 42)
        reviewContainerWidthConstraint = reviewContainerView.widthAnchor.constraint(equalToConstant: 178)
        reviewTopConstraint = reviewContainerView.topAnchor.constraint(equalTo: bookInfoContainerView.bottomAnchor, constant: 12)
        
        outerCardHeightConstraint?.isActive = true
        innerCardHeightConstraint?.isActive = true
        reviewContainerHeightConstraint?.isActive = true
        reviewContainerWidthConstraint?.isActive = true
        reviewTopConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            outerCardView.centerXAnchor.constraint(equalTo: centerXAnchor),
            outerCardView.centerYAnchor.constraint(equalTo: centerYAnchor),
            outerCardView.widthAnchor.constraint(equalTo: widthAnchor),
            
            decoCircleView.widthAnchor.constraint(equalToConstant: 152),
            decoCircleView.heightAnchor.constraint(equalToConstant: 152),
            decoCircleView.topAnchor.constraint(equalTo: outerCardView.topAnchor, constant: -46),
            decoCircleView.trailingAnchor.constraint(equalTo: outerCardView.trailingAnchor, constant: 42),
            
            decoSmallCircleView.widthAnchor.constraint(equalToConstant: 72),
            decoSmallCircleView.heightAnchor.constraint(equalToConstant: 72),
            decoSmallCircleView.leadingAnchor.constraint(equalTo: outerCardView.leadingAnchor, constant: -22),
            decoSmallCircleView.bottomAnchor.constraint(equalTo: outerCardView.bottomAnchor, constant: 18),
            
            innerCardView.topAnchor.constraint(equalTo: outerCardView.topAnchor, constant: 24),
            innerCardView.leadingAnchor.constraint(equalTo: outerCardView.leadingAnchor, constant: 24),
            innerCardView.trailingAnchor.constraint(equalTo: outerCardView.trailingAnchor, constant: -24),
            
            booklyLabel.topAnchor.constraint(equalTo: innerCardView.topAnchor, constant: 24),
            booklyLabel.leadingAnchor.constraint(equalTo: innerCardView.leadingAnchor, constant: 22),
            booklyLabel.trailingAnchor.constraint(equalTo: innerCardView.trailingAnchor, constant: -22),
            booklyLabel.heightAnchor.constraint(equalToConstant: 34),
            
            brandSubtitleLabel.topAnchor.constraint(equalTo: booklyLabel.bottomAnchor, constant: 1),
            brandSubtitleLabel.leadingAnchor.constraint(equalTo: booklyLabel.leadingAnchor),
            brandSubtitleLabel.trailingAnchor.constraint(equalTo: booklyLabel.trailingAnchor),
            brandSubtitleLabel.heightAnchor.constraint(equalToConstant: 15),
            
            bookInfoContainerView.topAnchor.constraint(equalTo: brandSubtitleLabel.bottomAnchor, constant: 18),
            bookInfoContainerView.leadingAnchor.constraint(equalTo: innerCardView.leadingAnchor, constant: 22),
            bookInfoContainerView.trailingAnchor.constraint(equalTo: innerCardView.trailingAnchor, constant: -22),
            bookInfoContainerView.heightAnchor.constraint(equalToConstant: 150),
            
            coverImageView.leadingAnchor.constraint(equalTo: bookInfoContainerView.leadingAnchor),
            coverImageView.topAnchor.constraint(equalTo: bookInfoContainerView.topAnchor),
            coverImageView.bottomAnchor.constraint(equalTo: bookInfoContainerView.bottomAnchor),
            coverImageView.widthAnchor.constraint(equalToConstant: 104),
            
            infoStackView.topAnchor.constraint(equalTo: bookInfoContainerView.topAnchor),
            infoStackView.leadingAnchor.constraint(equalTo: coverImageView.trailingAnchor, constant: 16),
            infoStackView.trailingAnchor.constraint(equalTo: bookInfoContainerView.trailingAnchor),
            infoStackView.bottomAnchor.constraint(lessThanOrEqualTo: bookInfoContainerView.bottomAnchor),
            
            reviewContainerView.centerXAnchor.constraint(equalTo: innerCardView.centerXAnchor),
            reviewContainerView.leadingAnchor.constraint(greaterThanOrEqualTo: innerCardView.leadingAnchor, constant: 22),
            reviewContainerView.trailingAnchor.constraint(lessThanOrEqualTo: innerCardView.trailingAnchor, constant: -22),
            
            leftQuoteImageView.leadingAnchor.constraint(equalTo: reviewContainerView.leadingAnchor),
            leftQuoteImageView.topAnchor.constraint(equalTo: reviewContainerView.topAnchor, constant: 2),
            leftQuoteImageView.widthAnchor.constraint(equalToConstant: 20),
            leftQuoteImageView.heightAnchor.constraint(equalToConstant: 20),
            
            rightQuoteImageView.trailingAnchor.constraint(equalTo: reviewContainerView.trailingAnchor),
            rightQuoteImageView.bottomAnchor.constraint(equalTo: reviewContainerView.bottomAnchor, constant: -2),
            rightQuoteImageView.widthAnchor.constraint(equalToConstant: 20),
            rightQuoteImageView.heightAnchor.constraint(equalToConstant: 20),
            
            reviewLabel.topAnchor.constraint(equalTo: reviewContainerView.topAnchor, constant: 4),
            reviewLabel.leadingAnchor.constraint(equalTo: leftQuoteImageView.trailingAnchor, constant: 8),
            reviewLabel.trailingAnchor.constraint(equalTo: rightQuoteImageView.leadingAnchor, constant: -8),
            reviewLabel.bottomAnchor.constraint(equalTo: reviewContainerView.bottomAnchor, constant: -4),
            
            periodLabel.topAnchor.constraint(equalTo: reviewContainerView.bottomAnchor, constant: 8),
            periodLabel.trailingAnchor.constraint(equalTo: innerCardView.trailingAnchor, constant: -22),
            periodLabel.leadingAnchor.constraint(greaterThanOrEqualTo: innerCardView.leadingAnchor, constant: 22),
            periodLabel.heightAnchor.constraint(equalToConstant: 15)
        ])
        
        applyStyle(.paper, isPlaceholder: true)
    }
    
    private func updateCardMetrics(for text: String) {
        let count = text.count
        
        let reviewWidth: CGFloat
        let reviewHeight: CGFloat
        let reviewTop: CGFloat
        let innerHeight: CGFloat
        let outerHeight: CGFloat
        
        switch count {
        case 0...10:
            reviewWidth = 178
            reviewHeight = 42
            reviewTop = 12
            innerHeight = 336
            outerHeight = 384
            
        case 11...24:
            reviewWidth = 232
            reviewHeight = 54
            reviewTop = 12
            innerHeight = 350
            outerHeight = 398
            
        case 25...42:
            reviewWidth = 286
            reviewHeight = 76
            reviewTop = 10
            innerHeight = 372
            outerHeight = 420
            
        case 43...56:
            reviewWidth = 306
            reviewHeight = 98
            reviewTop = 8
            innerHeight = 392
            outerHeight = 440
            
        default:
            reviewWidth = 316
            reviewHeight = 122
            reviewTop = 6
            innerHeight = 416
            outerHeight = 464
        }
        
        reviewContainerWidthConstraint?.constant = reviewWidth
        reviewContainerHeightConstraint?.constant = reviewHeight
        reviewTopConstraint?.constant = reviewTop
        innerCardHeightConstraint?.constant = innerHeight
        outerCardHeightConstraint?.constant = outerHeight
    }
    
    private func applyStyle(_ style: CardShareStyle, isPlaceholder: Bool) {
        switch style {
        case .paper:
            backgroundGradientLayer.colors = [
                UIColor(red: 0.94, green: 0.86, blue: 0.73, alpha: 1.0).cgColor,
                UIColor(red: 0.86, green: 0.91, blue: 0.87, alpha: 1.0).cgColor
            ]
            innerCardView.backgroundColor = UIColor(red: 1.00, green: 0.96, blue: 0.87, alpha: 0.97)
            booklyLabel.textColor = UIColor(red: 0.37, green: 0.25, blue: 0.16, alpha: 1.0)
            brandSubtitleLabel.textColor = UIColor(red: 0.55, green: 0.42, blue: 0.30, alpha: 1.0)
            titleLabel.textColor = UIColor(red: 0.28, green: 0.19, blue: 0.12, alpha: 1.0)
            authorLabel.textColor = UIColor(red: 0.50, green: 0.39, blue: 0.30, alpha: 1.0)
            ratingLabel.textColor = UIColor(red: 0.84, green: 0.36, blue: 0.10, alpha: 1.0)
            leftQuoteImageView.tintColor = UIColor(red: 0.78, green: 0.43, blue: 0.24, alpha: 0.55)
            rightQuoteImageView.tintColor = UIColor(red: 0.78, green: 0.43, blue: 0.24, alpha: 0.55)
            reviewLabel.textColor = isPlaceholder ? placeholderColor : UIColor(red: 0.28, green: 0.20, blue: 0.14, alpha: 1.0)
            periodLabel.textColor = UIColor(red: 0.55, green: 0.42, blue: 0.30, alpha: 0.76)
            decoCircleView.backgroundColor = UIColor.white.withAlphaComponent(0.28)
            decoSmallCircleView.backgroundColor = UIColor.white.withAlphaComponent(0.18)
            
        case .mood:
            backgroundGradientLayer.colors = [
                UIColor(red: 0.88, green: 0.77, blue: 0.92, alpha: 1.0).cgColor,
                UIColor(red: 0.97, green: 0.82, blue: 0.76, alpha: 1.0).cgColor
            ]
            innerCardView.backgroundColor = UIColor(red: 1.00, green: 0.94, blue: 0.94, alpha: 0.96)
            booklyLabel.textColor = UIColor(red: 0.33, green: 0.21, blue: 0.43, alpha: 1.0)
            brandSubtitleLabel.textColor = UIColor(red: 0.61, green: 0.42, blue: 0.62, alpha: 1.0)
            titleLabel.textColor = UIColor(red: 0.30, green: 0.20, blue: 0.40, alpha: 1.0)
            authorLabel.textColor = UIColor(red: 0.58, green: 0.43, blue: 0.58, alpha: 1.0)
            ratingLabel.textColor = UIColor(red: 0.88, green: 0.40, blue: 0.24, alpha: 1.0)
            leftQuoteImageView.tintColor = UIColor(red: 0.65, green: 0.43, blue: 0.72, alpha: 0.50)
            rightQuoteImageView.tintColor = UIColor(red: 0.65, green: 0.43, blue: 0.72, alpha: 0.50)
            reviewLabel.textColor = isPlaceholder ? placeholderColor : UIColor(red: 0.31, green: 0.23, blue: 0.36, alpha: 1.0)
            periodLabel.textColor = UIColor(red: 0.58, green: 0.43, blue: 0.58, alpha: 0.76)
            decoCircleView.backgroundColor = UIColor.white.withAlphaComponent(0.28)
            decoSmallCircleView.backgroundColor = UIColor.white.withAlphaComponent(0.18)
            
        case .night:
            backgroundGradientLayer.colors = [
                UIColor(red: 0.02, green: 0.10, blue: 0.28, alpha: 1.0).cgColor,
                UIColor(red: 0.10, green: 0.18, blue: 0.40, alpha: 1.0).cgColor
            ]
            innerCardView.backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 1.0, alpha: 0.96)
            booklyLabel.textColor = navyColor
            brandSubtitleLabel.textColor = UIColor(red: 0.48, green: 0.52, blue: 0.64, alpha: 1.0)
            titleLabel.textColor = navyColor
            authorLabel.textColor = mutedGray
            ratingLabel.textColor = .systemOrange
            leftQuoteImageView.tintColor = navyColor.withAlphaComponent(0.42)
            rightQuoteImageView.tintColor = navyColor.withAlphaComponent(0.42)
            reviewLabel.textColor = isPlaceholder ? placeholderColor : navyColor
            periodLabel.textColor = UIColor(red: 0.48, green: 0.52, blue: 0.64, alpha: 0.78)
            decoCircleView.backgroundColor = UIColor.white.withAlphaComponent(0.18)
            decoSmallCircleView.backgroundColor = UIColor.white.withAlphaComponent(0.10)
            
        case .forest:
            backgroundGradientLayer.colors = [
                UIColor(red: 0.67, green: 0.77, blue: 0.65, alpha: 1.0).cgColor,
                UIColor(red: 0.91, green: 0.86, blue: 0.73, alpha: 1.0).cgColor
            ]
            innerCardView.backgroundColor = UIColor(red: 0.96, green: 0.95, blue: 0.87, alpha: 0.96)
            booklyLabel.textColor = UIColor(red: 0.17, green: 0.32, blue: 0.22, alpha: 1.0)
            brandSubtitleLabel.textColor = UIColor(red: 0.42, green: 0.52, blue: 0.36, alpha: 1.0)
            titleLabel.textColor = UIColor(red: 0.17, green: 0.30, blue: 0.20, alpha: 1.0)
            authorLabel.textColor = UIColor(red: 0.41, green: 0.49, blue: 0.35, alpha: 1.0)
            ratingLabel.textColor = UIColor(red: 0.73, green: 0.39, blue: 0.14, alpha: 1.0)
            leftQuoteImageView.tintColor = UIColor(red: 0.36, green: 0.53, blue: 0.33, alpha: 0.50)
            rightQuoteImageView.tintColor = UIColor(red: 0.36, green: 0.53, blue: 0.33, alpha: 0.50)
            reviewLabel.textColor = isPlaceholder ? placeholderColor : UIColor(red: 0.17, green: 0.30, blue: 0.20, alpha: 1.0)
            periodLabel.textColor = UIColor(red: 0.42, green: 0.52, blue: 0.36, alpha: 0.78)
            decoCircleView.backgroundColor = UIColor.white.withAlphaComponent(0.24)
            decoSmallCircleView.backgroundColor = UIColor.white.withAlphaComponent(0.16)
            
        case .mono:
            backgroundGradientLayer.colors = [
                UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1.0).cgColor,
                UIColor(red: 0.99, green: 0.99, blue: 1.0, alpha: 1.0).cgColor
            ]
            innerCardView.backgroundColor = .white
            booklyLabel.textColor = UIColor(red: 0.10, green: 0.11, blue: 0.13, alpha: 1.0)
            brandSubtitleLabel.textColor = mutedGray
            titleLabel.textColor = UIColor(red: 0.10, green: 0.11, blue: 0.13, alpha: 1.0)
            authorLabel.textColor = mutedGray
            ratingLabel.textColor = .systemOrange
            leftQuoteImageView.tintColor = UIColor.black.withAlphaComponent(0.28)
            rightQuoteImageView.tintColor = UIColor.black.withAlphaComponent(0.28)
            reviewLabel.textColor = isPlaceholder ? placeholderColor : inkColor
            periodLabel.textColor = mutedGray
            decoCircleView.backgroundColor = UIColor.black.withAlphaComponent(0.04)
            decoSmallCircleView.backgroundColor = UIColor.black.withAlphaComponent(0.03)
        }
    }
    
    private func adjustTextSizing(title: String, author: String) {
        if title.count > 54 {
            titleLabel.font = .systemFont(ofSize: 13, weight: .heavy)
        } else if title.count > 42 {
            titleLabel.font = .systemFont(ofSize: 14, weight: .heavy)
        } else if title.count > 32 {
            titleLabel.font = .systemFont(ofSize: 16, weight: .heavy)
        } else if title.count > 22 {
            titleLabel.font = .systemFont(ofSize: 18, weight: .heavy)
        } else {
            titleLabel.font = .systemFont(ofSize: 20, weight: .heavy)
        }
        
        if author.count > 34 {
            authorLabel.font = .systemFont(ofSize: 10, weight: .semibold)
        } else if author.count > 24 {
            authorLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        } else {
            authorLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        }
    }
    
    private func makeRatingText(_ rating: Double) -> String {
        if rating <= 0 {
            return "별점 없음"
        }
        
        return "★ \(String(format: "%.1f", rating)) / 5.0"
    }
    
    private func makeReadingPeriodText(_ book: Book) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM.dd"
        
        guard let startDate = book.readingStartedAt else {
            return "독서 기간을 기록해보세요"
        }
        
        let endDate = book.readingFinishedAt ?? Date()
        return "\(formatter.string(from: startDate)) ~ \(formatter.string(from: endDate))"
    }
}
