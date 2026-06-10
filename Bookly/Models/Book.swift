import Foundation

struct Book: Codable, Equatable {
    var id: String
    var title: String
    var authors: [String]
    var publisher: String
    var isbn: String
    var datetime: String
    var thumbnail: String
    var status: BookStatus
    var rating: Int
    
    var ratingValue: Double?
    
    var memo: String
    var shortReview: String?
    var quote: String?
    
    var createdAt: Date
    
    var readingStartedAt: Date?
    var readingFinishedAt: Date?
    
    var progress: Double?
    
    init(
        id: String = UUID().uuidString,
        title: String,
        authors: [String],
        publisher: String,
        isbn: String,
        datetime: String,
        thumbnail: String,
        status: BookStatus,
        rating: Int = 0,
        ratingValue: Double? = nil,
        memo: String = "",
        shortReview: String? = nil,
        quote: String? = nil,
        createdAt: Date = Date(),
        readingStartedAt: Date? = nil,
        readingFinishedAt: Date? = nil,
        progress: Double? = nil
    ) {
        self.id = id
        self.title = title
        self.authors = authors
        self.publisher = publisher
        self.isbn = isbn
        self.datetime = datetime
        self.thumbnail = thumbnail
        self.status = status
        self.rating = rating
        self.ratingValue = ratingValue
        self.memo = memo
        self.shortReview = shortReview
        self.quote = quote
        self.createdAt = createdAt
        self.readingStartedAt = readingStartedAt
        self.readingFinishedAt = readingFinishedAt
        self.progress = progress
    }
    
    var authorText: String {
        authors.isEmpty ? "저자 정보 없음" : authors.joined(separator: ", ")
    }
    
    var publishedDateText: String {
        if datetime.count >= 10 {
            return String(datetime.prefix(10))
        }
        return datetime.isEmpty ? "출판일 정보 없음" : datetime
    }
    
    var progressValue: Double {
        progress ?? 0.0
    }
    
    var displayRating: Double {
        ratingValue ?? Double(rating)
    }
    
    var shortReviewText: String {
        shortReview?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
    
    var memoText: String {
        memo.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var quoteText: String {
        quote?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
    
    var readingDaysText: String {
        let startDate = readingStartedAt ?? createdAt
        let endDate = readingFinishedAt ?? Date()
        
        let startOfStartDate = Calendar.current.startOfDay(for: startDate)
        let startOfEndDate = Calendar.current.startOfDay(for: endDate)
        let day = Calendar.current.dateComponents([.day], from: startOfStartDate, to: startOfEndDate).day ?? 0
        
        return "\(max(day + 1, 1))일"
    }
    
    var readingPeriodText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM.dd"
        
        guard let startedAt = readingStartedAt else {
            return "독서 기간 없음"
        }
        
        let startText = formatter.string(from: startedAt)
        
        if let finishedAt = readingFinishedAt {
            let endText = formatter.string(from: finishedAt)
            return "\(startText) - \(endText)"
        }
        
        return "\(startText) - 진행 중"
    }
}
