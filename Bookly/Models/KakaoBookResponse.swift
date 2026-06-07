import Foundation

struct KakaoBookResponse: Codable {
    let meta: KakaoBookMeta
    let documents: [KakaoBookDocument]
}

struct KakaoBookMeta: Codable {
    let total_count: Int
    let pageable_count: Int
    let is_end: Bool
}

struct KakaoBookDocument: Codable {
    let title: String
    let authors: [String]
    let publisher: String
    let isbn: String
    let datetime: String
    let thumbnail: String
    let contents: String
    let url: String
    
    let translators: [String]?
    let price: Int?
    let sale_price: Int?
    let status: String?
    
    func toBook(status: BookStatus) -> Book {
        Book(
            title: title.removingHTMLTags(),
            authors: authors,
            publisher: publisher,
            isbn: isbn,
            datetime: datetime,
            thumbnail: thumbnail,
            status: status
        )
    }
}
