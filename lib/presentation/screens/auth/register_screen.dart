import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:getting_started/core/services/auth_service.dart';
import 'package:getting_started/core/services/localization_service.dart'; // Thêm import
import 'package:getting_started/presentation/screens/auth/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register(BuildContext context) async {
    // Kiểm tra các trường nhập liệu
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = context.tr('fill_all_fields');
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = context.tr('passwords_dont_match');
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Gọi phương thức register từ AuthService
      final authService = Provider.of<AuthService>(context, listen: false);
      final success = await authService.register(username, email, password);

      if (success && mounted) {
        // Nếu đăng ký thành công, chuyển đến trang chính
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      } else if (mounted) {
        // Nếu đăng ký thất bại, hiển thị thông báo lỗi
        setState(() {
          _errorMessage =
              authService.error ?? context.tr('registration_failed');
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
                context.tr('sign_up_to_start'),
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // Nút đăng ký Google
              _buildSocialRegisterButton(
                context,
                imagePath: 'assets/google_logo.png',
                text: context.tr('continue_with_google'),
                backgroundColor: Colors.white,
                textColor: Colors.black,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.tr('google_register_not_impl')),
                    ),
                  );
                },
              ),
              const SizedBox(height: 15),

              // Nút đăng ký Meta
              _buildSocialRegisterButton(
                context,
                imagePath: 'assets/meta_logo.png',
                text: context.tr('continue_with_meta'),
                backgroundColor: Colors.blue,
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.tr('meta_register_not_impl')),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Điều hướng sang màn hình đăng nhập
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: Text.rich(
                  TextSpan(
                    text: "${context.tr('already_have_account')} ",
                    style: const TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: context.tr('sign_in'),
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Form đăng ký
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
                      label: context.tr('username'),
                      controller: _usernameController,
                    ),
                    const SizedBox(height: 10),
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
                    _buildTextField(
                      label: context.tr('confirm_password'),
                      obscureText: true,
                      controller: _confirmPasswordController,
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
                    const SizedBox(height: 10),

                    // Nút Sign Up
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: _isLoading ? null : () => _register(context),
                      child:
                          _isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : Text(context.tr('sign_up')),
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

  // Widget tạo nút đăng ký Google/Meta
  Widget _buildSocialRegisterButton(
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
