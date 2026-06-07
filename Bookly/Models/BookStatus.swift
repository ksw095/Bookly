import Foundation

enum BookStatus: String, Codable, CaseIterable {
    case wish = "WISH"
    case reading = "READING"
    case done = "DONE"
    
    var title: String {
        switch self {
        case .wish:
            return "읽고 싶은 책"
        case .reading:
            return "읽는 중"
        case .done:
            return "완독"
        }
    }
}
