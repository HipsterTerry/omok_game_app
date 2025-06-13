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
        const SnackBar(
          content: Text(
            '회원가입이 완료되었습니다! 로그인해주세요.',
          ),
          backgroundColor: Color(0xFF89E0F7),
        ),
      );

      // 로그인 화면으로 이동
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              const AuthLoginScreen(),
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF5C47CE),
          ),
          onPressed: () =>
              Navigator.of(context).pop(),
        ),
        title: Text(
          '회원가입',
          style: TextStyle(
            fontFamily: 'Cafe24Ohsquare',
            fontSize: 20,
            color: const Color(0xFF5C47CE),
            fontWeight: FontWeight.bold,
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
                const SizedBox(height: 20),

                // 헤더
                _buildHeader(),

                const SizedBox(height: 40),

                // 에러 메시지
                if (_errorMessage != null)
                  _buildErrorMessage(),

                // 이메일 입력
                _buildEmailField(),

                const SizedBox(height: 20),

                // 닉네임 입력
                _buildNicknameField(),

                const SizedBox(height: 20),

                // 비밀번호 입력
                _buildPasswordField(),

                const SizedBox(height: 20),

                // 비밀번호 확인 입력
                _buildConfirmPasswordField(),

                const SizedBox(height: 30),

                // 비밀번호 조건 안내
                _buildPasswordRequirements(),

                const SizedBox(height: 30),

                // 회원가입 버튼
                _buildRegisterButton(),

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
        // 로고
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              15,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF8BBEDC,
                ).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              15,
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
                              15,
                            ),
                      ),
                      child: const Center(
                        child: Text(
                          '🎮',
                          style: TextStyle(
                            fontSize: 30,
                          ),
                        ),
                      ),
                    );
                  },
            ),
          ),
        ),

        const SizedBox(height: 15),

        Text(
          'Omok Arena 가입하기',
          style: TextStyle(
            fontFamily: 'Cafe24Ohsquare',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF5C47CE),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          '새로운 계정을 만들어 게임을 시작하세요',
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

  Widget _buildNicknameField() {
    return TextFormField(
      controller: _nicknameController,
      decoration: InputDecoration(
        labelText: '닉네임',
        hintText: '게임에서 사용할 닉네임',
        prefixIcon: Icon(
          Icons.person_outlined,
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
          return '닉네임을 입력해주세요';
        }
        if (value.length < 2) {
          return '닉네임은 2자 이상이어야 합니다';
        }
        if (value.length > 12) {
          return '닉네임은 12자 이하여야 합니다';
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
        if (value.length < 8) {
          return '비밀번호는 8자 이상이어야 합니다';
        }
        if (!RegExp(
          r'^(?=.*[a-zA-Z])(?=.*\d)',
        ).hasMatch(value)) {
          return '영문과 숫자를 포함해야 합니다';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: !_isConfirmPasswordVisible,
      decoration: InputDecoration(
        labelText: '비밀번호 확인',
        hintText: '비밀번호를 다시 입력하세요',
        prefixIcon: Icon(
          Icons.lock_outlined,
          color: const Color(
            0xFF5C47CE,
          ).withOpacity(0.7),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isConfirmPasswordVisible
                ? Icons.visibility
                : Icons.visibility_off,
            color: const Color(
              0xFF5C47CE,
            ).withOpacity(0.7),
          ),
          onPressed: () {
            setState(() {
              _isConfirmPasswordVisible =
                  !_isConfirmPasswordVisible;
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
          return '비밀번호 확인을 입력해주세요';
        }
        if (value != _passwordController.text) {
          return '비밀번호가 일치하지 않습니다';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordRequirements() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(
          0xFF89E0F7,
        ).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(
            0xFF89E0F7,
          ).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            '비밀번호 조건',
            style: TextStyle(
              fontFamily: 'SUIT',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5C47CE),
            ),
          ),
          const SizedBox(height: 8),
          _buildRequirementItem('8자 이상'),
          _buildRequirementItem('영문 포함'),
          _buildRequirementItem('숫자 포함'),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 2,
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: const Color(
              0xFF5C47CE,
            ).withOpacity(0.6),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12,
              color: const Color(
                0xFF5C47CE,
              ).withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : _handleRegister,
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
                '가입하기',
                style: TextStyle(
                  fontFamily: 'SUIT',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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
            fontFamily: 'SUIT',
            fontSize: 14,
            color: const Color(
              0xFF5C47CE,
            ).withOpacity(0.7),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) =>
                    const AuthLoginScreen(),
              ),
            );
          },
          child: Text(
            '로그인',
            style: TextStyle(
              fontFamily: 'SUIT',
              fontSize: 14,
              color: const Color(0xFF5C47CE),
              fontWeight: FontWeight.bold,
              decoration:
                  TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
