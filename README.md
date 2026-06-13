<div align="center">

# 📚 사용자 맞춤형 IOS 독서 기록 앱 "Bookly"

쉬운 도서 검색부터 도서 추천, 나만의 서재 관리, 독서 진행률 기록, 독서 카드 공유까지  
독서 과정을 한 곳에서 관리할 수 있는 IOS 독서 기록 앱입니다.

</div>

---

## 🖼️ 예시 화면

| 홈 화면 | 도서 검색 화면 | 나의 서재 화면 |
|:---:|:---:|:---:|
| <img src="https://github.com/user-attachments/assets/051b6e2c-2431-4be9-8ae7-7089690b623e" width="240" /> | <img src="https://github.com/user-attachments/assets/70710d66-8fb3-4947-8881-5b24c62481c1" width="240" /> | <img src="https://github.com/user-attachments/assets/9fa633ab-24ae-4000-a281-a3e07feb7b1e" width="240" /> |
| 오늘의 도서 추천과 독서 상태 요약 | 카카오 도서 API 기반 검색 | WISH / READING / DONE 책장 관리 |

| 독서 기록 화면 | 독서 카드 공유 화면 | 회원 정보 화면 |
|:---:|:---:|:---:|
| <img src="https://github.com/user-attachments/assets/d0667978-8f0f-4a91-9606-41318b64df19" width="240" /> | <img src="https://github.com/user-attachments/assets/27e94126-dd6d-4bb5-a763-4b5379d2c9c5" width="240" /> | <img src="https://github.com/user-attachments/assets/421b6d99-5596-41fb-a1a5-c11bf22a48cb" width="240" /> |
| 별점, 메모, 한줄평 기록 | 완독 기록 기반 독서 카드 저장 및 공유 | 로그인 계정 관리 및 이용약관 |

---

## 🎯 주요 기능

- <strong>🔎 도서 검색</strong> : 카카오 도서 검색 API를 활용해 제목, 저자, 출판사 기준으로 도서를 쉽게 검색할 수 있습니다.
  
- <strong>💡 오늘의 도서 추천</strong> : 다양한 추천 키워드를 기반으로 매일 새로운 도서를 홈 화면에 제공합니다.

- <strong>📚 나의 서재 관리</strong> : 책을 `WISH`, `READING`, `DONE` 상태로 분류해 독서 상태별로 관리할 수 있습니다.

- <strong>📖 독서 진행률 기록</strong> : 읽는 중인 책의 진행률과 독서 시작일을 기록하고 홈 화면에서 바로 확인할 수 있습니다.

- <strong>⭐ 완독 기록 관리</strong> : 완독한 책에 별점, 메모, 한줄평, 필사/인용문을 남길 수 있습니다.

- <strong>📝 독서 카드 공유</strong> : 완독 기록을 기반으로 독서 카드를 생성하고 이미지로 저장하거나 SNS에 바로 공유할 수 있습니다.

- <strong>🔥 Firebase 계정 연동</strong> : Firebase Authentication으로 회원가입/로그인을 제공하고, 사용자별 독서 기록을 Cloud에 저장합니다.
 

---

## 🛠 Tech Stack

### iOS

<p>
  <img src="https://img.shields.io/badge/Swift-F05138?style=for-the-badge&logo=swift&logoColor=white"/>
  <img src="https://img.shields.io/badge/UIKit-2396F3?style=for-the-badge&logo=apple&logoColor=white"/>
  <img src="https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=apple&logoColor=white"/>
</p>

### Backend / Database

<p>
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black"/>
  <img src="https://img.shields.io/badge/Firebase_Auth-FFCA28?style=for-the-badge&logo=firebase&logoColor=black"/>
  <img src="https://img.shields.io/badge/Cloud_Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black"/>
</p>

### API

<p>
  <img src="https://img.shields.io/badge/Kakao_Book_API-FFCD00?style=for-the-badge&logo=kakao&logoColor=black"/>
</p>

### Tools

