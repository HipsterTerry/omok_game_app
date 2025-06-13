import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'theme/omok_arena_theme.dart';

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
      theme: omokArenaTheme,
      debugShowCheckedModeBanner: false,
      home:
          const SplashScreen(), // 앱 시작점을 Splash Screen으로 변경
    );
  }
}
