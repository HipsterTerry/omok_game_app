# 🎮 Omok Arena - Flutter 십이지 오목 게임

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20macOS%20%7C%20Web-lightgrey?style=for-the-badge)

**한국 전통 오목과 현대적 RPG 요소를 결합한 혁신적인 Flutter 게임**

## 📱 프로젝트 개요

Omok Arena는 전통적인 오목(五목/Gomoku) 게임에 12십이지 캐릭터 시스템과 현대적인 UI/UX를 결합한 크로스 플랫폼 모바일 게임입니다.

### ✨ 핵심 특징

- 🎯 **정규 오목 규칙**: 렌주(Renju) 규칙 완전 구현
- 🐲 **12십이지 캐릭터**: 고유 스킬을 가진 수집형 캐릭터 시스템
- ⏰ **프로 타이머**: 5분 총시간 + 30초 1수 제한 듀얼 타이머
- 🤖 **AI 대전**: 3단계 난이도의 지능형 AI 상대
- 🎰 **복권 시스템**: 코인으로 캐릭터를 획득하는 가챠 시스템
- 🎨 **아름다운 UI**: 전통 바둑판과 현대적 애니메이션의 조화

## 🎮 게임 시스템

### 🏁 게임 모드
- **👥 멀티플레이어**: 로컬 2인 대전
- **🤖 AI 대전**: 쉬움/보통/어려움 3단계
- **📏 다중 보드**: 13×13(초급) / 17×17(중급) / 21×21(고급)

### 🐲 캐릭터 시스템
| 등급 | 캐릭터 | 스킬 타입 |
|------|--------|-----------|
| **천급(SSR)** | 용🐉, 호랑이🐅, 원숭이🐒, 닭🐓 | 고급 스킬 |
| **지급(SR)** | 소🐂, 말🐴, 개🐕, 돼지🐷 | 중급 스킬 |
| **인급(R)** | 쥐🐭, 토끼🐰, 뱀🐍, 양🐑 | 기본 스킬 |

### ⚔️ 스킬 시스템
- **🗡️ 공격형**: 상대의 수를 제한하거나 돌을 제거
- **🛡️ 수비형**: 자신의 시간을 늘리거나 보호막 생성
- **💥 방해형**: 상대의 스킬을 차단하거나 혼란 유발
- **⏰ 시간조작**: 시간 조작 및 추가 턴 획득

## 🎯 렌주 규칙

정통 렌주 규칙을 완벽 구현:
- **흑돌 금수**: 3-3, 4-4, 장목(6목 이상) 금지
- **백돌 자유**: 모든 수가 허용
- **5목 우선**: 금수보다 5목 완성이 우선

## 🛠️ 기술 스택

### 📱 프론트엔드
- **Flutter 3.x**: 크로스 플랫폼 UI 프레임워크
- **Dart**: 프로그래밍 언어
- **CustomPainter**: 고성능 보드 렌더링

### 🧠 게임 로직
- **Minimax 알고리즘**: AI 사고 엔진
- **Alpha-Beta 가지치기**: 성능 최적화
- **렌주 규칙 검증**: 실시간 금수 판별

### 🎵 멀티미디어
- **SystemSound**: 네이티브 사운드 효과
- **HapticFeedback**: 햅틱 피드백
- **Animation Controller**: 부드러운 애니메이션

## 📱 지원 플랫폼

- ✅ **iOS**: iPhone, iPad
- ✅ **Android**: 스마트폰, 태블릿
- ✅ **macOS**: 데스크톱
- ✅ **Web**: 모든 모던 브라우저

## 🚀 시작하기

### 📋 사전 요구사항

```bash
# Flutter SDK 설치 (3.0.0+)
flutter --version

# 의존성 설치
flutter pub get
```

### 🏃‍♂️ 실행하기

```bash
# 개발 모드 실행
flutter run

# 특정 플랫폼 실행
flutter run -d macos
flutter run -d chrome
flutter run -d ios
```

### 📦 빌드하기

```bash
# iOS 빌드
flutter build ios

# Android 빌드
flutter build apk

# macOS 빌드
flutter build macos

# 웹 빌드
flutter build web
```

## 📁 프로젝트 구조

```
lib/
├── 📱 screens/          # 화면 구성요소
│   ├── home_screen.dart
│   ├── character_selection_screen.dart
│   ├── enhanced_game_screen.dart
│   ├── lottery_screen.dart
│   └── game_rules_screen.dart
│
├── 🎨 widgets/          # 재사용 가능한 위젯
│   ├── enhanced_game_board_widget.dart
│   ├── game_timer_widget.dart
│   ├── character_card_widget.dart
│   └── animated_stone_widget.dart
│
├── 🧠 logic/           # 게임 로직
│   ├── omok_game_logic.dart
│   ├── ai_player.dart
│   └── renju_rule_checker.dart
│
├── 📊 models/          # 데이터 모델
│   ├── enhanced_game_state.dart
│   ├── character.dart
│   └── player_profile.dart
│
└── 🔊 services/        # 서비스 레이어
    ├── sound_manager.dart
    └── character_service.dart
```

## 🎯 주요 알고리즘

### 🧠 AI 사고 엔진
```dart
class AIPlayer {
  // Minimax with Alpha-Beta Pruning
  int minimax(List<List<PlayerType?>> board, int depth, 
             bool isMaximizing, int alpha, int beta) {
    // 승리 조건 체크
    // 휴리스틱 평가
    // 재귀적 탐색
  }
}
```

### ⚡ 렌주 규칙 검증
```dart
class RenjuRuleChecker {
  // 3-3 금수 체크
  static bool isThreeThree(board, position) { /* ... */ }
  
  // 4-4 금수 체크  
  static bool isFourFour(board, position) { /* ... */ }
  
  // 장목 금수 체크
  static bool isOverline(board, position) { /* ... */ }
}
```

## 🎨 UI/UX 특징

### 🌈 시각적 개선사항
- **격자선 강화**: 외곽선, 중앙선, 그림자 효과
- **화점 3D 효과**: 그라데이션과 하이라이트
- **마지막 수 강조**: 다중 링과 십자가 표시
- **호버 효과**: 실시간 미리보기

### ⏰ 타이머 시스템
- **듀얼 타이머**: 전체 5분 + 1수 30초
- **자동 리셋**: 수 완료 시 30초 충전
- **시각적 경고**: 시간 부족 시 펄스 애니메이션

## 🔧 개발 환경

### 🛠️ IDE 설정
- **권장**: Android Studio + Flutter Plugin
- **대안**: VS Code + Dart Extension

### 🐛 디버깅
```bash
# 디버그 모드
flutter run --debug

# 프로파일 모드  
flutter run --profile

# 릴리즈 모드
flutter run --release
```

## 📈 성능 최적화

- **CustomPainter**: 하드웨어 가속 렌더링
- **memo화**: 상태 변경 최소화
- **Lazy Loading**: 필요시에만 리소스 로드
- **메모리 관리**: 적절한 dispose 패턴

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 `LICENSE` 파일을 참조하세요.

## 📞 연락처

**프로젝트 링크**: [https://github.com/yourusername/omok_game_app](https://github.com/yourusername/omok_game_app)

## 🙏 감사의 말

- Flutter 팀의 훌륭한 프레임워크
- 한국 전통 오목 문화에 대한 존경
- 오픈소스 커뮤니티의 지원

---

**⭐ 별표를 눌러주시면 프로젝트 발전에 큰 도움이 됩니다!**
