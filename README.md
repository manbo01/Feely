# Feely - 감정 일기 앱

감정 변화를 기록하고 시각적으로 확인하는 iOS/Android 크로스플랫폼 앱입니다.

## 기술 스택

- Flutter (Dart)
- Provider (상태 관리)
- Hive (로컬 저장)
- flutter_local_notifications (알림)

## 실행 방법

1. [Flutter SDK](https://flutter.dev/docs/get-started/install) 설치
2. 프로젝트 루트에서:
   ```bash
   flutter pub get
   flutter run
   ```
3. iOS/Android 플랫폼 폴더가 불완전한 경우, 기존 `lib/`와 `pubspec.yaml`을 유지한 채로 플랫폼만 다시 생성하려면:
   ```bash
   flutter create . --project-name feely
   ```
   (이미 있는 Dart/설정 파일은 덮어쓰지 않도록 주의)

## 구현된 기능

- **감정 일기**: 날짜, 날씨/장소(텍스트 입력), 감정 태그, 감정 강도(1~10), 본문, 사진 1장 첨부
- **메인 화면**: 월별 캘린더, 날짜별 일기 목록, 일기 유무 표시, FAB으로 일기 쓰기
- **일기 쓰기/편집**: 저장·수정, 작성/수정 시간 자동 기록
- **일기 상세**: 카드 탭 시 상세 보기, 편집 버튼으로 수정 화면 이동
- **설정**: 테마 5종(라이트, 다크, 블루, 그린, 퍼플), 일기 작성 알림 on/off, 알림 시간 설정
- **로컬 알림**: 지정한 시간에 일기 작성 알림 (권한 필요)

## 장소 선택 지도 (네이버 지도)

- **네이버 지도** 사용. 서비스 환경 등록 후 Client ID가 필요합니다.
- Client ID 설정: [lib/config/naver_map_config.dart](lib/config/naver_map_config.dart)에서 `naverMapClientId` 값을 네이버 클라우드 콘솔 **인증정보 > Client ID**로 바꾸세요.

## 후순위(미구현)

- 감정 분석·요약
- 그룹 공유, 클라우드 백업
