# 🎮 Omok Arena - Flutter 프로젝트 종합 현황 프롬프트

## 📋 프로젝트 개요

**프로젝트명**: Omok Arena (오목 아레나)  
**플랫폼**: Flutter (iOS/Android/macOS/Web)  
**버전**: v2.0.0  
**테마**: 키치하고 귀여운 12간지 캐릭터 오목 게임  
**GitHub**: https://github.com/HipsterTerry/omok_game_app  

## 🎯 핵심 기능 구현 현황

### ✅ 완전 구현된 기능들

#### 🎮 게임 시스템
- **오목 게임 로직**: 5목 승리 판정, 렌주룰 (3-3, 4-4, 장목 금지)
- **AI 대전**: Minimax 알고리즘 기반 3단계 난이도
- **로컬 2인 플레이**: 같은 기기에서 턴제 플레이
- **듀얼 타이머**: 전체 5분 + 1수 30초 제한
- **게임 보드**: 13x13, 17x17, 21x21 크기 지원

#### 🐲 12간지 캐릭터 시스템
- **3등급 시스템**: 천급(SSR) / 지급(SR) / 인급(R)
- **고유 스킬**: 각 캐릭터별 특수 능력 (공격/방어/교란/시간조작)
- **승률 보너스**: 등급별 2-15% 승률 증가
- **PNG 이미지**: 실제 12간지 동물 캐릭터 이미지 적용

#### 🎲 가챠 시스템
- **3종 복권**: 동복권(100코인) / 은복권(500코인) / 금복권(1000코인)
- **확률 시스템**: 캐릭터 조각, 아이템, 코인, 경험치 획득
- **캐릭터 수집**: 조각 시스템으로 캐릭터 해금

#### 🎨 UI/UX 시스템
- **키치 테마**: #DFFBFF 배경, #5C47CE 텍스트, #89E0F7 버튼
- **한글 폰트**: Cafe24Ohsquare, SUIT, Pretendard
- **반응형 디자인**: 작은/큰 화면 자동 대응
- **애니메이션**: Bounce, Pulse, Blink 효과

### 🔄 최근 v2.0.0 업데이트 내용

#### 🎨 캐릭터 이미지 통합
- **13개 PNG 파일**: home_logo.png + 12간지 동물 이미지
- **홈화면 로고**: 호랑이+토끼 하이파이브 이미지와 타이틀 Stack 배치
- **캐릭터 선택**: 상단 4개 캐릭터 Bounce 애니메이션 (쥐,양,용,토끼)
- **이미지 fallback**: 로딩 실패시 이모지 자동 대체

#### ⏰ 타이머 시각 효과
- **30초 타이머**: 10초 이하 빨간색 깜빡임 경고
- **AnimationController**: 500ms 주기 색상 전환
- **다중 그림자**: 시각적 경고 강화

#### 💫 UI 개선사항
- **게임 카운트다운**: "3, 2, 1, Start" 단순화
- **버튼 스타일**: 그라데이션, 강화된 테두리, 다중 그림자
- **스킬 버튼**: 텍스트 제거, 아이콘 확대, 티어별 글로우
- **레이아웃 최적화**: 간격 조정, 타이틀 폰트 확대

## 📁 프로젝트 구조

