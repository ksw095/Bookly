import UIKit

final class BookCollectionViewCell: UICollectionViewCell {
    static let identifier = "BookCollectionViewCell"
    
    private let thumbnailImageView = UIImageView()
    
    private let dayBadgeView = UIView()
    private let dayBadgeIconImageView = UIImageView()
    private let dayBadgeLabel = UILabel()
    
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .default)
    private let progressLabel = UILabel()
    
    private let navyColor = UIColor(red: 0.02, green: 0.12, blue: 0.36, alpha: 1.0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
        
        dayBadgeView.isHidden = true
        dayBadgeLabel.text = nil
        
        progressView.isHidden = true
        progressLabel.isHidden = true
        progressView.progress = 0
    }
    
    func configureToday(with document: KakaoBookDocument) {
        thumbnailImageView.setImage(from: document.thumbnail)
        titleLabel.text = document.title.removingHTMLTags()
        
        if document.authors.isEmpty {
            authorLabel.text = "저자 정보 없음"
        } else {
            authorLabel.text = document.authors.joined(separator: ", ")
        }
        
        dayBadgeView.isHidden = true
        progressView.isHidden = true
        progressLabel.isHidden = true
    }
    
    func configureReading(with book: Book) {
        thumbnailImageView.setImage(from: book.thumbnail)
        titleLabel.text = book.title
        authorLabel.text = book.authorText
        
        dayBadgeLabel.text = book.readingDaysText
        dayBadgeView.isHidden = false
        
        let progress = Float(book.progressValue / 100.0)
        progressView.progress = progress
        progressView.isHidden = false
        
        progressLabel.text = "\(Int(book.progressValue))%"
        progressLabel.isHidden = false
    }
    
    func configure(with book: Book) {
        configureReading(with: book)
    }
    
    private func configureUI() {
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = false
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.08
        contentView.layer.shadowRadius = 5
        contentView.layer.shadowOffset = CGSize(width: 0, height: 3)
        
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView.layer.cornerRadius = 10
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.contentMode = .scaleAspectFit
        thumbnailImageView.backgroundColor = .secondarySystemBackground
        
        dayBadgeView.translatesAutoresizingMaskIntoConstraints = false
        dayBadgeView.backgroundColor = .white
        dayBadgeView.layer.cornerRadius = 11
        dayBadgeView.layer.borderWidth = 0.5
        dayBadgeView.layer.borderColor = UIColor.systemGray5.cgColor
        dayBadgeView.clipsToBounds = true
        dayBadgeView.isHidden = true
        
        dayBadgeIconImageView.translatesAutoresizingMaskIntoConstraints = false
        dayBadgeIconImageView.image = UIImage(systemName: "book.closed.fill")
        dayBadgeIconImageView.tintColor = navyColor
        dayBadgeIconImageView.contentMode = .scaleAspectFit
        
        dayBadgeLabel.translatesAutoresizingMaskIntoConstraints = false
        dayBadgeLabel.font = .boldSystemFont(ofSize: 10)
        dayBadgeLabel.textColor = .black
        dayBadgeLabel.textAlignment = .left
        dayBadgeLabel.setContentHuggingPriority(.required, for: .horizontal)
        dayBadgeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        titleLabel.font = .boldSystemFont(ofSize: 13)
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        authorLabel.font = .systemFont(ofSize: 11)
        authorLabel.textColor = .secondaryLabel
        authorLabel.numberOfLines = 1
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = navyColor
        progressView.trackTintColor = .systemGray5
        progressView.isHidden = true
        
        progressLabel.font = .boldSystemFont(ofSize: 11)
        progressLabel.textColor = navyColor
        progressLabel.textAlignment = .right
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.isHidden = true
        
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(dayBadgeView)
        dayBadgeView.addSubview(dayBadgeIconImageView)
        dayBadgeView.addSubview(dayBadgeLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(authorLabel)
        contentView.addSubview(progressView)
        contentView.addSubview(progressLabel)
        
        NSLayoutConstraint.activate([
            thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            thumbnailImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 82),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 116),
            
            dayBadgeView.topAnchor.constraint(equalTo: thumbnailImageView.topAnchor, constant: 6),
            dayBadgeView.leadingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor, constant: 6),
            dayBadgeView.heightAnchor.constraint(equalToConstant: 22),
            
            dayBadgeIconImageView.leadingAnchor.constraint(equalTo: dayBadgeView.leadingAnchor, constant: 7),
            dayBadgeIconImageView.centerYAnchor.constraint(equalTo: dayBadgeView.centerYAnchor),
            dayBadgeIconImageView.widthAnchor.constraint(equalToConstant: 11),
            dayBadgeIconImageView.heightAnchor.constraint(equalToConstant: 11),
            
            dayBadgeLabel.leadingAnchor.constraint(equalTo: dayBadgeIconImageView.trailingAnchor, constant: 4),
            dayBadgeLabel.trailingAnchor.constraint(equalTo: dayBadgeView.trailingAnchor, constant: -8),
            dayBadgeLabel.centerYAnchor.constraint(equalTo: dayBadgeView.centerYAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            progressView.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 8),
            progressView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            progressView.trailingAnchor.constraint(equalTo: progressLabel.leadingAnchor, constant: -6),
            
            progressLabel.centerYAnchor.constraint(equalTo: progressView.centerYAnchor),
            progressLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            progressLabel.widthAnchor.constraint(equalToConstant: 34)
        ])
    }
}
