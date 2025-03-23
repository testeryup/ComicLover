import 'package:flutter/material.dart';
import 'package:getting_started/presentation/screens/auth/login_screen.dart';

class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Welcome",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text(
                "Sign up to start",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // Nút đăng ký Google
              _buildSocialRegisterButton(
                context,
                imagePath: 'assets/google_logo.png',
                text: "Sign up with Google",
                backgroundColor: Colors.white,
                textColor: Colors.black,
                onPressed: () {},
              ),
              const SizedBox(height: 15),

              // Nút đăng ký Meta
              _buildSocialRegisterButton(
                context,
                imagePath: 'assets/meta_logo.png',
                text: "Sign up with Meta",
                backgroundColor: Colors.blue,
                textColor: Colors.white,
                onPressed: () {},
              ),

              const SizedBox(height: 20),

              // Điều hướng sang màn hình đăng nhập
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: const Text.rich(
                  TextSpan(
                    text: "Already have an account? ",
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: "Sign in!",
                        style: TextStyle(color: Colors.blue),
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
                    _buildTextField(label: "Login "),
                    const SizedBox(height: 10),
                    _buildTextField(label: "Password"),
                    const SizedBox(height: 10),
                    _buildTextField(
                      label: "Complete Password",
                      obscureText: true,
                    ),
                    const SizedBox(height: 10),

                    // Nút Register
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () {},
                      child: const Text("Sign Up"),
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
  Widget _buildTextField({required String label, bool obscureText = false}) {
    return TextField(
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
        icon: Image.asset(imagePath, height: 24),
        label: Text(text),
      ),
    );
  }
}
