import 'package:flutter/material.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';

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
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(
        milliseconds: 2500,
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
            curve: const Interval(
              0.0,
              0.6,
              curve: Curves.easeInOut,
            ),
          ),
        );

    _scaleAnimation =
        Tween<double>(
          begin: 0.5,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(
              0.0,
              0.8,
              curve: Curves.elasticOut,
            ),
          ),
        );

    _startAnimation();
  }

  void _startAnimation() async {
    // 애니메이션 시작
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
            milliseconds: 800,
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
                  child: SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(
                            0,
                            0.3,
                          ),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOut,
                          ),
                        ),
                    child: child,
                  ),
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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 스킵 버튼들 (우상단)
          Positioned(
            top: 50,
            right: 20,
            child: Column(
              children: [
                // 온보딩으로 스킵
                GestureDetector(
                  onTap: () {
                    Navigator.of(
                      context,
                    ).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) =>
                            const OnboardingScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withOpacity(0.2),
                      borderRadius:
                          BorderRadius.circular(
                            15,
                          ),
                      border: Border.all(
                        color: Colors.white
                            .withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.white
                            .withOpacity(0.8),
                        fontSize: 12,
                        fontFamily:
                            'Cafe24Ohsquare',
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // 홈으로 바로가기
                GestureDetector(
                  onTap: () {
                    Navigator.of(
                      context,
                    ).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) =>
                            const HomeScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFF4CAF50,
                      ).withOpacity(0.3),
                      borderRadius:
                          BorderRadius.circular(
                            15,
                          ),
                      border: Border.all(
                        color: const Color(
                          0xFF4CAF50,
                        ).withOpacity(0.7),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Home',
                      style: TextStyle(
                        color: Colors.white
                            .withOpacity(0.9),
                        fontSize: 12,
                        fontFamily:
                            'Cafe24Ohsquare',
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 메인 컨텐츠
          Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children: [
                        // 메인 캐릭터 (호랑이)
                        Transform.rotate(
                          angle:
                              _scaleAnimation
                                  .value *
                              0.05,
                          child: Container(
                            width: 240,
                            height: 240,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(
                                    120,
                                  ),
                              gradient: LinearGradient(
                                begin: Alignment(
                                  0.00,
                                  -1.00,
                                ),
                                end: Alignment(
                                  0,
                                  1,
                                ),
                                colors: [
                                  Colors
                                      .orange
                                      .shade300,
                                  Colors
                                      .orange
                                      .shade500
                                      .withOpacity(
                                        0.9,
                                      ),
                                ],
                              ),
                              border: Border.all(
                                width: 6,
                                color:
                                    Colors.white,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors
                                      .orange
                                      .withOpacity(
                                        0.5,
                                      ),
                                  blurRadius: 30,
                                  offset:
                                      const Offset(
                                        0,
                                        15,
                                      ),
                                ),
                                BoxShadow(
                                  color: Color(
                                    0x44000000,
                                  ),
                                  blurRadius: 25,
                                  offset:
                                      const Offset(
                                        0,
                                        10,
                                      ),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(
                                    114,
                                  ),
                              child: Image.asset(
                                'assets/image/splash_tiger.png',
                                fit: BoxFit.cover,
                                width: 240,
                                height: 240,
                                errorBuilder:
                                    (
                                      context,
                                      error,
                                      stackTrace,
                                    ) {
                                      print(
                                        '이미지 로드 실패: $error',
                                      );
                                      return Container(
                                        width:
                                            240,
                                        height:
                                            240,
                                        decoration: BoxDecoration(
                                          color: Colors
                                              .orange
                                              .shade300,
                                          borderRadius:
                                              BorderRadius.circular(
                                                114,
                                              ),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            '🐯',
                                            style: TextStyle(
                                              fontSize:
                                                  100,
                                              color:
                                                  Colors.white,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 40,
                        ),

                        // 앱 타이틀
                        Text(
                          'Omok Arena',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontFamily:
                                'Cafe24Ohsquare',
                            height: 0,
                            letterSpacing: -0.66,
                            shadows: [
                              Shadow(
                                color: Colors
                                    .white
                                    .withOpacity(
                                      0.5,
                                    ),
                                offset:
                                    const Offset(
                                      0,
                                      2,
                                    ),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        // 서브 타이틀
                        Text(
                          '귀여운 12간지 오목 게임',
                          style: TextStyle(
                            fontFamily:
                                'Cafe24Ohsquare',
                            fontSize: 18,
                            color: Colors.white
                                .withOpacity(0.8),
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(
                          height: 60,
                        ),

                        // 로딩 인디케이터
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(
                                  30,
                                ),
                            gradient: LinearGradient(
                              begin:
                                  const Alignment(
                                    0.00,
                                    -1.00,
                                  ),
                              end:
                                  const Alignment(
                                    0,
                                    1,
                                  ),
                              colors: [
                                const Color(
                                  0xFF2196F3,
                                ),
                                const Color(
                                  0xFF2196F3,
                                ).withOpacity(
                                  0.7,
                                ),
                              ],
                            ),
                            border: Border.all(
                              width: 3,
                              color: Colors.white,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(
                                      0x33000000,
                                    ),
                                blurRadius: 8,
                                offset:
                                    const Offset(
                                      0,
                                      4,
                                    ),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor:
                                    AlwaysStoppedAnimation<
                                      Color
                                    >(
                                      Colors
                                          .white,
                                    ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        // 버전 정보
                        Text(
                          'Omok Arena v 1.0',
                          style: TextStyle(
                            color: Colors.white
                                .withOpacity(0.6),
                            fontSize: 14,
                            fontFamily:
                                'Cafe24Ohsquare',
                            letterSpacing: -0.23,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
