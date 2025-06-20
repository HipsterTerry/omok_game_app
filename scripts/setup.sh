#!/bin/bash

# Omok Arena 개발 환경 설정 스크립트
echo "🎮 Omok Arena 개발 환경 설정을 시작합니다..."

# Flutter 설치 확인
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter가 설치되지 않았습니다. https://flutter.dev/docs/get-started/install 를 참조하세요."
    exit 1
fi

echo "✅ Flutter 버전 확인:"
flutter --version

# 의존성 설치
echo "📦 의존성을 설치합니다..."
flutter pub get

# Flutter Doctor 실행
echo "🔧 Flutter 환경을 검사합니다..."
flutter doctor

# 디바이스 확인
echo "📱 연결된 디바이스를 확인합니다..."
flutter devices

echo "🎉 설정이 완료되었습니다!"
echo ""
echo "🚀 다음 명령어로 앱을 실행하세요:"
echo "   flutter run -d chrome     # 웹 브라우저에서 실행"
echo "   flutter run -d ios        # iOS 시뮬레이터에서 실행"
echo "   flutter run -d android    # Android 에뮬레이터에서 실행"
echo ""
echo "📋 개발 가이드: DEVELOPMENT_GUIDE.md 를 참조하세요." 