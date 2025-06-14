# 🚀 Omok Arena 개발자 가이드

## 📋 **빠른 수정 체크리스트**

### 🎨 **UI 색상 변경 (30초)**
```dart
// lib/core/constants/app_colors.dart
static const Color primaryText = Color(0xFF5C47CE);    // 메인 텍스트
static const Color background = Color(0xFFDFFBFF);     // 배경색
static const Color primary = Color(0xFF89E0F7);        // 버튼색
```

### 📱 **새 화면 추가 (5분)**
1. `lib/screens/` 에 파일 생성
2. `lib/screens/index.dart` 에 export 추가
3. 라우팅에서 import: `import '../screens/index.dart';`

### 🎮 **게임 로직 수정**
```dart
// lib/logic/index.dart 에서 한번에 import
import '../logic/index.dart';
// 이제 모든 게임 로직 클래스 사용 가능
```

### 🔧 **위젯 재사용**
```dart
// lib/widgets/index.dart 에서 한번에 import  
import '../widgets/index.dart';
// 모든 커스텀 위젯 사용 가능
```

## 🏗️ **프로젝트 구조**

```
lib/
├── core/constants/     ← 🎨 모든 상수 (색상, 크기, 텍스트)
├── models/            ← 📊 데이터 모델
├── logic/             ← 🧠 게임 로직
├── services/          ← 🔧 외부 서비스
├── widgets/           ← 🧩 재사용 위젯
├── screens/           ← 📱 화면들
└── theme/             ← 🎭 테마 설정
```

## ⚡ **빠른 디버깅**

### 🐛 **색상 문제**
- `app_colors.dart` 에서 한번에 수정
- Hot Reload로 즉시 확인

### 🔍 **Import 오류**
- `index.dart` 파일들 확인
- 상대경로 대신 barrel export 사용

### 🎯 **기능 추가**
1. 해당 폴더에 파일 생성
2. `index.dart`에 export 추가
3. 다른 곳에서 `import '../폴더명/index.dart';`

## 📈 **성능 최적화 팁**

- ✅ Constants 사용으로 메모리 효율성
- ✅ Index.dart로 트리 쉐이킹 최적화
- ✅ 모듈화된 구조로 빌드 시간 단축

## 🚨 **주의사항**

- ❌ 하드코딩된 색상 사용 금지
- ❌ 직접 파일 경로 import 지양
- ✅ Constants와 Index.dart 활용
- ✅ 기능별 폴더 분리 유지 