<p>
  <img src="https://img.shields.io/badge/Xcode-147EFB?style=for-the-badge&logo=xcode&logoColor=white"/>
  <img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white"/>
</p>

---

## 🧱 시스템 구조도

```text
Bookly
 ├── Firebase Authentication
 │    ├── 이메일 회원가입
 │    ├── 로그인
 │    ├── 비밀번호 재설정
 │    └── 회원 탈퇴
 │
 ├── Cloud Firestore
 │    └── users/{uid}/books/{bookId}
 │         ├── WISH 책 목록
 │         ├── READING 책 목록
 │         ├── DONE 책 목록
 │         ├── 별점 / 메모 / 한줄평
 │         ├── 필사 / 인용문
 │         └── 독서 시작일 / 완독일 / 진행률
 │
 ├── Kakao Book Search API
 │    ├── 도서 검색
 │    ├── 도서 상세 정보 조회
 │    └── 오늘의 도서 추천 데이터 수집
 │
 └── UIKit ViewControllers
      ├── HomeViewController
      ├── SearchViewController
      ├── LibraryViewController
      ├── RecordViewController
      ├── AuthViewController
      └── AccountViewController
```

---

## 🗂 주요 화면 구성

### Home

- 오늘의 도서 추천
- WISH / READING / DONE 독서 상태 요약
- 읽고 있는 책 진행률 확인
- 앱 사용 방법 안내
- 나의 서재 바로가기

### Search

- 도서명, 저자, 출판사 기준 검색
- 정확도순 / 최신순 정렬
- 도서 상세 정보 확인
- 원하는 책장 상태로 저장

### Library

- WISH, READING, DONE 책장 분류
- 책 상태 변경
- 책 삭제 및 관리
- 추천 도서 확인

### Record

- 완독 기록 관리
- 별점, 메모, 한줄평 작성
- 독서 카드 생성 및 공유

### Account

- 로그인 계정 정보 확인
- 비밀번호 재설정
- 이용약관 확인
- 로그아웃
- 회원 탈퇴

---

## 🚀 설치 및 실행 방법

```bash
# 1. 프로젝트 클론
git clone https://github.com/ksw095/Bookly.git

# 2. 디렉토리 이동
cd Bookly

# 3. Xcode에서 프로젝트 열기
open Bookly.xcodeproj

# 4. Firebase 설정 파일 추가
# GoogleService-Info.plist 파일을 Bookly 타깃에 추가합니다.

# 5. Kakao REST API 키 설정
# Bookly/Config/Secrets.xcconfig 파일에 REST API 키를 입력합니다.

# 6. 시뮬레이터 또는 실제 iPhone에서 실행
```

---

## 🔐 환경 변수 및 API 키 설정

이 프로젝트는 카카오 도서 검색 API와 Firebase를 사용합니다.

### Kakao Book API

`Bookly/Config` 폴더의 예시 파일을 복사합니다.

```text
Secrets.xcconfig.example → Secrets.xcconfig
```

`Secrets.xcconfig`에 본인의 Kakao REST API 키를 입력합니다.

```xcconfig
KAKAO_REST_API_KEY = YOUR_KAKAO_REST_API_KEY
```

주의: `KakaoAK`는 붙이지 않습니다.  
앱 코드에서 API 요청 시 자동으로 `KakaoAK`를 붙입니다.

---

## ⚠️ 보안 주의사항

실제 API 키가 들어 있는 `Secrets.xcconfig` 파일은 GitHub에 업로드하면 안 됩니다.

`.gitignore`에는 아래 항목이 포함되어야 합니다.

```gitignore
Bookly/Config/Secrets.xcconfig
**/Secrets.xcconfig
```

GitHub에는 예시 파일만 업로드합니다.

```text
Secrets.xcconfig.example
```

커밋 전 실제 키 파일이 포함되지 않았는지 확인하려면 아래 명령어를 사용할 수 있습니다.

```bash
git ls-files | grep Secrets.xcconfig
```

정상적으로 설정되어 있다면 아래 파일만 보여야 합니다.

```text
Bookly/Config/Secrets.xcconfig.example
```

---
