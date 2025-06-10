#!/bin/bash

# 🚀 Omok Arena - 빠른 개발 환경 설정 스크립트
# 사용법: chmod +x quick_setup.sh && ./quick_setup.sh

echo "🎮 Omok Arena - 개발 환경 설정을 시작합니다..."

# 1. Flutter 환경 확인
echo "📱 Flutter 환경 확인 중..."
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter가 설치되어 있지 않습니다."
    echo "👉 https://flutter.dev/docs/get-started/install 에서 설치해주세요."
    exit 1
fi

flutter --version
echo "✅ Flutter 설치 확인 완료"

# 2. 프로젝트 의존성 설치
echo "📦 프로젝트 의존성 설치 중..."
flutter pub get

if [ $? -eq 0 ]; then
    echo "✅ 의존성 설치 완료"
else
    echo "❌ 의존성 설치 실패"
    exit 1
fi

# 3. Flutter Doctor 실행
echo "🔧 Flutter 환경 진단 중..."
flutter doctor

# 4. 사용 가능한 디바이스 확인
echo "📱 사용 가능한 디바이스 확인 중..."
flutter devices

# 5. 에뮬레이터 목록 확인
echo "📱 사용 가능한 에뮬레이터 확인 중..."
flutter emulators

# 6. 프로젝트 구조 확인
echo "📁 프로젝트 구조 확인 중..."
if [ -d "lib" ] && [ -f "pubspec.yaml" ]; then
    echo "✅ 프로젝트 구조 정상"
    echo "📂 주요 파일들:"
    echo "  - lib/main.dart (메인 앱)"
    echo "  - lib/screens/ (화면들)"
    echo "  - lib/widgets/ (위젯들)"
    echo "  - lib/logic/ (게임 로직)"
else
    echo "❌ 프로젝트 구조에 문제가 있습니다."
    exit 1
fi

# 7. Git 상태 확인
echo "🔄 Git 상태 확인 중..."
git status
echo "🏷️ 현재 태그: $(git describe --tags --abbrev=0 2>/dev/null || echo '태그 없음')"

# 8. 테스트 빌드 (선택사항)
read -p "🔨 테스트 빌드를 실행하시겠습니까? (y/N): " test_build
if [[ $test_build =~ ^[Yy]$ ]]; then
    echo "🔨 테스트 빌드 실행 중..."
    flutter build macos --debug
    if [ $? -eq 0 ]; then
        echo "✅ 테스트 빌드 성공"
    else
        echo "⚠️ 테스트 빌드 실패 (하지만 개발은 가능합니다)"
    fi
fi

echo ""
echo "🎉 개발 환경 설정 완료!"
echo ""
echo "📋 다음 단계:"
echo "  1. 'flutter run' 명령어로 앱 실행"
echo "  2. IDE에서 lib/main.dart 파일 열기"
echo "  3. DEVELOPMENT_STATUS.md 파일로 진행 상황 확인"
echo ""
echo "🚀 즐거운 개발되세요!" 