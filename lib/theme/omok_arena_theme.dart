import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Omok Arena 키치 테마 정의
final ThemeData omokArenaTheme = ThemeData(
  useMaterial3: true,

  // 컬러 스킴 정의
  colorScheme: const ColorScheme.light(
    // 기본 배경
    surface: AppColors.background, // 민트빛 파스텔 배경
    onSurface: AppColors.primaryText, // 전체 텍스트 색상
    // 버튼 관련
    primary: AppColors.primary, // 버튼 배경색
    onPrimary: AppColors.primaryText, // 버튼 텍스트
    primaryContainer:
        AppColors.primaryContainer, // 버튼 테두리
    // 강조 색상
    secondary: AppColors.secondary, // 강조 테두리
    onSecondary: AppColors.primaryText,

    // 카드/컨테이너
    surfaceContainerHighest:
        AppColors.surfaceHigh, // 클라우드형 UI 영역 배경
    surfaceContainer:
        AppColors.surface, // 캐릭터 선택 배경
    // 오목판
    surfaceContainerLow:
        AppColors.surfaceLow, // 오목판 바탕
    outline: AppColors.outline, // 오목판 외곽 테두리
  ),

  // 텍스트 테마
  textTheme: const TextTheme(
    // 타이틀/헤드라인 - Cafe24Ohsquare
    displayLarge: TextStyle(
      fontFamily: 'Cafe24Ohsquare',
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.primaryText,
    ),
    displayMedium: TextStyle(
      fontFamily: 'Cafe24Ohsquare',
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.primaryText,
    ),
    displaySmall: TextStyle(
      fontFamily: 'Cafe24Ohsquare',
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: AppColors.primaryText,
    ),

    // 헤드라인 - Cafe24Ohsquare
    headlineLarge: TextStyle(
      fontFamily: 'Cafe24Ohsquare',
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Color(0xFF5C47CE),
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Cafe24Ohsquare',
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Color(0xFF5C47CE),
    ),
    headlineSmall: TextStyle(
      fontFamily: 'Cafe24Ohsquare',
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Color(0xFF5C47CE),
    ),

    // 타이틀 - SUIT
    titleLarge: TextStyle(
      fontFamily: 'SUIT',
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Color(0xFF5C47CE),
    ),
    titleMedium: TextStyle(
      fontFamily: 'SUIT',
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Color(0xFF5C47CE),
    ),
    titleSmall: TextStyle(
      fontFamily: 'SUIT',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Color(0xFF5C47CE),
    ),

    // 본문 - Pretendard
    bodyLarge: TextStyle(
      fontFamily: 'Pretendard',
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Color(0xFF5C47CE),
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Pretendard',
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Color(0xFF5C47CE),
    ),
    bodySmall: TextStyle(
      fontFamily: 'Pretendard',
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: Color(0xFF5C47CE),
    ),

    // 라벨 - SUIT
    labelLarge: TextStyle(
      fontFamily: 'SUIT',
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Color(0xFF5C47CE),
    ),
    labelMedium: TextStyle(
      fontFamily: 'SUIT',
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Color(0xFF5C47CE),
    ),
    labelSmall: TextStyle(
      fontFamily: 'SUIT',
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: Color(0xFF5C47CE),
    ),
  ),

  // 버튼 테마 - 입체적 효과 강화
  elevatedButtonTheme: ElevatedButtonThemeData(
    style:
        ElevatedButton.styleFrom(
          backgroundColor: const Color(
            0xFF89E0F7,
          ), // 버튼 배경색
          foregroundColor: const Color(
            0xFF5C47CE,
          ), // 버튼 텍스트
          side: const BorderSide(
            color: Color(0xFF8BBEDC), // 버튼 테두리
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              20,
            ),
          ),
          elevation: 8,
          shadowColor: const Color(0xFF8BBEDC),
          textStyle: const TextStyle(
            fontFamily: 'SUIT',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
        ).copyWith(
          // 입체적 그림자 효과 추가
          overlayColor:
              WidgetStateProperty.resolveWith((
                states,
              ) {
                if (states.contains(
                  WidgetState.pressed,
                )) {
                  return const Color(
                    0xFF51D4EB,
                  ).withOpacity(0.2);
                }
                if (states.contains(
                  WidgetState.hovered,
                )) {
                  return const Color(
                    0xFF89E0F7,
                  ).withOpacity(0.1);
                }
                return null;
              }),
        ),
  ),

  // 텍스트 버튼 테마
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFF5C47CE),
      textStyle: const TextStyle(
        fontFamily: 'SUIT',
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
  ),

  // 아웃라인 버튼 테마
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF5C47CE),
      side: const BorderSide(
        color: Color(0xFF51D4EB), // 강조 테두리
        width: 2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      textStyle: const TextStyle(
        fontFamily: 'SUIT',
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),

  // 카드 테마 - Cloud BG 효과 강화
  cardTheme: CardThemeData(
    color: const Color(
      0xFFF4FEFF,
    ).withOpacity(0.9), // 클라우드형 UI 영역 배경 - 투명도 적용
    elevation: 12,
    shadowColor: Colors.white.withOpacity(0.8),
    shape: RoundedRectangleBorder(
      borderRadius: const BorderRadius.all(
        Radius.circular(24),
      ),
      side: BorderSide(
        color: const Color(
          0xFFC5F6F9,
        ).withOpacity(0.6),
        width: 0.8,
      ),
    ),
  ),

  // 입력 필드 테마
  inputDecorationTheme:
      const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFFAF9FB), // 캐릭터 선택 배경
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(16),
          ),
          borderSide: BorderSide(
            color: Color(0xFF8BBEDC),
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(16),
          ),
          borderSide: BorderSide(
            color: Color(0xFF8BBEDC),
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(16),
          ),
          borderSide: BorderSide(
            color: Color(0xFF51D4EB), // 강조 테두리
            width: 2,
          ),
        ),
        labelStyle: TextStyle(
          fontFamily: 'SUIT',
          color: Color(0xFF5C47CE),
        ),
        hintStyle: TextStyle(
          fontFamily: 'Pretendard',
          color: Color(0xFF5C47CE),
        ),
      ),

  // 앱바 테마
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF89E0F7), // 버튼 배경색
    foregroundColor: Color(0xFF5C47CE), // 텍스트 색상
    elevation: 4,
    shadowColor: Color(0xFF8BBEDC),
    titleTextStyle: TextStyle(
      fontFamily: 'Cafe24Ohsquare',
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Color(0xFF5C47CE),
    ),
    iconTheme: IconThemeData(
      color: Color(0xFF5C47CE),
    ),
  ),

  // 다이얼로그 테마 - Cloud BG 효과 강화
  dialogTheme: DialogThemeData(
    backgroundColor: const Color(0xFFF4FEFF)
        .withOpacity(
          0.95,
        ), // 클라우드형 UI 영역 배경 - 투명도 적용
    elevation: 16,
    shadowColor: Colors.white.withOpacity(0.9),
    shape: RoundedRectangleBorder(
      borderRadius: const BorderRadius.all(
        Radius.circular(28),
      ),
      side: BorderSide(
        color: const Color(
          0xFF51D4EB,
        ).withOpacity(0.8), // 강조 테두리
        width: 1.5,
      ),
    ),
    titleTextStyle: const TextStyle(
      fontFamily: 'Cafe24Ohsquare',
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Color(0xFF5C47CE),
    ),
    contentTextStyle: TextStyle(
      fontFamily: 'Pretendard',
      fontSize: 14,
      color: const Color(
        0xFF5C47CE,
      ).withOpacity(0.8), // 캡션 텍스트 반투명
    ),
  ),

  // 스낵바 테마
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Color(0xFF89E0F7), // 버튼 배경색
    contentTextStyle: TextStyle(
      fontFamily: 'SUIT',
      color: Color(0xFF5C47CE),
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(16),
      ),
    ),
  ),

  // 스위치 테마
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((
      states,
    ) {
      if (states.contains(WidgetState.selected)) {
        return const Color(0xFF51D4EB); // 강조 테두리
      }
      return const Color(0xFF8BBEDC); // 버튼 테두리
    }),
    trackColor: WidgetStateProperty.resolveWith((
      states,
    ) {
      if (states.contains(WidgetState.selected)) {
        return const Color(0xFF89E0F7); // 버튼 배경색
      }
      return const Color(
        0xFFF4FEFF,
      ); // 클라우드형 UI 영역 배경
    }),
  ),

  // 체크박스 테마
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((
      states,
    ) {
      if (states.contains(WidgetState.selected)) {
        return const Color(0xFF51D4EB); // 강조 테두리
      }
      return const Color(
        0xFFF4FEFF,
      ); // 클라우드형 UI 영역 배경
    }),
    checkColor: WidgetStateProperty.all(
      const Color(0xFF5C47CE),
    ),
    side: const BorderSide(
      color: Color(0xFF8BBEDC), // 버튼 테두리
      width: 2,
    ),
  ),

  // 슬라이더 테마
  sliderTheme: const SliderThemeData(
    activeTrackColor: Color(0xFF51D4EB), // 강조 테두리
    inactiveTrackColor: Color(
      0xFFC5F6F9,
    ), // 오목판 외곽 테두리
    thumbColor: Color(0xFF89E0F7), // 버튼 배경색
    overlayColor: Color(0x2951D4EB), // 강조 테두리 투명
  ),

  // 전체 배경색
  scaffoldBackgroundColor: const Color(
    0xFFDFFBFF,
  ), // 민트빛 파스텔 배경
);
