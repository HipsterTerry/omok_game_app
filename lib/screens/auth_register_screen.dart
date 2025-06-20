import 'package:flutter/material.dart';
import 'auth_login_screen.dart';

class AuthRegisterScreen extends StatefulWidget {
  const AuthRegisterScreen({Key? key})
    : super(key: key);

  @override
  State<AuthRegisterScreen> createState() =>
      _AuthRegisterScreenState();
}

class _AuthRegisterScreenState
    extends State<AuthRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController =
      TextEditingController();
  final _nicknameController =
      TextEditingController();
  final _passwordController =
      TextEditingController();
  final _confirmPasswordController =
      TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _nicknameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate())
      return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // TODO: 실제 회원가입 로직 구현 (Firebase Auth 등)
    await Future.delayed(
      const Duration(seconds: 2),
    ); // 시뮬레이션

    if (mounted) {
      // 성공 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '회원가입이 완료되었습니다! 로그인해주세요.',
            style: TextStyle(
              fontFamily: 'Cafe24Ohsquare',
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(
            0xFF4CAF50,
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              12,
            ),
          ),
        ),
      );

      // 로그인 화면으로 이동
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder:
              (
                context,
                animation,
                secondaryAnimation,
              ) => const AuthLoginScreen(),
          transitionDuration: const Duration(
            milliseconds: 600,
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
                            -1.0,
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

  // 홈 화면 스타일의 Figma 버튼
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
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: width,
              height: 50,
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
                      BorderRadius.circular(25),
                ),
                shadows: [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 8,
                    offset: Offset(0, 4),
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
                        BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 10,
            top: 6,
            right: 10,
            child: Container(
              height: 38,
              child: GestureDetector(
                onTap: isLoading
                    ? null
                    : onPressed,
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
                          textAlign:
                              TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSize,
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

  // 홈 화면 스타일의 입력 필드
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    bool isPassword = false,
    TextInputType keyboardType =
        TextInputType.text,
    String? Function(String?)? validator,
    bool isConfirmPassword = false,
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
            isPassword &&
            (isConfirmPassword
                ? !_isConfirmPasswordVisible
                : !_isPasswordVisible),
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
                    (isConfirmPassword
                            ? _isConfirmPasswordVisible
                            : _isPasswordVisible)
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.white
                        .withOpacity(0.7),
                  ),
                  onPressed: () {
                    setState(() {
                      if (isConfirmPassword) {
                        _isConfirmPasswordVisible =
                            !_isConfirmPasswordVisible;
                      } else {
                        _isPasswordVisible =
                            !_isPasswordVisible;
                      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.black, // 홈 화면과 동일한 검은색 배경
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () =>
              Navigator.of(context).pop(),
        ),
        title: Text(
          '회원가입',
          style: TextStyle(
            fontFamily: 'Cafe24Ohsquare',
            fontSize: 22,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),

                // 헤더
                _buildHeader(),

                const SizedBox(height: 40),

                // 에러 메시지
                if (_errorMessage != null)
                  _buildErrorMessage(),

                // 이메일 입력
                _buildInputField(
                  controller: _emailController,
                  label: '이메일',
                  hint: 'example@email.com',
                  prefixIcon:
                      Icons.email_outlined,
                  keyboardType:
                      TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
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

                // 닉네임 입력
                _buildInputField(
                  controller: _nicknameController,
                  label: '닉네임',
                  hint: '사용할 닉네임을 입력하세요',
                  prefixIcon:
                      Icons.person_outline,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return '닉네임을 입력해주세요';
                    }
                    if (value.length < 2) {
                      return '닉네임은 2자 이상이어야 합니다';
                    }
                    if (value.length > 10) {
                      return '닉네임은 10자 이하여야 합니다';
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
                    if (value == null ||
                        value.isEmpty) {
                      return '비밀번호를 입력해주세요';
                    }
                    if (value.length < 8) {
                      return '비밀번호는 최소 8자 이상이어야 합니다';
                    }
                    if (!RegExp(
                      r'^(?=.*[a-zA-Z])(?=.*\d)',
                    ).hasMatch(value)) {
                      return '영문과 숫자를 포함해야 합니다';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // 비밀번호 확인 입력
                _buildInputField(
                  controller:
                      _confirmPasswordController,
                  label: '비밀번호 확인',
                  hint: '비밀번호를 다시 입력하세요',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  isConfirmPassword: true,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return '비밀번호 확인을 입력해주세요';
                    }
                    if (value !=
                        _passwordController
                            .text) {
                      return '비밀번호가 일치하지 않습니다';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // 비밀번호 조건 안내
                _buildPasswordRequirements(),

                const SizedBox(height: 30),

                // 회원가입 버튼
                _buildFigmaButton(
                  text: '회원가입',
                  color: const Color(0xFF4CAF50),
                  onPressed: _handleRegister,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 20),

                // 로그인 링크
                _buildLoginLink(),
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
        // 캐릭터 로고 (홈 화면과 동일한 스타일)
        Container(
          width: 100,
          height: 100,
          child: Image.asset(
            'assets/image/home_logo.png',
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) {
                  return Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors
                              .orange
                              .shade300,
                          borderRadius:
                              BorderRadius.circular(
                                20,
                              ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange
                                  .withOpacity(
                                    0.3,
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
                          child: Text(
                            '🐯',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors
                              .pink
                              .shade100,
                          borderRadius:
                              BorderRadius.circular(
                                20,
                              ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.pink
                                  .withOpacity(
                                    0.3,
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
                          child: Text(
                            '🐰',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'Omok Arena',
          style: TextStyle(
            fontFamily: 'Cafe24Ohsquare',
            fontSize: 32,
            color: Colors.white,
            height: 0,
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
          '새로운 계정을 만들어보세요',
          style: TextStyle(
            fontFamily: 'Cafe24Ohsquare',
            fontSize: 16,
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

  Widget _buildPasswordRequirements() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            '비밀번호 조건',
            style: TextStyle(
              fontFamily: 'Cafe24Ohsquare',
              fontSize: 16,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          _buildRequirementItem('• 최소 8자 이상'),
          _buildRequirementItem('• 영문 포함'),
          _buildRequirementItem('• 숫자 포함'),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Cafe24Ohsquare',
          fontSize: 14,
          color: Colors.white.withOpacity(0.8),
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '이미 계정이 있으신가요? ',
          style: TextStyle(
            fontFamily: 'Cafe24Ohsquare',
            fontSize: 14,
            color: Colors.white.withOpacity(0.7),
            letterSpacing: -0.2,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            '로그인',
            style: TextStyle(
              fontFamily: 'Cafe24Ohsquare',
              fontSize: 14,
              color: Colors.white,
              letterSpacing: -0.2,
              decoration:
                  TextDecoration.underline,
              decorationColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
