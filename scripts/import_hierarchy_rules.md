# Import 계층 구조 규칙 📋

## 🚫 순환 참조 방지 규칙

### 1️⃣ **계층 구조**
```
models/ (최하위 - 다른 모든 곳에서 import 가능)
  ↑
logic/ (models만 import 가능)
  ↑  
services/ (models, logic import 가능)
  ↑
widgets/ (models, logic, services import 가능)
  ↑
screens/ (모든 계층 import 가능)
```

### 2️⃣ **금지된 Import 패턴**
- ❌ models → logic/services/widgets/screens
- ❌ logic → services/widgets/screens  
- ❌ services → widgets/screens
- ❌ widgets → screens
- ❌ 같은 폴더 내 순환 참조

### 3️⃣ **안전한 Index.dart 생성 순서**
1. `lib/models/index.dart` (의존성 0개)
2. `lib/logic/index.dart` (models만 의존)
3. `lib/services/index.dart` (models, logic 의존)
4. `lib/widgets/index.dart` (models, logic, services 의존)
5. `lib/screens/index.dart` (모든 계층 의존)

### 4️⃣ **각 단계별 검증 명령어**
```bash
# 1단계: models index.dart 생성 후
dart analyze lib/models/

# 2단계: logic index.dart 생성 후  
dart analyze lib/logic/
dart analyze lib/models/

# 3단계: services index.dart 생성 후
dart analyze lib/services/
dart analyze lib/logic/
dart analyze lib/models/

# 4단계: widgets index.dart 생성 후
dart analyze lib/widgets/
dart analyze lib/services/
dart analyze lib/logic/
dart analyze lib/models/

# 5단계: screens index.dart 생성 후
dart analyze lib/screens/
dart analyze lib/widgets/
dart analyze lib/services/
dart analyze lib/logic/
dart analyze lib/models/

# 최종 검증
flutter analyze
```

### 5️⃣ **문제 발생 시 롤백 계획**
```bash
# 특정 단계로 되돌리기
git checkout phase5-step-{N}

# 전체 롤백
git checkout main
git branch -D phase5-import-optimization
``` 