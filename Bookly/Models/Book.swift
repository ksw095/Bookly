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
    var memo: String
    var createdAt: Date
    
    var readingStartedAt: Date?
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
        memo: String = "",
        createdAt: Date = Date(),
        readingStartedAt: Date? = nil,
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
        self.memo = memo
        self.createdAt = createdAt
        self.readingStartedAt = readingStartedAt
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
    
    var readingDaysText: String {
        let startDate = readingStartedAt ?? createdAt
        let startOfStartDate = Calendar.current.startOfDay(for: startDate)
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let day = Calendar.current.dateComponents([.day], from: startOfStartDate, to: startOfToday).day ?? 0
        return "\(max(day + 1, 1))일째"
    }
}
