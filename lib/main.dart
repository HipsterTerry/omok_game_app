import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OmokGameApp());
}

class OmokGameApp extends StatelessWidget {
  const OmokGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Omok Arena',
      theme: ThemeData(
        // 🎨 새로운 컬러 스킴
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5C47CE),
          primary: const Color(0xFF5C47CE),
          secondary: const Color(0xFF89E0F7),
          surface: const Color(0xFFDFFBFF),
          background: const Color(0xFFDFFBFF),
          onPrimary: Colors.white,
          onSecondary: const Color(0xFF5C47CE),
          onSurface: const Color(0xFF5C47CE),
          onBackground: const Color(0xFF5C47CE),
        ),

        // 🎨 스캐폴드 배경색
        scaffoldBackgroundColor: const Color(0xFFDFFBFF),

        // 🎨 앱바 테마
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF5C47CE),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Cafe24Ohsquare',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        // 🎨 텍스트 테마
        textTheme: const TextTheme(
          // 제목용 - Cafe24Ohsquare
          headlineLarge: TextStyle(
            fontFamily: 'Cafe24Ohsquare',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5C47CE),
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Cafe24Ohsquare',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5C47CE),
          ),
          headlineSmall: TextStyle(
            fontFamily: 'Cafe24Ohsquare',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5C47CE),
          ),

          // 버튼용 - SUIT
          labelLarge: TextStyle(
            fontFamily: 'SUIT',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF5C47CE),
          ),
          labelMedium: TextStyle(
            fontFamily: 'SUIT',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF5C47CE),
          ),
          labelSmall: TextStyle(
            fontFamily: 'SUIT',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF5C47CE),
          ),

          // 본문용 - Pretendard
          bodyLarge: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w300,
            color: Color(0xFF5C47CE),
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w300,
            color: Color(0xFF5C47CE),
          ),
          bodySmall: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 12,
            fontWeight: FontWeight.w300,
            color: Color(0xFF5C47CE),
          ),

          // 제목과 표시용
          titleLarge: TextStyle(
            fontFamily: 'Cafe24Ohsquare',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5C47CE),
          ),
          titleMedium: TextStyle(
            fontFamily: 'Cafe24Ohsquare',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5C47CE),
          ),
          titleSmall: TextStyle(
            fontFamily: 'Cafe24Ohsquare',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5C47CE),
          ),
        ),

        // 🎨 버튼 테마
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF89E0F7),
            foregroundColor: const Color(0xFF5C47CE),
            side: const BorderSide(color: Color(0xFF8BBEDC), width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            textStyle: const TextStyle(
              fontFamily: 'SUIT',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            elevation: 8,
            shadowColor: const Color(0xFF8BBEDC).withOpacity(0.5),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),

        // 🎨 아웃라인 버튼 테마
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF5C47CE),
            side: const BorderSide(color: Color(0xFF8BBEDC), width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            textStyle: const TextStyle(
              fontFamily: 'SUIT',
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),

        // 🎨 텍스트 버튼 테마
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF5C47CE),
            textStyle: const TextStyle(
              fontFamily: 'SUIT',
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),

        // 🎨 카드 테마
        cardTheme: CardThemeData(
          color: const Color(0xFFFAF9FB), // Character Card BG 적용
          elevation: 8,
          shadowColor: const Color(0xFF8BBEDC).withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(
              color: Color(0xFFC5F6F9), // Board Border 적용
              width: 2,
            ),
          ),
          margin: const EdgeInsets.all(8),
        ),

        // 🎨 입력 필드 테마
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFFFFFDFB),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFC5F6F9), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFC5F6F9), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF51D4EB), width: 3),
          ),
          labelStyle: const TextStyle(
            fontFamily: 'Pretendard',
            color: Color(0xFF5C47CE),
          ),
          hintStyle: TextStyle(
            fontFamily: 'Pretendard',
            color: const Color(0xFF5C47CE).withOpacity(0.6),
          ),
        ),

        // 🎨 다이얼로그 테마
        dialogTheme: DialogThemeData(
          backgroundColor: const Color(0xFFFAF9FB),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: const BorderSide(color: Color(0xFFC5F6F9), width: 2),
          ),
          elevation: 12,
          shadowColor: const Color(0xFF8BBEDC).withOpacity(0.5),
          titleTextStyle: const TextStyle(
            fontFamily: 'Cafe24Ohsquare',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5C47CE),
          ),
          contentTextStyle: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w300,
            color: Color(0xFF5C47CE),
          ),
        ),

        // 🎨 스낵바 테마
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF89E0F7),
          contentTextStyle: const TextStyle(
            fontFamily: 'SUIT',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF5C47CE),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          behavior: SnackBarBehavior.floating,
          elevation: 8,
        ),

        // 🎨 체크박스 테마
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const Color(0xFF89E0F7);
            }
            return Colors.transparent;
          }),
          checkColor: MaterialStateProperty.all(const Color(0xFF5C47CE)),
          side: const BorderSide(color: Color(0xFF8BBEDC), width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),

        // 🎨 라디오 버튼 테마
        radioTheme: RadioThemeData(
          fillColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const Color(0xFF89E0F7);
            }
            return const Color(0xFF8BBEDC);
          }),
        ),

        // 🎨 스위치 테마
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const Color(0xFF89E0F7);
            }
            return const Color(0xFFDFFBFF);
          }),
          trackColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const Color(0xFF8BBEDC);
            }
            return const Color(0xFFC5F6F9);
          }),
        ),

        // 🎨 기타 테마 설정
        dividerColor: const Color(0xFFC5F6F9),
        canvasColor: const Color(0xFFFFFFDFB), // Board BG
        dialogBackgroundColor: const Color(0xFFFAF9FB),
        splashColor: const Color(0xFF89E0F7).withOpacity(0.3),
        highlightColor: const Color(0xFF51D4EB).withOpacity(0.2),
        focusColor: const Color(0xFF51D4EB).withOpacity(0.1),
        hoverColor: const Color(0xFF89E0F7).withOpacity(0.1),

        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
