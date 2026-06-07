# Bookly

Bookly는 사용자 맞춤형 iOS 독서 기록 앱입니다.

카카오 도서 검색 API를 활용해 도서 정보를 불러오며, 사용자는 책을 `WISH`, `READING`, `DONE` 상태로 분류해 관리할 수 있습니다.

## 주요 기능

```text
도서 검색
도서 상세 정보 확인
나의 서재에 책 저장
WISH / READING / DONE 상태 관리
읽고 있는 책 진행률 기록
홈 화면 도서 추천 및 독서 상태 분석
독서 카드 발행
```

## 기술 스택

```text
Swift
UIKit
Kakao Book Search API
Xcode
```

## Kakao Book API 설정 방법

이 프로젝트는 카카오 도서 검색 API를 사용합니다.
API 키는 보안을 위해 GitHub에 업로드하지 않고 `Secrets.xcconfig` 파일에서 관리합니다.

### 1. REST API 키 발급

Kakao Developers에서 애플리케이션을 생성한 뒤 REST API 키를 발급받습니다.

### 2. Secrets.xcconfig 파일 생성

`Bookly/Config` 폴더에 있는 예시 파일을 복사합니다.

```text
Secrets.xcconfig.example
```

복사한 파일명을 아래처럼 변경합니다.

```text
Secrets.xcconfig
```

### 3. API 키 입력

`Secrets.xcconfig` 파일에 본인의 REST API 키를 입력합니다.

```xcconfig
KAKAO_REST_API_KEY = YOUR_KAKAO_REST_API_KEY
```

주의: `KakaoAK`는 붙이지 않습니다.
앱 코드에서 API 요청 시 자동으로 `KakaoAK`를 붙입니다.

### 4. Xcode 설정 확인

Xcode에서 아래 설정을 확인합니다.

```text
PROJECT > Bookly > Info > Configurations
```

`Debug`와 `Release`의 Bookly 항목이 `Secrets.xcconfig`를 사용하도록 설정되어 있어야 합니다.

또한 `Info.plist`에는 아래 항목이 필요합니다.

```text
KAKAO_REST_API_KEY = $(KAKAO_REST_API_KEY)
```

## 보안 주의사항

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
