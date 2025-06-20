import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const OmokArenaApp());
}

class OmokArenaApp extends StatelessWidget {
  const OmokArenaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Omok Arena',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
