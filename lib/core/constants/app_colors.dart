import 'package:flutter/material.dart';

/// Omok Arena 앱에서 사용하는 모든 색상 상수
class AppColors {
  AppColors._(); // private constructor

  // 🎨 기본 테마 색상 - Omok Arena UI 적용
  static const Color background = Color(
    0xFF1E1F3A,
  ); // 배경색
  static const Color primary = Color(
    0xFFFF6A5E,
  ); // 버튼 배경색
  static const Color primaryText = Color(
    0xFFB39DDB,
  ); // 텍스트 색상
  static const Color primaryContainer = Color(
    0xFF8BBEDC,
  ); // 버튼 테두리
  static const Color secondary = Color(
    0xFFFF6A5E,
  ); // 버튼 배경색
  static const Color secondaryContainer = Color(
    0xFF8BBEDC,
  ); // 보조 컨테이너 색상
  static const Color tertiary = Color(
    0xFF51D4EB,
  ); // 강조 테두리
  static const Color buttonText = Color(
    0xFFF7F7F7,
  ); // 버튼 텍스트 색상

  // 🎨 게임 모드 버튼 색상
  static const Color accent1 = Color(
    0xFF7B68EE,
  ); // 온라인 플레이 버튼 (미디엄 슬레이트 블루)
  static const Color accent2 = Color(
    0xFF4169E1,
  ); // 2인 플레이 버튼 (로열 블루)
  static const Color accent3 = Color(
    0xFF483D8B,
  ); // 1인 플레이 버튼 (다크 슬레이트 블루)

  // 🎨 UI 컨테이너 색상
  static const Color surfaceHigh = Color(
    0xFFF4FEFF,
  ); // 클라우드형 UI 영역 배경
  static const Color surface = Color(
    0xFFFAF9FB,
  ); // 캐릭터 선택 배경
  static const Color surfaceLow = Color(
    0xFFFFFDFB,
  ); // 오목판 바탕
  static const Color outline = Color(
    0xFFC5F6F9,
  ); // 오목판 외곽 테두리

  // 🎨 상태별 색상
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // 🎨 투명도 적용 색상 헬퍼
  static Color primaryWithOpacity(
    double opacity,
  ) => primaryText.withValues(alpha: opacity);
  static Color backgroundWithOpacity(
    double opacity,
  ) => background.withValues(alpha: opacity);
  static Color primaryContainerWithOpacity(
    double opacity,
  ) =>
      primaryContainer.withValues(alpha: opacity);
}
