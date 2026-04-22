# Website MenuBar

자주 방문하는 웹사이트를 맥 메뉴바에 모아두고 클릭 한 번으로 여는 가벼운 macOS 앱.

- SwiftUI `MenuBarExtra` 기반, Dock 아이콘 없음 (`LSUIElement`)
- 로컬 JSON 저장 (`~/Library/Application Support/WebsiteMenuBar/websites.json`)
- 추가 / 편집 / 삭제 / 드래그 순서 변경
- Universal binary (Apple Silicon + Intel), macOS 13+

## 설치

1. [Releases](https://github.com/hanolee/mac-website-menubar-app/releases)에서 `WebsiteMenuBar-x.y.z.zip` 다운로드
2. 압축 해제 후 `WebsiteMenuBar.app`을 `/Applications/`로 이동
3. 첫 실행은 Gatekeeper 때문에 우클릭 → "열기"

ad-hoc 서명이라 Apple 공증은 되어 있지 않습니다. 직접 빌드하려면 아래를 참고하세요.

## 빌드

요구사항: macOS 13+, Xcode Command Line Tools

```bash
git clone https://github.com/hanolee/mac-website-menubar-app.git
cd mac-website-menubar-app
./build-app.sh            # 기본: v1.0.0
./build-app.sh 1.2.0 5    # 버전/빌드번호 지정
open WebsiteMenuBar.app
```

개발 중에는 `swift run`으로도 실행 가능하지만 `LSUIElement`가 적용되지 않아 Dock 아이콘이 표시됩니다. 메뉴바 전용 동작은 `.app` 번들로 확인하세요.

## 구조

```
Sources/WebsiteMenuBar/
├── App.swift                 # @main, MenuBarExtra + Window 씬
├── Website.swift             # 모델
├── WebsiteStore.swift        # JSON 영속 계층
├── MenuContentView.swift     # 메뉴바 팝오버 UI
└── ManageWebsitesView.swift  # 관리 창
```

## 라이선스

MIT
