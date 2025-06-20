# Omok Arena 개발 가이드 📋

> **최종 업데이트**: 2025년 6월 20일 (Figma 기반 UI 시스템 통합 완료)

## 🎯 프로젝트 현재 상태

### ✅ 완료된 주요 기능들

#### 🎨 **UI/UX 시스템 (100% 완료)**
- **Figma 기반 디자인**: 전체 화면 다크 테마 통합
- **색상 시스템**: 기능별 색상 코딩 (파란색/주황색/빨간색/노란색)
- **타이포그래피**: Cafe24Ohsquare 폰트 적용
- **컴포넌트**: 그라데이션 버튼, 카드, 입력 필드 표준화
- **캐릭터 마스코트**: 호랑이🐯, 토끼🐰, 돼지🐷

#### 📱 **화면 구현 (100% 완료)**
1. **스플래시 화면**: 호랑이 캐릭터, 로딩 애니메이션, 스킵 옵션
2. **온보딩 화면**: 4페이지 색상별 소개, 뒤로가기 버튼
3. **로그인 화면**: 돼지 캐릭터, 소셜 로그인, 개선된 레이아웃
4. **회원가입 화면**: 비밀번호 강도 검증, 실시간 유효성 검사
5. **홈 화면**: Figma 스타일 메인 메뉴, 캐릭터 로고
6. **캐릭터 선택**: 12지신 캐릭터, 스킬 정보, 보드 크기 선택
7. **게임 화면**: 향상된 보드, 실시간 타이머, 카운트다운
8. **게임 규칙**: 탭별 규칙 설명 (기본/렌주/전략)
9. **복권 화면**: 코인 시스템, 아이템 획득
10. **비밀번호 찾기**: 이메일 인증 시스템

#### 🎮 **게임 시스템 (90% 완료)**
- **보드 크기**: 13x13, 17x17, 21x21 지원
- **게임 로직**: 5목 승리 조건, 렌주 규칙
- **타이머 시스템**: AnimatedCountdown 위젯 (30초)
- **캐릭터 시스템**: 12지신 캐릭터와 스킬 구조
- **아이템 시스템**: 기본 구조 완성
- **복권 시스템**: 코인/티켓 기반 보상 시스템

#### 🔧 **기술적 구현 (90% 완료)**
- **상태 관리**: Provider 패턴
- **오디오 시스템**: 게임 사운드와 효과음
- **애니메이션**: 페이지 전환, 버튼 효과
- **에러 핸들링**: 이미지 로딩, 네트워크 에러
- **반응형 디자인**: 다양한 화면 크기 지원

## 🚀 다음 작업 우선순위

### 🔥 **높은 우선순위 (즉시 진행 가능)**

#### 1. AI 대전 시스템 구현
```bash
# 작업 위치: lib/logic/ai_player.dart
# 목표: 간단한 AI 알고리즘으로 "AI 연습게임" 버튼 활성화
```
- **미니맥스 알고리즘** 또는 **휴리스틱 기반** AI
- **난이도 설정**: 초급/중급/고급
- **AI 응답 시간**: 1-3초 딜레이로 자연스러운 플레이

#### 2. 캐릭터 스킬 시스템 완성
```bash
# 작업 위치: lib/models/character.dart, lib/widgets/skill_activation_widget.dart
# 목표: 게임당 1회 사용 가능한 캐릭터별 고유 스킬
```
- **12지신 캐릭터별 스킬 정의**
- **스킬 활성화 UI/UX**
- **게임 로직과 연동**
- **쿨다운 및 제한 시스템**

#### 3. 아이템 시스템 완성
```bash
# 작업 위치: lib/models/game_item_enhanced.dart
# 목표: 게임당 2회 사용 가능한 전략적 아이템
```
- **아이템 종류 정의**: 공격/방어/특수
- **사용 제한 로직**: 게임당 2회
- **스킬-아이템 동시 사용 금지**
- **아이템 효과 애니메이션**

### ⚡ **중간 우선순위 (주요 기능)**

#### 4. 온라인 대전 시스템
```bash
# 기술 스택: Firebase Firestore + Real-time Database
# 작업 범위: 매칭, 실시간 동기화, 연결 관리
```
- **Firebase 프로젝트 설정**
- **실시간 게임 상태 동기화**
- **매칭 시스템** (랜덤/친구)
- **연결 끊김 처리**

#### 5. 사용자 인증 시스템
```bash
# 기술 스택: Firebase Auth
# 연동: Google, Apple, 이메일 인증
```
- **소셜 로그인 실제 연동**
- **사용자 프로필 관리**
- **게임 기록 저장**

#### 6. 랭킹 및 통계 시스템
```bash
# 작업 위치: lib/models/rank_system.dart
# 기능: 전국 랭킹, 개인 통계, 업적 시스템
```

### 🔮 **낮은 우선순위 (향후 확장)**

#### 7. 고급 기능들
- **토너먼트 시스템**
- **친구 시스템**
- **상점 시스템** (캐릭터/아이템 구매)
- **업적 및 도전 과제**
- **푸시 알림**

## 🛠️ 개발 환경 설정

### 📋 **프로젝트 클론 및 실행**
```bash
# GitHub에서 클론
git clone https://github.com/HipsterTerry/omok_game_app.git
cd omok_game_app

# 의존성 설치
flutter pub get

# 실행 (Chrome 권장)
flutter run -d chrome
```

