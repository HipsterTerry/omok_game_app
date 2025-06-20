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
      color: Color(0xFF2196F3), // 파란색
    ),
    OnboardingData(
      imagePath: 'assets/image/rabbit.png',
      emoji: '🐰',
      title: '특별한 스킬 시스템',
      description:
          '각 캐릭터마다 고유한 스킬이 있어\n전략적인 게임을 즐길 수 있어요!',
      color: Color(0xFFFF9800), // 주황색
    ),
    OnboardingData(
      imagePath: 'assets/image/tiger.png',
      emoji: '🐅',
      title: 'AI와 대전하기',
      description:
          '3단계 난이도의 AI와 대전하거나\n친구와 함께 플레이하세요!',
      color: Color(0xFFF44336), // 빨간색
    ),
    OnboardingData(
      imagePath: 'assets/image/monkey.png',
      emoji: '🐒',
      title: '지금 시작하기',
      description:
          'Omok Arena에서\n최고의 오목 마스터가 되어보세요!',
      color: Color(0xFFFFC107), // 노란색
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
          milliseconds: 1000,
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
          milliseconds: 400,
        ),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin(); // 로그인 화면으로 이동
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
                          1.0,
                          0.0,
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

  // 바로 홈화면으로 이동 (개발용 - 상단 "바로 시작" 버튼용)
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
                          1.0,
                          0.0,
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

  // 홈 화면 스타일의 Figma 버튼
  Widget _buildFigmaButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
    double width = 250,
  }) {
    return Container(
      width: width,
      height: 48,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: width,
              height: 48,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 3,
                    strokeAlign: BorderSide
                        .strokeAlignOutside,
                    color: Color(0x590A0A0A),
                  ),
                  borderRadius:
                      BorderRadius.circular(24),
                ),
                shadows: [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 5,
                    offset: Offset(0, 1),
                  ),
                  BoxShadow(
                    color: Color(0x1E000000),
                    blurRadius: 4,
                    offset: Offset(0, 3),
                  ),
                  BoxShadow(
                    color: Color(0x23000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Container(
                decoration: ShapeDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(0.00, -1.00),
                    end: Alignment(0, 1),
                    colors: [
                      color,
                      color.withOpacity(0.7),
                    ],
                  ),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 6,
                      color: Colors.white,
                    ),
                    borderRadius:
                        BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 10,
            top: 5,
            right: 10,
            child: Container(
              height: 38,
              child: GestureDetector(
                onTap: onPressed,
                child: Center(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily:
                          'Cafe24Ohsquare',
                      height: 0,
                      letterSpacing: -0.30,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.black, // 홈 화면과 동일한 검은색 배경
      body: SafeArea(
        child: Column(
          children: [
            // 상단 네비게이션 바
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                children: [
                  // 뒤로가기 버튼
                  GestureDetector(
                    onTap: () => Navigator.of(
                      context,
                    ).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(
                              20,
                            ),
                        border: Border.all(
                          color: Colors.white
                              .withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white
                            .withOpacity(0.8),
                        size: 18,
                      ),
                    ),
                  ),
                  Text(
                    'Omok Arena',
                    style: TextStyle(
                      fontFamily:
                          'Cafe24Ohsquare',
                      fontSize: 24,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  TextButton(
                    onPressed:
                        _navigateToHome, // 바로 홈화면으로 이동
                    child: Text(
                      '바로 시작',
                      style: TextStyle(
                        fontFamily:
                            'Cafe24Ohsquare',
                        fontSize: 16,
                        color: Colors.white
                            .withOpacity(0.7),
                        letterSpacing: -0.3,
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

                  // 다음/로그인하기 버튼 (홈 화면 스타일)
                  _buildFigmaButton(
                    text:
                        _currentPage ==
                            _onboardingData
                                    .length -
                                1
                        ? '로그인하기'
                        : '다음',
                    color:
                        _onboardingData[_currentPage]
                            .color,
                    onPressed: _nextPage,
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

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                MediaQuery.of(
                  context,
                ).size.height *
                0.6,
          ),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              // 캐릭터 이미지 (크기 줄여서 overflow 방지)
              AnimatedBuilder(
                animation:
                    _bounceAnimations[index],
                builder: (context, child) {
                  return Transform.scale(
                    scale:
                        _bounceAnimations[index]
                            .value,
                    child: Container(
                      width:
                          160, // 220에서 160으로 줄임
                      height:
                          160, // 220에서 160으로 줄임
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(
                              80,
                            ), // 110에서 80으로
                        gradient: LinearGradient(
                          begin: Alignment(
                            0.00,
                            -1.00,
                          ),
                          end: Alignment(0, 1),
                          colors: [
                            data.color,
                            data.color
                                .withOpacity(0.7),
                          ],
                        ),
                        border: Border.all(
                          width: 4, // 6에서 4로 줄임
                          color: Colors.white,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: data.color
                                .withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(
                              0,
                              8,
                            ),
                          ),
                          BoxShadow(
                            color: Color(
                              0x33000000,
                            ),
                            blurRadius: 15,
                            offset: const Offset(
                              0,
                              5,
                            ),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(
                              76,
                            ), // 104에서 76으로
                        child: Image.asset(
                          data.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (
                                context,
                                error,
                                stackTrace,
                              ) {
                                return Center(
                                  child: Text(
                                    data.emoji,
                                    style: const TextStyle(
                                      fontSize:
                                          60,
                                    ), // 80에서 60으로
                                  ),
                                );
                              },
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(
                height: 40,
              ), // 60에서 40으로 줄임
              // 타이틀
              Text(
                data.title,
                style: const TextStyle(
                  fontFamily: 'Cafe24Ohsquare',
                  fontSize: 28, // 32에서 28로 줄임
                  color: Colors.white,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(
                height: 20,
              ), // 30에서 20으로 줄임
              // 설명
              Text(
                data.description,
                style: TextStyle(
                  fontFamily: 'Cafe24Ohsquare',
                  fontSize: 16, // 18에서 16으로 줄임
                  color: Colors.white.withOpacity(
                    0.8,
                  ),
                  height: 1.4,
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(
        horizontal: 6,
      ),
      width: _currentPage == index ? 28 : 12,
      height: 12,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? Colors.white
            : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(6),
        boxShadow: _currentPage == index
            ? [
                BoxShadow(
                  color: Colors.white.withOpacity(
                    0.5,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
    );
  }
}

class OnboardingData {
  final String imagePath;
  final String emoji;
  final String title;
  final String description;
  final Color color;

  OnboardingData({
    required this.imagePath,
    required this.emoji,
    required this.title,
    required this.description,
    required this.color,
  });
}