```
omok_game_app/
├── lib/
│   ├── main.dart                           # 앱 진입점
│   ├── screens/                            # 화면들
│   │   ├── home_screen.dart               # 홈화면 (Stack 레이아웃)
│   │   ├── character_selection_screen.dart # 캐릭터 선택 (PNG 이미지)
│   │   ├── enhanced_game_screen.dart      # 메인 게임 화면
│   │   ├── game_screen.dart               # 기본 게임 화면
│   │   ├── lottery_screen.dart            # 가챠 시스템
│   │   └── game_rules_screen.dart         # 게임 규칙 설명
│   ├── widgets/                           # 커스텀 위젯들
│   │   ├── game_timer_widget.dart         # 듀얼 타이머 + 깜빡임
│   │   ├── enhanced_game_board_widget.dart # 게임 보드
│   │   ├── skill_activation_widget.dart   # 스킬 시스템
│   │   ├── game_countdown_overlay.dart    # 카운트다운
│   │   └── enhanced_visual_effects.dart   # 시각 효과
│   ├── models/                            # 데이터 모델
│   │   ├── enhanced_game_state.dart       # 게임 상태
│   │   ├── character.dart                 # 캐릭터 정보
│   │   └── player_profile.dart            # 플레이어 프로필
│   ├── logic/                             # 게임 로직
│   │   ├── omok_game_logic.dart          # 기본 오목 로직
│   │   └── advanced_renju_rule_evaluator.dart # 렌주룰 검증
│   └── theme/
│       └── omok_arena_theme.dart          # 테마 시스템
├── assets/
│   ├── image/                             # 캐릭터 이미지들
│   │   ├── home_logo.png                  # 홈 로고 (1.5MB)
│   │   ├── rat.png, ox.png, tiger.png     # 12간지 동물들
│   │   └── ... (총 13개 PNG 파일)
│   ├── fonts/                             # 한글 폰트들
│   │   ├── Cafe24Ohsquare-v2.0.ttf
│   │   ├── SUIT-Medium.ttf
│   │   └── Pretendard-Light.otf
│   └── audio/                             # 효과음 (예정)
├── README.md                              # 프로젝트 문서
├── CHANGELOG.md                           # 변경사항 로그
├── PULL_REQUEST_REVIEW.md                 # 리뷰 가이드
└── pubspec.yaml                           # 의존성 관리
```

## 🛠️ 기술 스택 및 구현 세부사항

### 📱 Flutter 구성
```yaml
dependencies:
  flutter: sdk: flutter
  audioplayers: ^6.1.0        # 효과음 (미구현)
  
dev_dependencies:
  flutter_test: sdk: flutter
  flutter_lints: ^4.0.0

fonts:
  - family: Cafe24Ohsquare     # 타이틀, 카운트다운
  - family: SUIT               # 버튼, 설명
  - family: Pretendard         # 기타 텍스트
```

### 🎨 핵심 위젯 구조

#### 1. CuteTimerWidget (StatefulWidget)
```dart
class CuteTimerWidget extends StatefulWidget {
  final bool isCurrentPlayer;
  final int remainingTime;
  final String playerName;
  final Color themeColor;
  
  // 10초 이하시 빨간색 깜빡임 애니메이션
  // AnimationController + Color.lerp 사용
}
```

#### 2. 홈화면 Stack 레이아웃
```dart
Container(
  height: isSmallScreen ? 240 : 280,
  child: Stack(
    children: [
      Positioned(top: 0, child: Image.asset('assets/image/home_logo.png')),
      Positioned(bottom: 0, child: Text('Omok Arena')),
    ],
  ),
)
```

#### 3. 캐릭터 이미지 시스템
```dart
String _getCharacterImagePath(CharacterType type) {
  switch (type) {
    case CharacterType.rat: return 'assets/image/rat.png';
    case CharacterType.ox: return 'assets/image/ox.png';
    // ... 12간지 모든 캐릭터
  }
}

// errorBuilder로 fallback 처리
Image.asset(imagePath, errorBuilder: (context, error, stackTrace) {
  return Text(getCharacterEmoji(type)); // 이모지 대체
})
```

### 🎮 게임 로직 구현

#### 오목 승리 판정
```dart
bool checkWin(List<List<PlayerType?>> board, int row, int col, PlayerType player) {
  // 4방향 (가로, 세로, 대각선) 체크
  // 정확히 5개 연속인지 확인 (6개 이상 장목 방지)
}
```

#### 렌주룰 검증
```dart
class AdvancedRenjuRuleEvaluator {
  static bool isThreeThree(board, row, col) { /* 3-3 금수 */ }
  static bool isFourFour(board, row, col) { /* 4-4 금수 */ }
  static bool isOverline(board, row, col) { /* 장목 금수 */ }
}
```

#### AI 알고리즘
```dart
int minimax(board, depth, isMaximizing, alpha, beta) {
  // Minimax with Alpha-Beta Pruning
  // 3단계 난이도별 depth 조정
}
```

### 🐲 캐릭터 시스템 데이터

