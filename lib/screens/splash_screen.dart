import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key})
    : super(key: key);

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(
        milliseconds: 2000,
      ),
      vsync: this,
    );

    _fadeAnimation =
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    _startAnimation();
  }

  void _startAnimation() async {
    // 페이드 인
    await _animationController.forward();

    // 1초 대기
    await Future.delayed(
      const Duration(milliseconds: 1000),
    );

    // 페이드 아웃
    await _animationController.reverse();

    // 온보딩 화면으로 이동
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder:
              (
                context,
                animation,
                secondaryAnimation,
              ) => const OnboardingScreen(),
          transitionDuration: const Duration(
            milliseconds: 500,
          ),
          transitionsBuilder:
              (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background, // 기존 테마 배경색
      body: Center(
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  // 로고 이미지
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(
                            20,
                          ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors
                              .primaryContainer
                              .withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(
                            0,
                            10,
                          ),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(
                            20,
                          ),
                      child: Image.asset(
                        'assets/image/home_logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors
                                      .primary
                                      .withOpacity(
                                        0.8,
                                      ),
                                  AppColors
                                      .secondary
                                      .withOpacity(
                                        0.6,
                                      ),
                                ],
                                begin: Alignment
                                    .topLeft,
                                end: Alignment
                                    .bottomRight,
                              ),
                              borderRadius:
                                  BorderRadius.circular(
                                    20,
                                  ),
                            ),
                            child: const Center(
                              child: Text(
                                '🎮',
                                style: TextStyle(
                                  fontSize: 80,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 앱 타이틀
                  Text(
                    'Omok Arena',
                    style: TextStyle(
                      fontFamily:
                          'Cafe24Ohsquare',
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color:
                          AppColors.primaryText,
                      shadows: [
                        Shadow(
                          color: AppColors
                              .primaryContainer
                              .withOpacity(0.5),
                          offset: const Offset(
                            2,
                            2,
                          ),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 서브 타이틀
                  Text(
                    '귀여운 12간지 오목 게임',
                    style: TextStyle(
                      fontFamily: 'SUIT',
                      fontSize: 16,
                      color: AppColors.primaryText
                          .withOpacity(0.7),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // 로딩 인디케이터
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor:
                          AlwaysStoppedAnimation<
                            Color
                          >(AppColors.primary),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
