import 'package:flutter/material.dart';
import 'auth_login_screen.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key})
    : super(key: key);

  @override
  State<OnboardingScreen> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState
    extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController =
      PageController();
  int _currentPage = 0;
  late List<AnimationController>
  _bounceControllers;
  late List<Animation<double>> _bounceAnimations;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      imagePath: 'assets/image/dragon.png',
      emoji: '🐉',
      title: '12간지 캐릭터와 함께',
      description:
          '귀여운 12간지 동물 캐릭터들과\n함께 오목을 즐겨보세요!',
    ),
    OnboardingData(
      imagePath: 'assets/image/rabbit.png',
      emoji: '🐰',
      title: '특별한 스킬 시스템',
      description:
          '각 캐릭터마다 고유한 스킬이 있어\n전략적인 게임을 즐길 수 있어요!',
    ),
    OnboardingData(
      imagePath: 'assets/image/tiger.png',
      emoji: '🐅',
      title: 'AI와 대전하기',
      description:
          '3단계 난이도의 AI와 대전하거나\n친구와 함께 플레이하세요!',
    ),
    OnboardingData(
      imagePath: 'assets/image/monkey.png',
      emoji: '🐒',
      title: '지금 시작하기',
      description:
          'Omok Arena에서\n최고의 오목 마스터가 되어보세요!',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _bounceControllers = List.generate(
      _onboardingData.length,
      (index) => AnimationController(
        duration: const Duration(
          milliseconds: 800,
        ),
        vsync: this,
      ),
    );

    _bounceAnimations = _bounceControllers.map((
      controller,
    ) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.elasticOut,
        ),
      );
    }).toList();

    // 첫 번째 페이지 애니메이션 시작
    _bounceControllers[0].forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _bounceControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });

    // 현재 페이지 애니메이션 시작
    _bounceControllers[page].reset();
    _bounceControllers[page].forward();
  }

  void _nextPage() {
    if (_currentPage <
        _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(
          milliseconds: 300,
        ),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder:
            (
              context,
              animation,
              secondaryAnimation,
            ) => const AuthLoginScreen(),
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
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
      ),
    );
  }

  // 바로 홈화면으로 이동 (개발용)
  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder:
            (
              context,
              animation,
              secondaryAnimation,
            ) => const HomeScreen(),
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
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFFBFF),
      body: SafeArea(
        child: Column(
          children: [
            // 상단 건너뛰기 버튼
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                children: [
                  const SizedBox(width: 60),
                  Text(
                    'Omok Arena',
                    style: TextStyle(
                      fontFamily:
                          'Cafe24Ohsquare',
                      fontSize: 20,
                      color: const Color(
                        0xFF5C47CE,
                      ),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed:
                        _navigateToHome, // 바로 홈화면으로 이동
                    child: Text(
                      '바로 시작',
                      style: TextStyle(
                        fontFamily: 'SUIT',
                        fontSize: 14,
                        color: const Color(
                          0xFF5C47CE,
                        ).withOpacity(0.7),
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 메인 콘텐츠
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(
                    index,
                  );
                },
              ),
            ),

            // 하단 인디케이터와 버튼
            Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  // 페이지 인디케이터
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) =>
                          _buildPageIndicator(
                            index,
                          ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 다음/시작하기 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(
                              0xFF89E0F7,
                            ),
                        foregroundColor:
                            const Color(
                              0xFF5C47CE,
                            ),
                        elevation: 5,
                        shadowColor: const Color(
                          0xFF8BBEDC,
                        ).withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                25,
                              ),
                        ),
                      ),
                      child: Text(
                        _currentPage ==
                                _onboardingData
                                        .length -
                                    1
                            ? '시작하기'
                            : '다음',
                        style: const TextStyle(
                          fontFamily: 'SUIT',
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(int index) {
    final data = _onboardingData[index];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          // 캐릭터 이미지 (Bounce 애니메이션)
          AnimatedBuilder(
            animation: _bounceAnimations[index],
            builder: (context, child) {
              return Transform.scale(
                scale: _bounceAnimations[index]
                    .value,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(
                          100,
                        ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(
                          0xFF8BBEDC,
                        ).withOpacity(0.3),
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
                          100,
                        ),
                    child: Image.asset(
                      data.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient:
                                LinearGradient(
                                  colors: [
                                    const Color(
                                      0xFF89E0F7,
                                    ).withOpacity(
                                      0.8,
                                    ),
                                    const Color(
                                      0xFF51D4EB,
                                    ).withOpacity(
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
                                  100,
                                ),
                          ),
                          child: Center(
                            child: Text(
                              data.emoji,
                              style:
                                  const TextStyle(
                                    fontSize: 80,
                                  ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 50),

          // 타이틀
          Text(
            data.title,
            style: const TextStyle(
              fontFamily: 'Cafe24Ohsquare',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5C47CE),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // 설명
          Text(
            data.description,
            style: TextStyle(
              fontFamily: 'SUIT',
              fontSize: 16,
              color: const Color(
                0xFF5C47CE,
              ).withOpacity(0.8),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(
        horizontal: 4,
      ),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? const Color(0xFF89E0F7)
            : const Color(
                0xFF89E0F7,
              ).withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingData {
  final String imagePath;
  final String emoji;
  final String title;
  final String description;

  OnboardingData({
    required this.imagePath,
    required this.emoji,
    required this.title,
    required this.description,
  });
}
