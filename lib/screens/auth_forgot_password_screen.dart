import 'package:flutter/material.dart';
import 'auth_login_screen.dart';

class AuthForgotPasswordScreen
    extends StatefulWidget {
  const AuthForgotPasswordScreen({Key? key})
    : super(key: key);

  @override
  State<AuthForgotPasswordScreen> createState() =>
      _AuthForgotPasswordScreenState();
}

class _AuthForgotPasswordScreenState
    extends State<AuthForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController =
      TextEditingController();
  bool _isLoading = false;
  bool _isEmailSent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendResetLink() async {
    if (!_formKey.currentState!.validate())
      return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // TODO: 실제 비밀번호 재설정 로직 구현 (Firebase Auth 등)
    await Future.delayed(
      const Duration(seconds: 2),
    ); // 시뮬레이션

    setState(() {
      _isLoading = false;
      _isEmailSent = true;
    });
  }

  void _backToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) =>
            const AuthLoginScreen(),
      ),
    );
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
          '비밀번호 찾기',
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
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // 헤더
              _buildHeader(),

              const SizedBox(height: 50),

              if (_isEmailSent)
                _buildSuccessMessage()
              else
                _buildResetForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // 아이콘
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(
              0xFF89E0F7,
            ).withOpacity(0.2),
            borderRadius: BorderRadius.circular(
              40,
            ),
            border: Border.all(
              color: const Color(
                0xFF89E0F7,
              ).withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Icon(
            _isEmailSent
                ? Icons.mark_email_read
                : Icons.lock_reset,
            size: 40,
            color: const Color(0xFF5C47CE),
          ),
        ),

        const SizedBox(height: 20),

        Text(
          _isEmailSent
              ? '이메일을 확인하세요'
              : '비밀번호를 잊으셨나요?',
          style: TextStyle(
            fontFamily: 'Cafe24Ohsquare',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF5C47CE),
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 12),

        Text(
          _isEmailSent
              ? '비밀번호 재설정 링크를 이메일로 보내드렸습니다.\n이메일을 확인하고 링크를 클릭해주세요.'
              : '가입하신 이메일 주소를 입력하시면\n비밀번호 재설정 링크를 보내드립니다.',
          style: TextStyle(
            fontFamily: 'SUIT',
            fontSize: 14,
            color: const Color(
              0xFF5C47CE,
            ).withOpacity(0.7),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildResetForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          // 에러 메시지
          if (_errorMessage != null)
            _buildErrorMessage(),

          // 이메일 입력
          _buildEmailField(),

          const SizedBox(height: 30),

          // 재설정 링크 전송 버튼
          _buildSendButton(),

          const SizedBox(height: 20),

          // 로그인으로 돌아가기
          _buildBackToLoginButton(),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Column(
      children: [
        // 성공 메시지 카드
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(
              0xFF89E0F7,
            ).withOpacity(0.1),
            borderRadius: BorderRadius.circular(
              16,
            ),
            border: Border.all(
              color: const Color(
                0xFF89E0F7,
              ).withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.check_circle,
                size: 60,
                color: const Color(0xFF89E0F7),
              ),

              const SizedBox(height: 16),

              Text(
                '이메일 전송 완료!',
                style: TextStyle(
                  fontFamily: 'SUIT',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF5C47CE),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _emailController.text,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                  color: const Color(
                    0xFF5C47CE,
                  ).withOpacity(0.8),
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                '위 이메일 주소로 비밀번호 재설정 링크를 보내드렸습니다.\n이메일을 확인하고 링크를 클릭하여 새로운 비밀번호를 설정해주세요.',
                style: TextStyle(
                  fontFamily: 'SUIT',
                  fontSize: 14,
                  color: const Color(
                    0xFF5C47CE,
                  ).withOpacity(0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // 이메일이 오지 않았을 때
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(
              12,
            ),
            border: Border.all(
              color: Colors.orange.withOpacity(
                0.3,
              ),
            ),
          ),
          child: Column(
            children: [
              Text(
                '이메일이 오지 않았나요?',
                style: TextStyle(
                  fontFamily: 'SUIT',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                '• 스팸 메일함을 확인해보세요\n• 이메일 주소가 정확한지 확인해보세요\n• 몇 분 후에 다시 시도해보세요',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12,
                  color: Colors.orange.shade600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // 다시 보내기 버튼
        OutlinedButton(
          onPressed: () {
            setState(() {
              _isEmailSent = false;
            });
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: const Color(0xFF89E0F7),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                25,
              ),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 12,
            ),
          ),
          child: Text(
            '다시 보내기',
            style: TextStyle(
              fontFamily: 'SUIT',
              fontSize: 14,
              color: const Color(0xFF5C47CE),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // 로그인으로 돌아가기
        _buildBackToLoginButton(),
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

  Widget _buildSendButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : _handleSendResetLink,
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
                '비밀번호 재설정 링크 전송',
                style: TextStyle(
                  fontFamily: 'SUIT',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildBackToLoginButton() {
    return TextButton(
      onPressed: _backToLogin,
      child: Text(
        '로그인으로 돌아가기',
        style: TextStyle(
          fontFamily: 'SUIT',
          fontSize: 14,
          color: const Color(
            0xFF5C47CE,
          ).withOpacity(0.8),
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
