import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 앱 전체에서 사용하는 텍스트 스타일 상수
///
/// 사용법:
/// Text('제목', style: AppTextStyles.title)
/// Text('본문', style: AppTextStyles.body)
class AppTextStyles {
  AppTextStyles._(); // 인스턴스 생성 방지

  // 🎯 타이틀/헤드라인 - Cafe24Ohsquare
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'Cafe24Ohsquare',
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryText,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'Cafe24Ohsquare',
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryText,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: 'Cafe24Ohsquare',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryText,
  );

  // 🎯 헤드라인 - SUIT
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: 'SUIT',
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryText,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: 'SUIT',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: 'SUIT',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );

  // 🎯 본문 텍스트 - Pretendard
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryText,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryText,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryText,
  );

  // 🎯 라벨/버튼 텍스트 - SUIT
  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'SUIT',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryText,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'SUIT',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryText,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'SUIT',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryText,
  );

  // 🎯 특수 용도
  static const TextStyle splashTitle = TextStyle(
    fontFamily: 'Cafe24Ohsquare',
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryText,
  );

  static const TextStyle splashSubtitle = TextStyle(
    fontFamily: 'SUIT',
    fontSize: 16,
    color: AppColors.primaryText,
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: 'SUIT',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );

  static const TextStyle gameScore = TextStyle(
    fontFamily: 'Cafe24Ohsquare',
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryText,
  );
}
