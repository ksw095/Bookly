import Foundation

final class BookStore {
    static let shared = BookStore()
    
    private let saveKey = "bookly_saved_books"
    private(set) var books: [Book] = []
    
    private init() {
        loadBooks()
    }
    
    var wishBooks: [Book] {
        books
            .filter { $0.status == .wish }
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    var readingBooks: [Book] {
        books
            .filter { $0.status == .reading }
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    var doneBooks: [Book] {
        books
            .filter { $0.status == .done }
            .sorted {
                if $0.rating == $1.rating {
                    return $0.createdAt > $1.createdAt
                }
                return $0.rating > $1.rating
            }
    }
    
    func books(for status: BookStatus) -> [Book] {
        switch status {
        case .wish:
            return wishBooks
        case .reading:
            return readingBooks
        case .done:
            return doneBooks
        }
    }
    
    func count(for status: BookStatus) -> Int {
        books.filter { $0.status == status }.count
    }
    
    func addBook(_ book: Book) {
        if !book.isbn.isEmpty {
            let duplicated = books.contains { $0.isbn == book.isbn }
            if duplicated {
                return
            }
        }
        
        var newBook = book
        
        if newBook.status == .reading {
            newBook.readingStartedAt = newBook.readingStartedAt ?? Date()
            newBook.progress = newBook.progress ?? 0.0
        }
        
        books.append(newBook)
        saveBooks()
        postChange()
    }
    
    func updateBook(_ updatedBook: Book) {
        guard let index = books.firstIndex(where: { $0.id == updatedBook.id }) else {
            return
        }
        
        var bookToSave = updatedBook
        
        if bookToSave.status == .reading {
            bookToSave.readingStartedAt = bookToSave.readingStartedAt ?? Date()
            bookToSave.progress = bookToSave.progress ?? 0.0
        }
        
        books[index] = bookToSave
        saveBooks()
        postChange()
    }
    
    func deleteBook(_ book: Book) {
        books.removeAll { $0.id == book.id }
        saveBooks()
        postChange()
    }
    
    private func saveBooks() {
        do {
            let data = try JSONEncoder().encode(books)
            UserDefaults.standard.set(data, forKey: saveKey)
        } catch {
            print("Book save error:", error.localizedDescription)
        }
    }
    
    private func loadBooks() {
        guard let data = UserDefaults.standard.data(forKey: saveKey) else {
            books = []
            return
        }
        
        do {
            books = try JSONDecoder().decode([Book].self, from: data)
        } catch {
            books = []
            print("Book load error:", error.localizedDescription)
        }
    }
    
    private func postChange() {
        NotificationCenter.default.post(name: .bookStoreDidChange, object: nil)
    }
}
