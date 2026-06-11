import Foundation

enum RecommendationFilter {
    private static let bannedKeywords = [
        // 어린이 / 아동 / 유아 / 청소년
        "어린이",
        "아동",
        "유아",
        "초등",
        "초등학생",
        "초등학교",
        "중등",
        "중학생",
        "청소년",
        "아이",
        "아이들",
        "어린이를위한",
        "어린이용",
        "주니어",
        "키즈",
        "kids",
        "kid",
        "child",
        "children",
        
        // 교육서 / 교재 / 학습서 / 문제집
        "교육",
        "교재",
        "교과서",
        "참고서",
        "문제집",
        "학습서",
        "학습",
        "워크북",
        "기출",
        "수험서",
        "시험대비",
        "내신",
        "자습서",
        "익힘책",
        "평가문제집",
        "개념서",
        "기본서",
        "특강",
        "강의",
        "수업",
        "선생님",
        "교사용",
        "학생용",
        "학년",
        "학기",
        
        // 동화 / 그림책 / 만화
        "동화",
        "그림책",
        "만화",
        "학습만화",
        "웹툰",
        "코믹",
        "애니메이션",
        "캐릭터",
        "캐릭터북",
        "스토리북",
        "그림동화",
        "명작동화",
        "전래동화",
        "창작동화",
        
        // 어린이 코딩 / 교육용 IT
        "스크래치",
        "엔트리",
        "어린이코딩",
        "코딩교실",
        "코딩교육",
        "코딩공부",
        "컴퓨팅사고력",
        "사고력코딩",
        
        // 놀이 / 활동북
        "놀이",
        "색칠",
        "색칠북",
        "스티커",
        "스티커북",
        "만들기",
        "종이접기",
        "퍼즐",
        "퀴즈",
        "숨은그림찾기",
        "활동북",
        "쓰기",
        "따라쓰기",
        "필사",
        
        // 세트 / 전집 / 부록 / 굿즈
        "세트",
        "전집",
        "전권",
        "박스",
        "박스세트",
        "패키지",
        "부록",
        "별책",
        "별책부록",
        "카드북",
        "노트",
        "다이어리",
        "굿즈",
        "포스터",
        "스페셜",
        "한정판",
        "특별판",
        "리커버",
        "리커버판",
        "개정판",
        "합본",
        "미니북",
        "포켓북",
        
        // 매체형 도서
        "cd",
        "dvd",
        "오디오북",
        "전자책",
        "ebook",
        
        // 시험 / 자격증 / 수험류
        "자격증",
        "공무원",
        "공시",
        "토익",
        "토플",
        "수능",
        "모의고사",
        "검정고시",
        "완벽가이드",
        "한권으로끝내는",
        "따라하며배우는"
    ]
    
    private static let bannedPublisherKeywords = [
        "천재교육",
        "비상교육",
        "미래엔",
        "좋은책신사고",
        "동아출판",
        "디딤돌",
        "길벗스쿨",
        "시대고시",
        "에듀윌",
        "해커스",
        "ybm",
        "ne능률",
        "다락원",
        "마더텅",
        "수경출판사",
        "개념원리",
        "쎄듀",
        "키출판사",
        "한빛에듀",
        "예림당",
        "아이세움",
        "아울북",
        "웅진주니어",
        "비룡소",
        "창비교육"
    ]
    
    static func isRecommendable(_ document: KakaoBookDocument) -> Bool {
        let title = document.title.removingHTMLTags()
        let authors = document.authors.joined(separator: " ")
        let publisher = document.publisher
        let contents = document.contents.removingHTMLTags()
        let combinedText = "\(title) \(authors) \(publisher) \(contents)"
        
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        
        guard !document.thumbnail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        
        guard !containsBannedKeyword(in: combinedText) else {
            return false
        }
        
        guard !containsBannedPublisherKeyword(in: publisher) else {
            return false
        }
        
        return true
    }
    
    static func containsBannedKeyword(in text: String) -> Bool {
        let normalizedText = normalized(text)
        
        return bannedKeywords.contains { keyword in
            normalizedText.contains(normalized(keyword))
        }
    }
    
    static func containsBannedPublisherKeyword(in publisher: String) -> Bool {
        let normalizedPublisher = normalized(publisher)
        
        return bannedPublisherKeywords.contains { keyword in
            normalizedPublisher.contains(normalized(keyword))
        }
    }
    
    static func normalized(_ text: String) -> String {
        text
            .removingHTMLTags()
            .lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\t", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "_", with: "")
            .replacingOccurrences(of: "·", with: "")
            .replacingOccurrences(of: ":", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "[", with: "")
            .replacingOccurrences(of: "]", with: "")
            .replacingOccurrences(of: "<", with: "")
            .replacingOccurrences(of: ">", with: "")
    }
}
