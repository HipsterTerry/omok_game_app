# 렌주룰 기능 통합 가이드

## 📦 개요

기존 오목 게임 기능을 **절대 수정하지 않고**, 고급 난이도에서만 작동하는 렌주룰과 시각 이펙트를 외부에서 추가했습니다.

## ✅ 구현된 기능

### 1. 새로운 유틸 클래스
- **`AdvancedRenjuRuleEvaluator`**: 렌주룰 계산 로직
- **`ForbiddenType`**: 금지 타입 enum (삼삼, 사사, 장목, 사삼)

### 2. 새로운 UI 위젯
- **`ForbiddenMoveOverlay`**: 금지 위치 X 마크 표시
- **`RenjuWarningOverlay`**: 금지 수 클릭 시 경고 메시지
- **`EnhancedGameBoardWrapper`**: 기존 게임판을 감싸는 래퍼

### 3. 렌주룰 적용 기준
- **삼삼/사사/장목**: 모든 난이도에서 적용
- **사삼**: `AIDifficulty.hard` 일 때만 금지
- **흑돌만**: 백돌에는 렌주룰 적용 안함

## 🛠️ 파일 구조

```
lib/
├── logic/
│   └── advanced_renju_rule_evaluator.dart  # 새로 추가
├── widgets/
│   ├── forbidden_move_overlay.dart         # 새로 추가
│   ├── renju_warning_overlay.dart          # 새로 추가
│   └── enhanced_game_board_wrapper.dart    # 새로 추가
└── screens/
    └── renju_rule_demo_screen.dart         # 데모용
```

## 🎯 사용 방법

### 기본 사용법

기존 `EnhancedGameBoardWidget` 대신 `EnhancedGameBoardWrapper`를 사용:

```dart
// 기존 코드 (수정 안함)
EnhancedGameBoardWidget(
  gameState: gameState,
  onTileTap: onTileTap,
  boardSizeType: BoardSize.large,
)

// 새로운 래퍼 사용
EnhancedGameBoardWrapper(
  gameState: gameState,
  onTileTap: onTileTap,
  boardSizeType: BoardSize.large,
  aiDifficulty: AIDifficulty.hard,  // 렌주룰 적용 레벨
)
```

### 렌주룰 체크 API

```dart
// 금지 위치 목록 가져오기
List<Position> forbiddenPositions = AdvancedRenjuRuleEvaluator.getForbiddenPositions(
  board,
  currentPlayer,
  aiDifficulty,
);

// 특정 위치 금지 타입 확인
ForbiddenType type = AdvancedRenjuRuleEvaluator.getForbiddenTypeAt(
  board,
  row,
  col, 
  currentPlayer,
  aiDifficulty,
);

// 금지 메시지 가져오기
String message = AdvancedRenjuRuleEvaluator.getForbiddenMessage(type);
```

## 🎮 데모 실행

렌주룰 기능을 테스트하려면:

```dart
// main.dart에 추가
import 'screens/renju_rule_demo_screen.dart';

// 또는 직접 이동
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const RenjuRuleDemoScreen(),
  ),
);
```

## 🎨 시각 효과

### 금지 위치 표시
- **X 마크**: 빨간색 반투명 아이콘
- **클릭 가능**: 터치 시 경고 메시지 표시
- **흑돌만**: 백돌 차례에는 표시 안함

### 경고 메시지
- **자동 사라짐**: 0.8초 후 자동 제거
- **애니메이션**: 페이드인/스케일 효과
- **타입별 메시지**:
  - 삼삼입니다!
  - 사사입니다!  
  - 장목입니다!
  - 사삼입니다! (고급만)

## 🔧 기존 프로젝트 통합

### 1. enhanced_game_screen.dart 수정

```dart
// 기존 import에 추가
import '../widgets/enhanced_game_board_wrapper.dart';

// build 메서드에서 게임판 위젯 교체
child: EnhancedGameBoardWrapper(  // 기존: EnhancedGameBoardWidget
  gameState: _gameState,
  onTileTap: _handleTileTap,
  boardSizeType: _getBoardSizeType(),
  aiDifficulty: widget.aiDifficulty,  // 새로 추가
),
```

### 2. 난이도별 렌주룰 적용

```dart
BoardSize _getBoardSizeType() {
  // 기존 로직...
}

bool _isAdvancedRenjuRule() {
  return widget.aiDifficulty == AIDifficulty.hard;
}
```

## ⚡ 성능 최적화

### 렌주룰 계산 최적화
- **필요시에만**: 흑돌 차례에만 계산
- **캐싱**: 동일한 보드 상태는 캐시 가능
- **부분 계산**: 변경된 부분만 재계산

### UI 최적화
- **조건부 렌더링**: 백돌 차례에는 오버레이 숨김
- **경량 위젯**: 최소한의 위젯 트리 구성

## 🐛 주의사항

### 메모리 관리
```dart
@override
void dispose() {
  RenjuWarningHelper.hideWarning();  // 경고 오버레이 정리
  super.dispose();
}
```

### 상태 동기화
- 게임 상태 변경 시 오버레이도 함께 업데이트
- 렌주룰 계산은 최신 보드 상태 기준

## 📋 테스트 체크리스트

- [ ] 삼삼 금지 (열린 3이 2개 이상)
- [ ] 사사 금지 (열린 4가 2개 이상)  
- [ ] 장목 금지 (6목 이상)
- [ ] 사삼 금지 (고급 난이도만)
- [ ] 백돌은 렌주룰 적용 안함
- [ ] X 마크 클릭 시 경고 메시지
- [ ] 경고 메시지 자동 사라짐
- [ ] 금지 수 클릭 차단
- [ ] 유효한 수는 정상 진행

## 🔄 롤백 방법

렌주룰 기능을 제거하려면:

1. `EnhancedGameBoardWrapper` → `EnhancedGameBoardWidget`로 변경
2. `aiDifficulty` 파라미터 제거
3. 새로 생성한 파일들 삭제

기존 코드는 전혀 수정되지 않았으므로 완전한 롤백 가능합니다.

## 📞 지원

문제가 발생하면:
1. 데모 화면에서 먼저 테스트
2. 브라우저 개발자 도구에서 콘솔 확인
3. 렌주룰 로직은 `AdvancedRenjuRuleEvaluator`에서 디버깅 