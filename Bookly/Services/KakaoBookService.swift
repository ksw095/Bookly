import Foundation

final class KakaoBookService {
    static let shared = KakaoBookService()
    
    private init() {}
    
    private var kakaoRESTAPIKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "KAKAO_REST_API_KEY") as? String else {
            return ""
        }
        
        return key.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func searchBooks(
        keyword: String,
        page: Int,
        size: Int = 50,
        target: String? = nil,
        sort: String = "accuracy"
    ) async throws -> KakaoBookResponse {
        let trimmedKeyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedKeyword.isEmpty else {
            throw NSError(
                domain: "KakaoBookService",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "검색어가 비어 있습니다."]
            )
        }
        
        guard isValidAPIKey(kakaoRESTAPIKey) else {
            throw NSError(
                domain: "KakaoBookService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Kakao REST API 키가 입력되지 않았습니다."]
            )
        }
        
        var components = URLComponents(string: "https://dapi.kakao.com/v3/search/book")!
        
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "query", value: trimmedKeyword),
            URLQueryItem(name: "sort", value: sort),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "size", value: "\(size)")
        ]
        
        if let target = target {
            queryItems.append(URLQueryItem(name: "target", value: target))
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("KakaoAK \(kakaoRESTAPIKey)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            let errorBody = String(data: data, encoding: .utf8) ?? "응답 본문 없음"
            print("Kakao API Error Body:", errorBody)
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(KakaoBookResponse.self, from: data)
    }
    
    private func isValidAPIKey(_ key: String) -> Bool {
        guard !key.isEmpty else {
            return false
        }
        
        let invalidKeys = [
            "YOUR_KAKAO_REST_API_KEY",
            "여기에_REST_API_키_입력",
            "카카오_REST_API_키",
            "여기에_카카오_REST_API_키"
        ]
        
        return !invalidKeys.contains(key)
    }
}
