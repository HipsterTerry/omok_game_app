import 'package:flutter/material.dart';
import 'auth_register_screen.dart';
import 'auth_forgot_password_screen.dart';
import 'home_screen.dart';

class AuthLoginScreen extends StatefulWidget {
  const AuthLoginScreen({Key? key})
    : super(key: key);

  @override
  State<AuthLoginScreen> createState() =>
      _AuthLoginScreenState();
}

class _AuthLoginScreenState
    extends State<AuthLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController =
      TextEditingController();
  final _passwordController =
      TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate())
      return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // TODO: 실제 로그인 로직 구현 (Firebase Auth 등)
    await Future.delayed(
      const Duration(seconds: 2),
    ); // 시뮬레이션

    // 임시로 홈 화면으로 이동 (실제로는 인증 성공 시에만)
    if (mounted) {
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

    setState(() {
      _isLoading = false;
    });
  }

  // 임시 로그인 핸들러 (개발용 - 유효성 검사 없이 바로 홈화면으로)
  Future<void> _handleTempLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // 짧은 로딩 시간
    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    if (mounted) {
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
                  child: child,
                );
              },
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _handleSocialLogin(
    String provider,
  ) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // TODO: 소셜 로그인 로직 구현
    await Future.delayed(
      const Duration(seconds: 1),
    ); // 시뮬레이션

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$provider 로그인 기능은 준비 중입니다.',
            style: const TextStyle(
              fontFamily: 'Cafe24Ohsquare',
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(
            0xFF2196F3,
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              12,
            ),
          ),
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () =>
              Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white.withOpacity(0.8),
            size: 20,
          ),
        ),
        title: Text(
          '로그인',
          style: TextStyle(
            fontFamily: 'Cafe24Ohsquare',
            fontSize: 18,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(
                    context,
                  ).size.height -
                  MediaQuery.of(
                    context,
                  ).padding.top -
                  MediaQuery.of(
                    context,
                  ).padding.bottom -
                  kToolbarHeight, // AppBar 높이 제외
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(
                      height: 20,
                    ), // AppBar가 있으므로 줄임
                    // 로고 및 타이틀
                    _buildHeader(),

                    const SizedBox(height: 60),

                    // 에러 메시지
                    if (_errorMessage != null)
                      _buildErrorMessage(),

                    // 로그인 폼
                    _buildLoginForm(),

                    const SizedBox(height: 30),

                    // 회원가입 및 비밀번호 찾기 링크
                    _buildAuthLinks(),

                    const SizedBox(height: 40),

                    // 구분선
                    _buildDivider(),

                    const SizedBox(height: 30),

                    // 소셜 로그인 버튼들
                    _buildSocialLoginButtons(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // 캐릭터 로고 (돼지)
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              70,
            ),
            gradient: LinearGradient(
              begin: Alignment(0.00, -1.00),
              end: Alignment(0, 1),
              colors: [
                Colors.pink.shade200,
                Colors.pink.shade400.withOpacity(
                  0.9,
                ),
              ],
            ),
            border: Border.all(
              width: 4,
              color: Colors.white,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withOpacity(
                  0.4,
                ),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              66,
            ),
            child: Image.asset(
              'assets/image/login_pig.png',
              width: 140,
              height: 140,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) {
                    // 이미지 로딩 실패 시 이모지 대체
                    print(
                      '🖼️ 이미지 로딩 실패: $error',
                    );
                    return Container(
                      width: 140,
                      height: 140,
                      color: Colors.pink.shade100,
                      child: const Center(
                        child: Text(
                          '🐷',
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

        const SizedBox(height: 20),

        Text(
          'Omok Arena',
          style: TextStyle(
            fontFamily: 'Cafe24Ohsquare',
            fontSize: 32,
            color: Colors.white,
            height: 1.0,
            letterSpacing: -0.66,
            shadows: [
              Shadow(
                color: Colors.white.withOpacity(
                  0.5,
                ),
                offset: const Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        Text(
          '로그인하여 게임을 시작하세요',
          style: TextStyle(
            fontFamily: 'Cafe24Ohsquare',
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Text(
        _errorMessage!,
        style: const TextStyle(
          fontFamily: 'Cafe24Ohsquare',
          color: Colors.red,
          fontSize: 14,
          letterSpacing: -0.2,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch,
      children: [
        // 이메일 입력
        _buildInputField(
          controller: _emailController,
          label: '이메일',
          hint: 'example@email.com',
          prefixIcon: Icons.email_outlined,
          keyboardType:
              TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '이메일을 입력해주세요';
            }
            if (!RegExp(
              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
            ).hasMatch(value)) {
              return '올바른 이메일 형식을 입력해주세요';
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

        // 비밀번호 입력
        _buildInputField(
          controller: _passwordController,
          label: '비밀번호',
          hint: '비밀번호를 입력하세요',
          prefixIcon: Icons.lock_outlined,
          isPassword: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '비밀번호를 입력해주세요';
            }
            if (value.length < 6) {
              return '비밀번호는 최소 6자 이상이어야 합니다';
            }
            return null;
          },
        ),

        const SizedBox(height: 40),

        // 로그인 버튼
        _buildFigmaButton(
          text: '로그인',
          color: const Color(0xFF2196F3),
          onPressed: _handleLogin,
          isLoading: _isLoading,
          width: 280,
        ),

        const SizedBox(height: 15),

        // 임시 로그인 버튼 (개발용)
        _buildFigmaButton(
          text: '빠른 시작 (개발용)',
          color: const Color(0xFFFFC107),
          onPressed: _handleTempLogin,
          fontSize: 16,
          width: 280,
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    bool isPassword = false,
    TextInputType keyboardType =
        TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText:
            isPassword && !_isPasswordVisible,
        style: const TextStyle(
          fontFamily: 'Cafe24Ohsquare',
          fontSize: 16,
          color: Colors.white,
          letterSpacing: -0.2,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(
            prefixIcon,
            color: Colors.white.withOpacity(0.7),
            size: 22,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.white
                        .withOpacity(0.7),
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible =
                          !_isPasswordVisible;
                    });
                  },
                )
              : null,
          labelStyle: TextStyle(
            fontFamily: 'Cafe24Ohsquare',
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
          hintStyle: TextStyle(
            fontFamily: 'Cafe24Ohsquare',
            color: Colors.white.withOpacity(0.5),
            fontSize: 14,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(
            0.1,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              15,
            ),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(
                0.3,
              ),
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              15,
            ),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(
                0.3,
              ),
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              15,
            ),
            borderSide: const BorderSide(
              color: Colors.white,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              15,
            ),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              15,
            ),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
          errorStyle: const TextStyle(
            fontFamily: 'Cafe24Ohsquare',
            color: Colors.red,
            fontSize: 12,
          ),
          contentPadding:
              const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildFigmaButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
    double width = 280,
    double fontSize = 18,
    bool isLoading = false,
  }) {
    return Container(
      width: width,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.00, -1.00),
          end: Alignment(0, 1),
          colors: [color, color.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          width: 3,
          color: Colors.white,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(25),
          child: Container(
            width: width,
            height: 50,
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<
                              Color
                            >(Colors.white),
                      ),
                    )
                  : Text(
                      text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize,
                        fontFamily:
                            'Cafe24Ohsquare',
                        fontWeight:
                            FontWeight.bold,
                        letterSpacing: -0.30,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder:
                    (
                      context,
                      animation,
                      secondaryAnimation,
                    ) =>
                        const AuthRegisterScreen(),
                transitionDuration:
                    const Duration(
                      milliseconds: 400,
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
                          begin: const Offset(
                            1.0,
                            0.0,
                          ),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      );
                    },
              ),
            );
          },
          child: Text(
            '회원가입',
            style: TextStyle(
              fontFamily: 'Cafe24Ohsquare',
              fontSize: 14,
              color: Colors.white.withOpacity(
                0.8,
              ),
              letterSpacing: -0.3,
              decoration:
                  TextDecoration.underline,
              decorationColor: Colors.white
                  .withOpacity(0.8),
            ),
          ),
        ),
        Container(
          width: 1,
          height: 14,
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          color: Colors.white.withOpacity(0.5),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder:
                    (
                      context,
                      animation,
                      secondaryAnimation,
                    ) =>
                        const AuthForgotPasswordScreen(),
                transitionDuration:
                    const Duration(
                      milliseconds: 400,
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
                          begin: const Offset(
                            1.0,
                            0.0,
                          ),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      );
                    },
              ),
            );
          },
          child: Text(
            '비밀번호 찾기',
            style: TextStyle(
              fontFamily: 'Cafe24Ohsquare',
              fontSize: 14,
              color: Colors.white.withOpacity(
                0.8,
              ),
              letterSpacing: -0.3,
              decoration:
                  TextDecoration.underline,
              decorationColor: Colors.white
                  .withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withOpacity(0.3),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Text(
            'OR',
            style: TextStyle(
              fontFamily: 'Cafe24Ohsquare',
              color: Colors.white.withOpacity(
                0.6,
              ),
              fontSize: 14,
              letterSpacing: -0.2,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLoginButtons() {
    return Column(
      children: [
        _buildFigmaButton(
          text: 'Google로 로그인',
          color: const Color(0xFFF44336),
          onPressed: () =>
              _handleSocialLogin('Google'),
          fontSize: 16,
          width: 280,
        ),
        const SizedBox(height: 15),
        _buildFigmaButton(
          text: 'Apple로 로그인',
          color: const Color(0xFF424242),
          onPressed: () =>
              _handleSocialLogin('Apple'),
          fontSize: 16,
          width: 280,
        ),
      ],
    );
  }
}
