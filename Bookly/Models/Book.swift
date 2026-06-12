import Foundation
import FirebaseFirestore

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

// MARK: - Firestore Mapping

extension Book {
    func toFirestoreData() -> [String: Any] {
        var data: [String: Any] = [
            "id": id,
            "title": title,
            "authors": authors,
            "publisher": publisher,
            "isbn": isbn,
            "datetime": datetime,
            "thumbnail": thumbnail,
            "status": status.rawValue,
            "rating": rating,
            "memo": memo,
            "createdAt": Timestamp(date: createdAt),
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        if let ratingValue {
            data["ratingValue"] = ratingValue
        }
        
        if let shortReview {
            data["shortReview"] = shortReview
        }
        
        if let quote {
            data["quote"] = quote
        }
        
        if let readingStartedAt {
            data["readingStartedAt"] = Timestamp(date: readingStartedAt)
        }
        
        if let readingFinishedAt {
            data["readingFinishedAt"] = Timestamp(date: readingFinishedAt)
        }
        
        if let progress {
            data["progress"] = progress
        }
        
        return data
    }
    
    init?(documentId: String, data: [String: Any]) {
        let id = data["id"] as? String ?? documentId
        
        guard let title = data["title"] as? String else {
            return nil
        }
        
        let authors = data["authors"] as? [String] ?? []
        let publisher = data["publisher"] as? String ?? ""
        let isbn = data["isbn"] as? String ?? ""
        let datetime = data["datetime"] as? String ?? ""
        let thumbnail = data["thumbnail"] as? String ?? ""
        
        let statusRawValue = data["status"] as? String ?? BookStatus.wish.rawValue
        let status = BookStatus(rawValue: statusRawValue) ?? .wish
        
        let rating = data["rating"] as? Int ?? 0
        let ratingValue = data["ratingValue"] as? Double
        
        let memo = data["memo"] as? String ?? ""
        let shortReview = data["shortReview"] as? String
        let quote = data["quote"] as? String
        
        let createdAt = Book.firestoreDate(from: data["createdAt"]) ?? Date()
        let readingStartedAt = Book.firestoreDate(from: data["readingStartedAt"])
        let readingFinishedAt = Book.firestoreDate(from: data["readingFinishedAt"])
        let progress = data["progress"] as? Double
        
        self.init(
            id: id,
            title: title,
            authors: authors,
            publisher: publisher,
            isbn: isbn,
            datetime: datetime,
            thumbnail: thumbnail,
            status: status,
            rating: rating,
            ratingValue: ratingValue,
            memo: memo,
            shortReview: shortReview,
            quote: quote,
            createdAt: createdAt,
            readingStartedAt: readingStartedAt,
            readingFinishedAt: readingFinishedAt,
            progress: progress
        )
    }
    
    private static func firestoreDate(from value: Any?) -> Date? {
        if let timestamp = value as? Timestamp {
            return timestamp.dateValue()
        }
        
        if let date = value as? Date {
            return date
        }
        
        return nil
    }
}
