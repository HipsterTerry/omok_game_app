# 🛠️ 개발자 가이드 (Development Guide)

## 📋 목차
1. [프로젝트 구조](#프로젝트-구조)
2. [UI 시스템](#ui-시스템)
3. [게임 로직](#게임-로직)
4. [주요 컴포넌트](#주요-컴포넌트)
5. [개발 규칙](#개발-규칙)

## 🏗️ 프로젝트 구조

### 📁 디렉토리 구조
```
lib/
├── screens/                    # 화면 컴포넌트
│   ├── home_screen.dart       # 홈 화면 (오버플로우 해결됨)
│   ├── character_selection_screen.dart  # 캐릭터 선택
│   ├── enhanced_game_screen.dart        # 메인 게임 화면
│   ├── lottery_screen.dart    # 복권/가챠 시스템
│   └── game_rules_screen.dart # 게임 규칙 설명
│
├── widgets/                   # 재사용 위젯
│   ├── enhanced_game_board_widget.dart # 오목판 렌더링
│   ├── skill_activation_widget.dart    # 스킬 효과 시스템
│   ├── game_timer_widget.dart # 듀얼 타이머
│   └── character_card_widget.dart      # 캐릭터 카드
│
├── logic/                     # 게임 로직
│   ├── omok_game_logic.dart   # 핵심 오목 규칙
│   ├── ai_player.dart         # AI 알고리즘
│   └── renju_rule_checker.dart # 렌주 규칙 검증
│
├── models/                    # 데이터 모델
│   ├── enhanced_game_state.dart # 게임 상태 관리
│   ├── character.dart         # 캐릭터 정보
│   └── player_profile.dart    # 플레이어 프로필
│
└── services/                  # 서비스 레이어
    ├── sound_manager.dart     # 사운드 관리
    └── character_service.dart # 캐릭터 서비스
```

## 🎨 UI 시스템

### 🎯 2024.12.28 완전 개선된 UI 시스템

#### 📝 폰트 시스템
```dart
// 3단계 폰트 계층 구조
const String TITLE_FONT = 'Cafe24Ohsquare';    // 타이틀, 강조
const String PRIMARY_FONT = 'SUIT';             // 기본 텍스트, 버튼
const String SECONDARY_FONT = 'Pretendard';     // 부제목, 설명

// 사용 예시
Text(
  '오목 게임',
  style: TextStyle(
    fontFamily: TITLE_FONT,     // 타이틀용
    fontSize: 36,
    fontWeight: FontWeight.bold,
  ),
)
```

#### 🌈 색상 시스템
```dart
// 통일된 색상 테마
class AppColors {
  static const Color background = Color(0xFFFDF7E3);  // 따뜻한 크림
  static const Color mainText = Color(0xFF2D2D2D);    // 진한 회색
  static const Color button = Color(0xFFFFD966);      // 노란색
  static const Color accentPink = Color(0xFFFFA3A3);  // 핑크
  static const Color accentBlue = Color(0xFFA3D8F4);  // 하늘색
}

// 모든 화면에 일관되게 적용
Container(
  decoration: const BoxDecoration(
    color: AppColors.background,
  ),
  child: AppBar(
    backgroundColor: AppColors.background,
    foregroundColor: AppColors.mainText,
  ),
)
```

#### 📱 레이아웃 시스템
```dart
// 오버플로우 방지 패턴 (홈 스크린에서 완전 해결됨)
SingleChildScrollView(
  child: Container(
    decoration: const BoxDecoration(
      color: AppColors.background,
    ),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 10.0,  // 축소된 패딩
        ),
        child: Column(
          children: [
            // 컨텐츠들...
          ],
        ),
      ),
    ),
  ),
)
```

## 🎮 게임 로직

### 🏆 승리 판정 시스템 (완전 검증됨)
```dart
// lib/logic/omok_game_logic.dart
class OmokGameLogic {
  static const int winCondition = 5; // 5목으로 승리

  /// 승리 조건 확인 - 가로/세로/대각선 모든 방향 검사
  static PlayerType? checkWinner(
    List<List<PlayerType?>> board,
    Position lastMove,
  ) {
    final player = board[lastMove.row][lastMove.col];
    if (player == null) return null;

    // 4방향 검사: 가로, 세로, 우하향 대각선, 좌하향 대각선
    final directions = [
      [0, 1],  // 가로 →
      [1, 0],  // 세로 ↓
      [1, 1],  // 우하향 대각선 ↘
      [1, -1], // 좌하향 대각선 ↙
    ];

    for (final direction in directions) {
      final count = 1 +
        countDirection(board, lastMove, player, direction[0], direction[1]) +
        countDirection(board, lastMove, player, -direction[0], -direction[1]);

      if (count >= winCondition) {
        return player; // 5목 달성!
      }
    }

    return null; // 승리 조건 미충족
  }
}
```

### 🚫 렌주룰 시스템 (완전 적용됨)
```dart
// lib/logic/renju_rule_checker.dart
class RenjuRuleChecker {
  /// 렌주 룰 위반 체크 (흑돌만 적용)
  static bool isValidMove(
    List<List<PlayerType?>> board,
    int row,
    int col,
    PlayerType player,
  ) {
    if (player != PlayerType.black) {
      return true; // 백돌은 렌주 룰 적용 안함
    }

    // 임시로 돌 놓기
    board[row][col] = player;

    bool isValid = true;

    // 삼삼 체크: 두 개의 열린 3을 동시에 만드는 수
    if (_hasDoubleThree(board, row, col, player)) {
      isValid = false;
    }

    // 사사 체크: 두 개의 4를 동시에 만드는 수
    if (_hasDoubleFour(board, row, col, player)) {
      isValid = false;
    }

    // 장목 체크: 6목 이상 연속
    if (_hasOverline(board, row, col, player)) {
      isValid = false;
    }

    // 임시 돌 제거
    board[row][col] = null;

    return isValid;
  }
}
```

## ⚡ 주요 컴포넌트

### 🎭 스킬 효과 시스템 (액션 RPG 스타일)
```dart
// lib/widgets/skill_activation_widget.dart

/// 순수 비주얼 스킬 효과 - 텍스트 설명 완전 제거됨
class SkillActivationWidget extends StatelessWidget {
  
  /// 일반 스킬: 1초간 방사형 그라데이션 효과
  void _showNormalSkillEffect() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(seconds: 1),
        builder: (context, value, child) {
          return Center(
            child: Transform.scale(
              scale: value * 2,
              child: Opacity(
                opacity: 1 - value,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.accentPink.withOpacity(0.8),
                        AppColors.accentBlue.withOpacity(0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        onEnd: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  /// 메가 스킬: 2초간 전체화면 확장 링 + 캐릭터 아이콘
  void _showMegaSkillEffect() {
    // 햅틱 피드백
    HapticFeedback.heavyImpact(); // 발동시 강한 진동
    
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(seconds: 2),
        builder: (context, value, child) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 확장하는 링 효과
                Transform.scale(
                  scale: value * 5,
                  child: Opacity(
                    opacity: 1 - value,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.accentPink,
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // 캐릭터 아이콘
                Icon(
                  Icons.star,
                  size: 80,
                  color: AppColors.accentPink,
                ),
              ],
            ),
          );
        },
        onEnd: () {
          HapticFeedback.lightImpact(); // 완료시 약한 진동
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
```

### 🎯 게임 보드 렌더링
```dart
// lib/widgets/enhanced_game_board_widget.dart

/// 고성능 CustomPainter 기반 오목판
class EnhancedOmokBoardPainter extends CustomPainter {
  
  @override
  void paint(Canvas canvas, Size size) {
    // 1. 배경 그리기 (새로운 크림색 배경)
    final backgroundPaint = Paint()..color = AppColors.background;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // 2. 격자선 그리기 (외곽선, 중앙선, 그림자 효과)
    _drawGridLines(canvas, size);
    
    // 3. 화점 그리기 (3D 효과)
    _drawStarPoints(canvas, size);
    
    // 4. 돌 그리기
    _drawStones(canvas, size);
    
    // 5. 마지막 수 강조 (다중 링과 십자가)
    _drawLastMoveHighlight(canvas, size);
    
    // 6. 승리 라인 표시
    _drawWinningLine(canvas, size);
  }
}
```

## 📏 개발 규칙

### ✅ 코딩 컨벤션
1. **폰트 사용**: 3단계 시스템 (Cafe24Ohsquare, SUIT, Pretendard) 준수
2. **색상 사용**: AppColors 클래스의 정의된 색상만 사용
3. **레이아웃**: SingleChildScrollView + SafeArea + 적절한 패딩
4. **스킬 효과**: 텍스트 설명 금지, 순수 비주얼만 허용
5. **주석**: 모든 핵심 함수에 상세한 주석 작성

### 🔧 성능 최적화
1. **메모리 관리**: 불필요한 위젯 재생성 방지
2. **애니메이션**: TweenAnimationBuilder 활용
3. **렌더링**: CustomPainter로 고성능 그래픽
4. **상태 관리**: 필요한 부분만 setState 호출

### 🧪 테스트 가이드
1. **승리 판정**: 가로/세로/대각선 모든 경우 테스트
2. **렌주룰**: 삼삼/사사/장목 금지 확인
3. **UI 일관성**: 모든 화면의 폰트/색상 확인
4. **오버플로우**: 다양한 화면 크기에서 테스트

### 🚀 배포 준비
1. **코드 정리**: 불필요한 print문, 주석 제거
2. **에러 처리**: 모든 예외 상황 처리
3. **성능 프로파일링**: 메모리 누수 확인
4. **다국어**: 하드코딩된 문자열 제거

---

> **중요**: 이 가이드는 2024.12.28 완전 개선된 UI 시스템을 기준으로 작성되었습니다. 모든 개발은 이 기준을 따라야 합니다. 