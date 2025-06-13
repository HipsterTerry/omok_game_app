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
        MaterialPageRoute(
          builder: (context) =>
              const HomeScreen(),
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
        MaterialPageRoute(
          builder: (context) =>
              const HomeScreen(),
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
          ),
          backgroundColor: const Color(
            0xFF89E0F7,
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
      backgroundColor: const Color(0xFFDFFBFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // 로고 및 타이틀
                _buildHeader(),

                const SizedBox(height: 50),

                // 에러 메시지
                if (_errorMessage != null)
                  _buildErrorMessage(),

                // 이메일 입력
                _buildEmailField(),

                const SizedBox(height: 20),

                // 비밀번호 입력
                _buildPasswordField(),

                const SizedBox(height: 30),

                // 로그인 버튼
                _buildLoginButton(),

                const SizedBox(height: 15),

                // 임시 로그인 버튼 (개발용)
                _buildTempLoginButton(),

                const SizedBox(height: 20),

                // 회원가입 및 비밀번호 찾기 링크
                _buildAuthLinks(),

                const SizedBox(height: 40),

                // 구분선
                _buildDivider(),

                const SizedBox(height: 30),

                // 소셜 로그인 버튼들
                _buildSocialLoginButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // 로고
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              20,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF8BBEDC,
                ).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              20,
            ),
            child: Image.asset(
              'assets/image/home_logo.png',
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(
                              0xFF89E0F7,
                            ).withOpacity(0.8),
                            const Color(
                              0xFF51D4EB,
                            ).withOpacity(0.6),
                          ],
                          begin:
                              Alignment.topLeft,
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
                            fontSize: 40,
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
            fontWeight: FontWeight.bold,
            color: const Color(0xFF5C47CE),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          '로그인하여 게임을 시작하세요',
          style: TextStyle(
            fontFamily: 'SUIT',
            fontSize: 14,
            color: const Color(
              0xFF5C47CE,
            ).withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
        ),
      ),
      child: Text(
        _errorMessage!,
        style: const TextStyle(
          fontFamily: 'SUIT',
          color: Colors.red,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: '이메일',
        hintText: 'example@email.com',
        prefixIcon: Icon(
          Icons.email_outlined,
          color: const Color(
            0xFF5C47CE,
          ).withOpacity(0.7),
        ),
        labelStyle: TextStyle(
          fontFamily: 'SUIT',
          color: const Color(
            0xFF5C47CE,
          ).withOpacity(0.7),
        ),
        hintStyle: TextStyle(
          fontFamily: 'Pretendard',
          color: const Color(
            0xFF5C47CE,
          ).withOpacity(0.5),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(
              0xFF89E0F7,
            ).withOpacity(0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(
              0xFF89E0F7,
            ).withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF89E0F7),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),
      ),
      style: const TextStyle(
        fontFamily: 'Pretendard',
        color: Color(0xFF5C47CE),
      ),
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
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: '비밀번호',
        hintText: '비밀번호를 입력하세요',
        prefixIcon: Icon(
          Icons.lock_outlined,
          color: const Color(
            0xFF5C47CE,
          ).withOpacity(0.7),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible
                ? Icons.visibility
                : Icons.visibility_off,
            color: const Color(
              0xFF5C47CE,
            ).withOpacity(0.7),
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible =
                  !_isPasswordVisible;
            });
          },
        ),
        labelStyle: TextStyle(
          fontFamily: 'SUIT',
          color: const Color(
            0xFF5C47CE,
          ).withOpacity(0.7),
        ),
        hintStyle: TextStyle(
          fontFamily: 'Pretendard',
          color: const Color(
            0xFF5C47CE,
          ).withOpacity(0.5),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(
              0xFF89E0F7,
            ).withOpacity(0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(
              0xFF89E0F7,
            ).withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF89E0F7),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),
      ),
      style: const TextStyle(
        fontFamily: 'Pretendard',
        color: Color(0xFF5C47CE),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '비밀번호를 입력해주세요';
        }
        if (value.length < 6) {
          return '비밀번호는 6자 이상이어야 합니다';
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(
            0xFF89E0F7,
          ),
          foregroundColor: const Color(
            0xFF5C47CE,
          ),
          elevation: 5,
          shadowColor: const Color(
            0xFF8BBEDC,
          ).withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              25,
            ),
          ),
          disabledBackgroundColor: const Color(
            0xFF89E0F7,
          ).withOpacity(0.5),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<
                        Color
                      >(Color(0xFF5C47CE)),
                ),
              )
            : const Text(
                '로그인',
                style: TextStyle(
                  fontFamily: 'SUIT',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  // 임시 로그인 버튼 (개발용 - Firebase 연동 전까지)
  Widget _buildTempLoginButton() {
    return SizedBox(
      height: 45,
      child: OutlinedButton(
        onPressed: _isLoading
            ? null
            : _handleTempLogin,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: const Color(0xFF89E0F7),
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              25,
            ),
          ),
          backgroundColor: Colors.white
              .withOpacity(0.8),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.developer_mode,
              color: const Color(0xFF5C47CE),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              '임시 로그인 (개발용)',
              style: TextStyle(
                fontFamily: 'SUIT',
                fontSize: 14,
                color: const Color(0xFF5C47CE),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthLinks() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    const AuthRegisterScreen(),
              ),
            );
          },
          child: Text(
            '회원가입',
            style: TextStyle(
              fontFamily: 'SUIT',
              fontSize: 14,
              color: const Color(
                0xFF5C47CE,
              ).withOpacity(0.8),
              decoration:
                  TextDecoration.underline,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    const AuthForgotPasswordScreen(),
              ),
            );
          },
          child: Text(
            '비밀번호 찾기',
            style: TextStyle(
              fontFamily: 'SUIT',
              fontSize: 14,
              color: const Color(
                0xFF5C47CE,
              ).withOpacity(0.8),
              decoration:
                  TextDecoration.underline,
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
          child: Divider(
            color: const Color(
              0xFF5C47CE,
            ).withOpacity(0.3),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Text(
            '또는',
            style: TextStyle(
              fontFamily: 'SUIT',
              fontSize: 14,
              color: const Color(
                0xFF5C47CE,
              ).withOpacity(0.6),
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: const Color(
              0xFF5C47CE,
            ).withOpacity(0.3),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLoginButtons() {
    return Column(
      children: [
        // 구글 로그인
        _buildSocialButton(
          '구글로 로그인',
          Icons.account_circle,
          Colors.red,
          () => _handleSocialLogin('구글'),
        ),

        const SizedBox(height: 12),

        // 네이버 로그인
        _buildSocialButton(
          '네이버로 로그인',
          Icons.account_circle,
          Colors.green,
          () => _handleSocialLogin('네이버'),
        ),

        const SizedBox(height: 12),

        // 카카오 로그인
        _buildSocialButton(
          '카카오로 로그인',
          Icons.account_circle,
          Colors.yellow.shade700,
          () => _handleSocialLogin('카카오'),
        ),
      ],
    );
  }

  Widget _buildSocialButton(
    String text,
    IconData icon,
    Color iconColor,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : onPressed,
        icon: Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
        label: Text(
          text,
          style: const TextStyle(
            fontFamily: 'SUIT',
            fontSize: 14,
            color: Color(0xFF5C47CE),
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white
              .withOpacity(0.8),
          side: BorderSide(
            color: const Color(
              0xFF89E0F7,
            ).withOpacity(0.5),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              12,
            ),
          ),
        ),
      ),
    );
  }
}
