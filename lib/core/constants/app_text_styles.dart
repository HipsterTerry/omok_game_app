import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Omok Arena 앱에서 사용하는 모든 텍스트 스타일 상수
class AppTextStyles {
  AppTextStyles._(); // private constructor

  // 🎨 폰트 패밀리
  static const String fontTitle =
      'Cafe24Ohsquare'; // 타이틀용
  static const String fontButton =
      'SUIT'; // 버튼 및 설명용
  static const String fontBody =
      'Pretendard'; // 기타 텍스트용

  // 🎨 타이틀 스타일 (Cafe24Ohsquare)
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontTitle,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryText,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontTitle,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryText,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontTitle,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryText,
  );

  // 🎨 헤드라인 스타일 (Cafe24Ohsquare)
  static const TextStyle headlineLarge =
      TextStyle(
        fontFamily: fontTitle,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryText,
      );

  static const TextStyle headlineMedium =
      TextStyle(
        fontFamily: fontTitle,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryText,
      );

  static const TextStyle headlineSmall =
      TextStyle(
        fontFamily: fontTitle,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryText,
      );

  // 🎨 버튼 스타일 (SUIT)
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: fontButton,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryText,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: fontButton,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryText,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: fontButton,
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryText,
  );

  // 🎨 본문 스타일 (Pretendard)
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontBody,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryText,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontBody,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryText,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontBody,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryText,
  );

  // 🎨 라벨 스타일 (SUIT)
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontButton,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryText,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontButton,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryText,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontButton,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryText,
  );

  // 🎨 특수 스타일 (투명도 적용)
  static TextStyle bodyMediumWithOpacity(
    double opacity,
  ) => bodyMedium.copyWith(
    color: AppColors.primaryWithOpacity(opacity),
  );

  static TextStyle labelMediumWithOpacity(
    double opacity,
  ) => labelMedium.copyWith(
    color: AppColors.primaryWithOpacity(opacity),
  );
}
