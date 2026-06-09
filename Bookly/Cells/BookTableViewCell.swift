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
    private let addButton = UIButton(type: .system)
    
    private let textStackView = UIStackView()
    private let infoStackView = UIStackView()
    private let mainStackView = UIStackView()
    
    private let navyColor = UIColor(red: 0.02, green: 0.10, blue: 0.28, alpha: 1.0)
    private let purpleColor = UIColor(red: 0.31, green: 0.22, blue: 0.88, alpha: 1.0)
    private let mutedTextColor = UIColor(red: 0.55, green: 0.56, blue: 0.62, alpha: 1.0)
    
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
        addButton.isHidden = true
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
        addButton.isHidden = true
        
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
            authorLabel.text = "저자 정보 없음"
        } else {
            authorLabel.text = document.authors.joined(separator: ", ")
        }
        
        let publisher = document.publisher.isEmpty ? "출판사 정보 없음" : document.publisher
        let year = publishedYear(from: document.datetime)
        publisherLabel.text = year.isEmpty ? publisher : "\(publisher) · \(year)"
        
        statusLabel.isHidden = true
        ratingLabel.isHidden = true
        memoLabel.isHidden = true
        
        priceLabel.text = formattedPrice(from: document)
        priceLabel.isHidden = false
        
        addButton.isHidden = false
        accessoryType = .none
    }
    
    private func configureUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .white
        selectionStyle = .none
        
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView.layer.cornerRadius = 10
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.backgroundColor = .secondarySystemBackground
        
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textColor = navyColor
        titleLabel.numberOfLines = 2
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        authorLabel.font = .systemFont(ofSize: 13, weight: .medium)
        authorLabel.textColor = mutedTextColor
        authorLabel.numberOfLines = 1
        
        publisherLabel.font = .systemFont(ofSize: 12, weight: .medium)
        publisherLabel.textColor = mutedTextColor
        publisherLabel.numberOfLines = 1
        
        statusLabel.font = .boldSystemFont(ofSize: 12)
        statusLabel.textColor = purpleColor
        
        ratingLabel.font = .systemFont(ofSize: 12)
        ratingLabel.textColor = .systemOrange
        
        priceLabel.font = .systemFont(ofSize: 14, weight: .bold)
        priceLabel.textColor = navyColor
        priceLabel.numberOfLines = 1
        priceLabel.lineBreakMode = .byClipping
        priceLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        priceLabel.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        memoLabel.font = .systemFont(ofSize: 13)
        memoLabel.textColor = .secondaryLabel
        memoLabel.numberOfLines = 2
        
        addButton.setTitle("+ 추가", for: .normal)
        addButton.titleLabel?.font = .boldSystemFont(ofSize: 13)
        addButton.setTitleColor(purpleColor, for: .normal)
        addButton.layer.cornerRadius = 10
        addButton.layer.borderWidth = 1
        addButton.layer.borderColor = purpleColor.cgColor
        addButton.backgroundColor = .white
        addButton.isUserInteractionEnabled = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.isHidden = true
        
        infoStackView.axis = .horizontal
        infoStackView.spacing = 8
        infoStackView.addArrangedSubview(statusLabel)
        infoStackView.addArrangedSubview(ratingLabel)
        
        textStackView.axis = .vertical
        textStackView.spacing = 4
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(authorLabel)
        textStackView.addArrangedSubview(publisherLabel)
        textStackView.addArrangedSubview(priceLabel)
        textStackView.addArrangedSubview(infoStackView)
        textStackView.addArrangedSubview(memoLabel)
        
        mainStackView.axis = .horizontal
        mainStackView.spacing = 14
        mainStackView.alignment = .center
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.addArrangedSubview(thumbnailImageView)
        mainStackView.addArrangedSubview(textStackView)
        
        contentView.addSubview(mainStackView)
        contentView.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 66),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 94),
            
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            mainStackView.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -12),
            mainStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12),
            
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),
            addButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 70),
            addButton.heightAnchor.constraint(equalToConstant: 36)
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
    
    private func publishedYear(from datetime: String) -> String {
        guard datetime.count >= 4 else {
            return ""
        }
        
        return String(datetime.prefix(4))
    }
}