### 🔧 **주요 의존성**
```yaml
dependencies:
  flutter: sdk: flutter
  cupertino_icons: ^1.0.8
  audioplayers: ^6.1.0

dev_dependencies:
  flutter_test: sdk: flutter
  flutter_lints: ^5.0.0
```

### 📁 **핵심 폴더 구조**
```
lib/
├── screens/          # 화면 UI (10개 완성)
├── widgets/          # 재사용 위젯 (22개 완성)
├── models/           # 데이터 모델 (8개 완성)
├── logic/            # 게임 로직
├── core/             # 핵심 유틸리티
├── theme/            # 테마 설정
└── services/         # 서비스 레이어
```

## 🎨 디자인 시스템 가이드

### 🎯 **색상 코드**
```dart
// 주요 색상
static const Color primaryBlue = Color(0xFF2196F3);    // AI 연습게임
static const Color orange = Color(0xFFFF9800);         // 2인 플레이
static const Color red = Color(0xFFF44336);            // 온라인 플레이
static const Color yellow = Color(0xFFFFC107);         // 규칙/상점
static const Color green = Color(0xFF4CAF50);          // 성공/시작
static const Color gray = Color(0xFF757575);           // 중립
```

### 📝 **버튼 스타일 템플릿**
```dart
// Figma 스타일 버튼
Container(
  width: 280,
  height: 60,
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment(0.00, -1.00),
      end: Alignment(0, 1),
      colors: [color1, color2],
    ),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: Colors.white, width: 6),
  ),
  // ...
)
```

## 🧪 테스트 전략

### ✅ **현재 테스트 가능한 기능**
1. **UI 네비게이션**: 모든 화면 전환
2. **게임 로직**: 5목 승리 조건
3. **타이머 시스템**: 30초 카운트다운
4. **캐릭터 선택**: 12지신 캐릭터
5. **복권 시스템**: 코인/아이템 획득

### 🚀 **실행 명령어**
```bash
# 앱 실행
flutter run -d chrome    # 웹 (권장)
flutter run -d ios       # iOS 시뮬레이터
flutter run -d android   # Android 에뮬레이터

# 테스트
flutter test
flutter test --coverage
```

## 🐛 알려진 이슈 및 해결 방법

### ⚠️ **현재 이슈들**
1. **AI 대전**: 아직 구현되지 않음 → "AI 연습게임" 버튼 비활성화
2. **온라인 플레이**: Firebase 연동 필요
3. **소셜 로그인**: UI만 구현, 실제 연동 필요
4. **스킬 시스템**: 기본 구조만 완성

### 🔧 **개발 팁**
```bash
# Flutter 캐시 정리 (에러 발생시)
flutter clean
flutter pub get

# Hot Reload 활용
r키 - 핫 리로드
R키 - 핫 리스타트
```

## 🎯 다음 작업 시작 프롬프트

### 🚀 **AI 대전 시스템 구현부터 시작**
```
"Omok Arena 프로젝트에서 AI 대전 시스템을 구현하고 싶습니다. 
현재 'AI 연습게임' 버튼이 있지만 실제 AI 로직이 없어서 작동하지 않습니다.
간단한 미니맥스 알고리즘이나 휴리스틱 기반 AI를 구현해서 
사용자가 컴퓨터와 오목 게임을 할 수 있도록 만들어주세요.
난이도는 중급 정도로 설정하고, AI 응답 시간은 2-3초 정도로 해주세요."
```

### 🎮 **캐릭터 스킬 시스템 완성**
```
"12지신 캐릭터 시스템에서 각 캐릭터별 고유 스킬을 구현하고 싶습니다.
현재 캐릭터 선택 화면과 기본 구조는 완성되어 있지만, 
실제 게임에서 스킬을 사용할 수 있는 시스템이 필요합니다.
게임당 1회 제한으로 캐릭터별 특수 능력을 사용할 수 있게 해주세요."
```

## 📚 참고 자료

### 🔗 **중요 파일들**
- **메인 진입점**: `lib/main.dart`
- **게임 로직**: `lib/logic/omok_game_logic.dart`
- **향상된 게임 화면**: `lib/screens/enhanced_game_screen.dart`
- **캐릭터 모델**: `lib/models/character.dart`
- **애니메이션 타이머**: `lib/widgets/animated_countdown.dart`

### 🎨 **디자인 레퍼런스**
- **Figma 디자인**: 다크 테마 기반
- **색상 가이드**: 기능별 색상 코딩 시스템
- **폰트**: Cafe24Ohsquare (한국어 최적화)

---

## ⭐ **핵심 요약**

1. **현재 상태**: Figma 기반 UI 완성, 기본 게임 로직 구현
2. **다음 작업**: AI 대전 → 스킬 시스템 → 아이템 시스템
3. **기술 스택**: Flutter 3.8.1+, Dart, Material Design 3
4. **GitHub**: https://github.com/HipsterTerry/omok_game_app.git
5. **모든 변경사항 커밋 완료**: 60개 파일, 10K+ 줄 코드

**🚀 내일부터 AI 대전 시스템 구현으로 시작하면 됩니다!** 🎮 