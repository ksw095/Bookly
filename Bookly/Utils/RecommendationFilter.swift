import Foundation

enum RecommendationFilter {
    static let recommendationSearchKeywords: [String] = [
        "한국문학 소설",
        "세계문학 소설",
        "문학동네 소설",
        "창비 소설",
        "민음사 세계문학",
        "문학과지성사 소설",
        "오늘의 젊은 작가",
        "에세이 베스트셀러",
        "힐링 에세이",
        "고전문학 소설",
        "감성 에세이",
        "산문집",
        "소설 베스트셀러",
        "한국 에세이"
    ]
    
    static let bannedKeywords: [String] = [
        "수능",
        "기출",
        "모의고사",
        "문제집",
        "자격증",
        "토익",
        "toeic",
        "토플",
        "toefl",
        "opic",
        "오픽",
        "텝스",
        "teps",
        "공무원",
        "임용",
        "시험",
        "해설",
        "정답",
        "ebs",
        "내신",
        "중학",
        "중등",
        "고등",
        "고교",
        "초등",
        "초등학생",
        "중학생",
        "고등학생",
        "워크북",
        "교재",
        "교과서",
        "학습지",
        "학습",
        "수험",
        "입시",
        "논술",
        "면접",
        "개념",
        "유형",
        "평가원",
        "교육청",
        "문제",
        "대비",
        "특강",
        "실전",
        "모의",
        "강의",
        "강의노트",
        "강좌",
        "개론",
        "원론",
        "입문서",
        "전공",
        "전공서",
        "대학교재",
        "대학강의",
        "대학교양",
        "교육",
        "교육학",
        "교육과정",
        "교사용",
        "지도서",
        "참고서",
        "학원",
        "스프링",
        "스프링북",
        "세트",
        "전집",
        "카드",
        "플래시카드",
        "사전",
        "도감",
        "백과",
        "컴퓨터",
        "프로그래밍",
        "코딩",
        "파이썬",
        "python",
        "java",
        "c언어",
        "알고리즘",
        "자료구조",
        "인공지능",
        "ai",
        "머신러닝",
        "딥러닝",
        "생명과학",
        "물리",
        "화학",
        "지구과학",
        "수학",
        "미적분",
        "확률과통계",
        "기하",
        "국어",
        "영어",
        "한국사",
        "사회탐구",
        "과학탐구"
    ]
    
    static func normalized(_ text: String) -> String {
        text
            .lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\t", with: "")
    }
    
    static func containsBannedKeyword(in text: String) -> Bool {
        let normalizedText = normalized(text)
        
        return bannedKeywords.contains { keyword in
            normalizedText.contains(normalized(keyword))
        }
    }
}
