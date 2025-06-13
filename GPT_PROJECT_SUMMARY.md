# 🎮 Omok Arena - 프로젝트 요약 프롬프트

## 📋 기본 정보
**Flutter 오목 게임 앱** | **v2.0.0** | **12간지 캐릭터 시스템** | **키치 테마**

## 🎯 핵심 구현 완료 기능

### 🎮 게임 시스템
- 오목 게임 로직 (5목 승리, 렌주룰 3-3/4-4/장목 금지)
- AI 대전 (Minimax 알고리즘, 3단계 난이도)
- 로컬 2인 플레이
- 듀얼 타이머 (전체 5분 + 1수 30초, 10초 이하 빨간색 깜빡임)

### 🐲 캐릭터 시스템
- 12간지 동물 캐릭터 (천급/지급/인급, 2-15% 승률 보너스)
- 각 캐릭터별 고유 스킬 (공격/방어/교란/시간조작)
- PNG 이미지 적용 (13개 파일, 총 20MB+)
- 가챠 시스템 (3종 복권, 확률형 보상)

### 🎨 UI/UX
- 키치 테마 (#DFFBFF 배경, #5C47CE 텍스트, #89E0F7 버튼)
- 한글 폰트 3종 (Cafe24Ohsquare, SUIT, Pretendard)
- 반응형 디자인 (작은/큰 화면 대응)
- 애니메이션 효과 (Bounce, Pulse, Blink)

## 📁 주요 파일 구조
```
lib/
├── screens/ (홈, 캐릭터선택, 게임, 가챠, 규칙)
├── widgets/ (타이머, 게임보드, 스킬, 시각효과)
├── models/ (게임상태, 캐릭터, 플레이어)
├── logic/ (오목로직, 렌주룰검증)
└── theme/ (테마시스템)

assets/
├── image/ (13개 PNG: home_logo + 12간지)
└── fonts/ (3개 한글폰트)
```

## 🔧 핵심 기술 구현

### 타이머 깜빡임 (v2.0.0 신규)
```dart
class CuteTimerWidget extends StatefulWidget {
  // 10초 이하시 AnimationController로 빨간색 깜빡임
  // Color.lerp + 다중 그림자 효과
}
```

### 홈화면 Stack 레이아웃 (v2.0.0 신규)
```dart
Stack(
  children: [
    Positioned(top: 0, child: Image.asset('home_logo.png')), // 호랑이+토끼
    Positioned(bottom: 0, child: Text('Omok Arena')), // 타이틀 겹치기
  ],
)
```

### 캐릭터 이미지 시스템 (v2.0.0 신규)
```dart
Image.asset('assets/image/dragon.png', 
  errorBuilder: (context, error, stackTrace) => Text('🐉') // fallback
)
```

## 🚀 현재 상태
- ✅ **완전 구현**: 게임로직, 캐릭터시스템, UI/UX, 이미지통합
- 🔄 **부분 구현**: 효과음(설정만), 온라인플레이(미구현)
- ⚠️ **이슈**: 앱크기 20MB+, 초기로딩시간, 메모리사용량

## 📊 통계
- **44개 파일**, **9,000줄 코드**
- **5개 화면** (홈, 캐릭터선택, 게임, 가챠, 규칙)
- **13개 이미지**, **3개 폰트**

---
**💡 요청사항**: 이 프로젝트 기반으로 [구체적인 요청사항을 여기에 작성] 