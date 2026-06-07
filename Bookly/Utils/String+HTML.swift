import UIKit

extension String {
    func removingHTMLTags() -> String {
        return self.replacingOccurrences(
            of: "<[^>]+>",
            with: "",
            options: .regularExpression,
            range: nil
        )
    }
    
    func highQualityKakaoThumbnailURLString() -> String {
        var result = self
        
        let patterns = [
            ("R\\d+x\\d+", "R600x800"),
            ("C\\d+x\\d+", "C600x800"),
            ("S\\d+x\\d+", "S600x800"),
            ("\\d+x\\d+", "600x800")
        ]
        
        for pattern in patterns {
            if result.range(of: pattern.0, options: .regularExpression) != nil {
                result = result.replacingOccurrences(
                    of: pattern.0,
                    with: pattern.1,
                    options: .regularExpression
                )
                break
            }
        }
        
        return result
    }
}

extension Notification.Name {
    static let bookStoreDidChange = Notification.Name("bookStoreDidChange")
}

extension UIImageView {
    func setImage(from urlString: String?) {
        self.image = UIImage(systemName: "book.closed.fill")
        self.tintColor = .systemIndigo
        self.contentMode = .scaleAspectFit
        self.backgroundColor = .secondarySystemBackground
        self.clipsToBounds = true
        
        guard let urlString = urlString,
              !urlString.isEmpty else {
            return
        }
        
        let highQualityURLString = urlString.highQualityKakaoThumbnailURLString()
        
        if let highQualityURL = URL(string: highQualityURLString) {
            loadImage(from: highQualityURL, fallbackURLString: urlString)
        } else if let originalURL = URL(string: urlString) {
            loadImage(from: originalURL, fallbackURLString: nil)
        }
    }
    
    private func loadImage(from url: URL, fallbackURLString: String?) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, _ in
            let isValidResponse: Bool
            
            if let httpResponse = response as? HTTPURLResponse {
                isValidResponse = (200...299).contains(httpResponse.statusCode)
            } else {
                isValidResponse = true
            }
            
            if isValidResponse,
               let data = data,
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.image = image
                    self?.contentMode = .scaleAspectFit
                    self?.backgroundColor = .clear
                }
                return
            }
            
            guard let fallbackURLString = fallbackURLString,
                  let fallbackURL = URL(string: fallbackURLString),
                  fallbackURL != url else {
                return
            }
            
            URLSession.shared.dataTask(with: fallbackURL) { [weak self] fallbackData, _, _ in
                guard let fallbackData = fallbackData,
                      let fallbackImage = UIImage(data: fallbackData) else {
                    return
                }
                
                DispatchQueue.main.async {
                    self?.image = fallbackImage
                    self?.contentMode = .scaleAspectFit
                    self?.backgroundColor = .clear
                }
            }.resume()
        }.resume()
    }
}
