import Foundation
import FirebaseAuth
import FirebaseFirestore

final class BookStore {
    static let shared = BookStore()
    
    private let db = Firestore.firestore()
    private let legacySaveKey = "bookly_saved_books"
    private let migrationPrefix = "bookly_did_migrate_books_"
    
    private var listener: ListenerRegistration?
    private var currentUserId: String?
    
    private(set) var books: [Book] = []
    private(set) var isLoading: Bool = false
    
    private init() {}
    
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
    
    func startListeningForCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else {
            stopListeningAndClear()
            return
        }
        
        guard currentUserId != uid else {
            return
        }
        
        stopListeningOnly()
        currentUserId = uid
        isLoading = true
        
        migrateLegacyLocalBooksIfNeeded(for: uid)
        
        listener = booksCollection(for: uid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else {
                    return
                }
                
                if let error {
                    print("Firestore books listener error:", error.localizedDescription)
                    self.isLoading = false
                    self.postChange()
                    return
                }
                
                let documents = snapshot?.documents ?? []
                
                self.books = documents.compactMap { document in
                    Book(documentId: document.documentID, data: document.data())
                }
                
                self.isLoading = false
                self.postChange()
            }
    }
    
    func stopListeningAndClear() {
        stopListeningOnly()
        currentUserId = nil
        books = []
        isLoading = false
        postChange()
    }
    
    private func stopListeningOnly() {
        listener?.remove()
        listener = nil
    }
    
    func addBook(_ book: Book) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Book add failed: current user is nil")
            return
        }
        
        var newBook = book
        
        if newBook.status == .reading {
            newBook.readingStartedAt = newBook.readingStartedAt ?? Date()
            newBook.progress = newBook.progress ?? 0.0
        }
        
        if newBook.status == .done {
            newBook.readingFinishedAt = newBook.readingFinishedAt ?? Date()
        }
        
        if !newBook.isbn.isEmpty {
            let duplicated = books.contains { $0.isbn == newBook.isbn }
            if duplicated {
                return
            }
        }
        
        booksCollection(for: uid)
            .document(newBook.id)
            .setData(newBook.toFirestoreData(), merge: true) { error in
                if let error {
                    print("Firestore book add error:", error.localizedDescription)
                }
            }
    }
    
    func updateBook(_ updatedBook: Book) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Book update failed: current user is nil")
            return
        }
        
        var bookToSave = updatedBook
        
        if bookToSave.status == .reading {
            bookToSave.readingStartedAt = bookToSave.readingStartedAt ?? Date()
            bookToSave.progress = bookToSave.progress ?? 0.0
        }
        
        if bookToSave.status == .done {
            bookToSave.readingFinishedAt = bookToSave.readingFinishedAt ?? Date()
            bookToSave.progress = 1.0
        }
        
        booksCollection(for: uid)
            .document(bookToSave.id)
            .setData(bookToSave.toFirestoreData(), merge: true) { error in
                if let error {
                    print("Firestore book update error:", error.localizedDescription)
                }
            }
    }
    
    func deleteBook(_ book: Book) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Book delete failed: current user is nil")
            return
        }
        
        booksCollection(for: uid)
            .document(book.id)
            .delete { error in
                if let error {
                    print("Firestore book delete error:", error.localizedDescription)
                }
            }
    }
    
    func deleteAllBooksForCurrentUser(completion: ((Error?) -> Void)? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion?(nil)
            return
        }
        
        deleteAllBooks(for: uid, completion: completion)
    }
    
    func deleteAllBooks(for uid: String, completion: ((Error?) -> Void)? = nil) {
        booksCollection(for: uid)
            .getDocuments { [weak self] snapshot, error in
                guard let self else {
                    completion?(error)
                    return
                }
                
                if let error {
                    completion?(error)
                    return
                }
                
                let documents = snapshot?.documents ?? []
                
                guard !documents.isEmpty else {
                    completion?(nil)
                    return
                }
                
                let batch = self.db.batch()
                
                documents.forEach { document in
                    batch.deleteDocument(document.reference)
                }
                
                batch.commit { error in
                    completion?(error)
                }
            }
    }
    
    private func booksCollection(for uid: String) -> CollectionReference {
        db.collection("users")
            .document(uid)
            .collection("books")
    }
    
    private func postChange() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .bookStoreDidChange, object: nil)
        }
    }
}

// MARK: - Legacy UserDefaults Migration

private extension BookStore {
    func migrateLegacyLocalBooksIfNeeded(for uid: String) {
        let migrationKey = migrationPrefix + uid
        
        guard !UserDefaults.standard.bool(forKey: migrationKey) else {
            return
        }
        
        let legacyBooks = loadLegacyBooks()
        
        guard !legacyBooks.isEmpty else {
            UserDefaults.standard.set(true, forKey: migrationKey)
            return
        }
        
        let batch = db.batch()
        let collection = booksCollection(for: uid)
        
        legacyBooks.forEach { book in
            var bookToSave = book
            
            if bookToSave.status == .reading {
                bookToSave.readingStartedAt = bookToSave.readingStartedAt ?? Date()
                bookToSave.progress = bookToSave.progress ?? 0.0
            }
            
            if bookToSave.status == .done {
                bookToSave.readingFinishedAt = bookToSave.readingFinishedAt ?? Date()
            }
            
            let reference = collection.document(bookToSave.id)
            batch.setData(bookToSave.toFirestoreData(), forDocument: reference, merge: true)
        }
        
        batch.commit { error in
            if let error {
                print("Legacy book migration error:", error.localizedDescription)
                return
            }
            
            UserDefaults.standard.set(true, forKey: migrationKey)
            UserDefaults.standard.removeObject(forKey: self.legacySaveKey)
            print("Legacy book migration completed")
        }
    }
    
    func loadLegacyBooks() -> [Book] {
        guard let data = UserDefaults.standard.data(forKey: legacySaveKey) else {
            return []
        }
        
        do {
            return try JSONDecoder().decode([Book].self, from: data)
        } catch {
            print("Legacy book load error:", error.localizedDescription)
            return []
        }
    }
}
