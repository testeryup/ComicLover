import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:getting_started/core/services/auth_service.dart';
import 'package:getting_started/core/services/localization_service.dart'; // Thêm import

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    // Simulate a splash screen delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authService = Provider.of<AuthService>(context, listen: false);

    // Check if user is already authenticated
    if (authService.isAuthenticated) {
      // Navigate to home if already authenticated
      Navigator.of(context).pushReplacementNamed('/');
    } else {
      // Navigate to login if not authenticated
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book_rounded, size: 100, color: Colors.white),
            const SizedBox(height: 24),
            Text(
              'ComicLover',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
