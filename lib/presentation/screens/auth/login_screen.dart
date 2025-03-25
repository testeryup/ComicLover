import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:getting_started/core/services/auth_service.dart';
import 'package:getting_started/core/services/localization_service.dart'; // Thêm import
import 'package:getting_started/presentation/screens/auth/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login(BuildContext context) async {
    // Kiểm tra các trường nhập liệu
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = context.tr('enter_email_password');
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Gọi phương thức login từ AuthService
      final authService = Provider.of<AuthService>(context, listen: false);
      final success = await authService.login(email, password);

      if (success && mounted) {
        // Nếu đăng nhập thành công, chuyển đến trang chính
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      } else if (mounted) {
        // Nếu đăng nhập thất bại, hiển thị thông báo lỗi
        setState(() {
          _errorMessage = authService.error ?? context.tr('login_failed');
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '${context.tr('error_occurred')}: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Text(
                context.tr('welcome'),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                context.tr('sign_in_to_start'),
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // Nút đăng nhập Google
              _buildSocialLoginButton(
                context,
                imagePath: 'assets/google_logo.png',
                text: context.tr('continue_with_google'),
                backgroundColor: Colors.white,
                textColor: Colors.black,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.tr('google_login_not_impl')),
                    ),
                  );
                },
              ),
              const SizedBox(height: 15),

              // Nút đăng nhập Meta
              _buildSocialLoginButton(
                context,
                imagePath: 'assets/meta_logo.png',
                text: context.tr('continue_with_meta'),
                backgroundColor: Colors.blue,
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.tr('meta_login_not_impl'))),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Điều hướng sang màn hình đăng ký
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
                child: Text.rich(
                  TextSpan(
                    text: "${context.tr('no_account')} ",
                    style: const TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: context.tr('sign_up'),
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Form đăng nhập
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 204, 199, 182),
                      Color(0xFFA2B2FC),
                    ],
                    begin: Alignment(-0.9, -0.9),
                    end: Alignment(0.9, 0.9),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _buildTextField(
                      label: context.tr('email'),
                      controller: _emailController,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      label: context.tr('password'),
                      obscureText: true,
                      controller: _passwordController,
                    ),
                    const SizedBox(height: 10),

                    // Hiển thị lỗi nếu có
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                context.tr('forgot_password_not_impl'),
                              ),
                            ),
                          );
                        },
                        child: Text(
                          context.tr('forgot_password'),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Nút continue
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: _isLoading ? null : () => _login(context),
                      child:
                          _isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : Text(context.tr('continue')),
                    ),

                    // Thêm gợi ý tài khoản đăng nhập
                    const SizedBox(height: 16),
                    Text(
                      context.tr('account_hint'),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget tạo TextField
  Widget _buildTextField({
    required String label,
    bool obscureText = false,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        border: const UnderlineInputBorder(),
        labelStyle: const TextStyle(color: Colors.white),
      ),
    );
  }

  // Widget tạo nút đăng nhập Google/Meta
  Widget _buildSocialLoginButton(
    BuildContext context, {
    required String imagePath,
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(76),
            spreadRadius: 3,
            blurRadius: 7,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: onPressed,
        icon: Image.asset(
          imagePath,
          height: 24,
          errorBuilder: (context, error, stackTrace) {
            // Nếu không tìm thấy hình ảnh, hiển thị icon thay thế
            return Icon(
              backgroundColor == Colors.white ? Icons.login : Icons.facebook,
              size: 24,
              color: textColor,
            );
          },
        ),
        label: Text(text),
      ),
    );
  }
}
