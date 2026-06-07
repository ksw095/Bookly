import UIKit

final class BookTableViewCell: UITableViewCell {
    static let identifier = "BookTableViewCell"
    
    private let thumbnailImageView = UIImageView()
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let publisherLabel = UILabel()
    private let statusLabel = UILabel()
    private let ratingLabel = UILabel()
    private let priceLabel = UILabel()
    private let memoLabel = UILabel()
    
    private let textStackView = UIStackView()
    private let bottomStackView = UIStackView()
    private let mainStackView = UIStackView()
    
    private let navyColor = UIColor(red: 0.02, green: 0.12, blue: 0.36, alpha: 1.0)
    
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
        memoLabel.text = nil
        memoLabel.isHidden = true
        statusLabel.isHidden = false
        ratingLabel.isHidden = false
        priceLabel.isHidden = true
        accessoryType = .none
    }
    
    func configure(with book: Book) {
        thumbnailImageView.setImage(from: book.thumbnail)
        titleLabel.text = book.title
        authorLabel.text = book.authorText
        publisherLabel.text = book.publisher.isEmpty ? "출판사 정보 없음" : book.publisher
        
        statusLabel.text = book.status.rawValue
        statusLabel.isHidden = false
        
        ratingLabel.text = book.rating > 0 ? "★ \(book.rating)" : "평점 없음"
        ratingLabel.isHidden = false
        
        priceLabel.isHidden = true
        
        if book.memo.isEmpty {
            memoLabel.isHidden = true
        } else {
            memoLabel.isHidden = false
            memoLabel.text = "“\(book.memo)”"
        }
        
        accessoryType = .disclosureIndicator
    }
    
    func configureSearchResult(with document: KakaoBookDocument) {
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
        
        statusLabel.isHidden = true
        ratingLabel.isHidden = true
        memoLabel.isHidden = true
        
        priceLabel.text = formattedPrice(from: document)
        priceLabel.isHidden = false
        
        accessoryType = .disclosureIndicator
    }
    
    private func configureUI() {
        selectionStyle = .default
        
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView.layer.cornerRadius = 8
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.contentMode = .scaleAspectFit
        thumbnailImageView.backgroundColor = .secondarySystemBackground
        
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.numberOfLines = 2
        
        authorLabel.font = .systemFont(ofSize: 13)
        authorLabel.textColor = .secondaryLabel
        authorLabel.numberOfLines = 1
        
        publisherLabel.font = .systemFont(ofSize: 12)
        publisherLabel.textColor = .secondaryLabel
        publisherLabel.numberOfLines = 1
        
        statusLabel.font = .boldSystemFont(ofSize: 12)
        statusLabel.textColor = .systemIndigo
        
        ratingLabel.font = .systemFont(ofSize: 12)
        ratingLabel.textColor = .systemOrange
        
        priceLabel.font = .boldSystemFont(ofSize: 13)
        priceLabel.textColor = navyColor
        priceLabel.numberOfLines = 1
        
        memoLabel.font = .systemFont(ofSize: 13)
        memoLabel.textColor = .secondaryLabel
        memoLabel.numberOfLines = 2
        
        bottomStackView.axis = .horizontal
        bottomStackView.spacing = 8
        bottomStackView.addArrangedSubview(statusLabel)
        bottomStackView.addArrangedSubview(ratingLabel)
        bottomStackView.addArrangedSubview(priceLabel)
        
        textStackView.axis = .vertical
        textStackView.spacing = 5
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(authorLabel)
        textStackView.addArrangedSubview(publisherLabel)
        textStackView.addArrangedSubview(bottomStackView)
        textStackView.addArrangedSubview(memoLabel)
        
        mainStackView.axis = .horizontal
        mainStackView.spacing = 12
        mainStackView.alignment = .top
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.addArrangedSubview(thumbnailImageView)
        mainStackView.addArrangedSubview(textStackView)
        
        contentView.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 56),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 82),
            
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
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
}