#### 캐릭터 등급 및 스킬
```dart
enum CharacterTier { heaven, earth, human } // 천급, 지급, 인급

class Character {
  final CharacterType type;
  final String name;
  final String skill;
  final CharacterTier tier;
  final double winRateBonus; // 2-15%
  final String imagePath;    // PNG 경로
}

// 예시: 청룡 (천급)
Character(
  type: CharacterType.dragon,
  name: "청룡",
  skill: "천둥번개: 상대방의 다음 수 무효화",
  tier: CharacterTier.heaven,
  winRateBonus: 0.15,
  imagePath: "assets/image/dragon.png",
)
```

### 🎨 테마 시스템

#### 색상 팔레트
```dart
class OmokArenaTheme {
  static const Color background = Color(0xFFDFFFBF);      // 연한 청록
  static const Color backgroundSecondary = Color(0xFFF4FEFF);
  static const Color primaryText = Color(0xFF5C47CE);      // 보라색
  static const Color buttonColor = Color(0xFF89E0F7);      // 하늘색
  static const Color accentColor = Color(0xFF51D4EB);      // 청록색
  static const Color shadowColor = Color(0xFF8BBEDC);      // 회청색
}
```

#### 반응형 디자인
```dart
bool isSmallScreen = MediaQuery.of(context).size.width < 400;

// 크기 조정 예시
fontSize: isSmallScreen ? 42 : 52,
imageSize: isSmallScreen ? Size(450, 225) : Size(550, 275),
padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
```

## 🚀 현재 구현 상태 및 이슈

### ✅ 완료된 기능들
- [x] 기본 오목 게임 로직 (승리 판정, 렌주룰)
- [x] 12간지 캐릭터 시스템 (PNG 이미지 포함)
- [x] AI 대전 (3단계 난이도)
- [x] 가챠 시스템 (3종 복권)
- [x] 듀얼 타이머 (5분 + 30초)
- [x] 키치 테마 UI/UX
- [x] 반응형 디자인
- [x] 애니메이션 효과 (깜빡임, Bounce 등)
- [x] 완전한 문서화

### 🔄 부분 구현 / 개선 필요
- [ ] **온라인 멀티플레이**: 서버 연동 미구현
- [ ] **효과음 시스템**: audioplayers 설정만 완료
- [ ] **이미지 최적화**: 20MB+ 용량 압축 필요
- [ ] **성능 최적화**: 메모리 사용량 개선
- [ ] **추가 애니메이션**: 게임 진행 중 시각 효과

### ⚠️ 알려진 이슈들
- **앱 크기**: 이미지 파일로 인한 용량 증가 (20MB+)
- **초기 로딩**: 다중 이미지 로딩 시간
- **메모리 사용**: 동시 애니메이션 실행시 부하
- **폰트 렌더링**: 일부 기기에서 한글 폰트 이슈

## 📊 프로젝트 통계

### 📈 코드 규모
- **총 파일 수**: 44개
- **코드 라인 수**: 약 9,000줄
- **이미지 파일**: 13개 (총 20MB+)
- **폰트 파일**: 3개 (총 4MB+)

### 🎯 화면 구성
1. **홈화면**: 캐릭터 로고 + 게임 모드 선택
2. **캐릭터 선택**: 12간지 캐릭터 카드 + 상단 애니메이션
3. **게임 화면**: 오목 보드 + 타이머 + 스킬 버튼
4. **가챠 화면**: 3종 복권 + 인벤토리
5. **규칙 설명**: 렌주룰 및 스킬 설명

### 🔧 개발 환경
- **Flutter**: 3.8.1+
- **Dart**: 언어
- **IDE**: Android Studio / VS Code
- **버전 관리**: Git + GitHub
- **플랫폼**: iOS, Android, macOS, Web

## 🎯 향후 개발 계획

### v2.1.0 예정 기능
- [ ] 이미지 최적화 및 압축
- [ ] 효과음 시스템 완성
- [ ] 추가 시각 효과 및 애니메이션
- [ ] 성능 최적화

### v3.0.0 장기 계획
- [ ] 온라인 멀티플레이 (Firebase)
- [ ] 랭킹 시스템
- [ ] 친구 시스템
- [ ] 토너먼트 모드

---

**📝 참고사항**: 이 프로젝트는 Flutter로 제작된 완전한 오목 게임으로, 12간지 캐릭터 시스템과 키치한 UI/UX가 특징입니다. 모든 기본 기능이 구현되어 있으며, v2.0.0에서 캐릭터 이미지 통합과 UI 대폭 개선이 완료되었습니다. 