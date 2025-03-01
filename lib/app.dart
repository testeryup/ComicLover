import 'package:flutter/material.dart';
import 'package:getting_started/presentation/screens/auth/login_screen.dart';
import 'package:getting_started/presentation/screens/home/home_screen.dart';
import 'package:getting_started/presentation/widgets/bottom_nav.dart';
import 'package:provider/provider.dart';

class ComicApp extends StatelessWidget {
  const ComicApp({super.key});
  bool _isLoggedIn() {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final String initialRoute = _isLoggedIn() ? '/home' : '/login';
    print("check init route: $initialRoute");
    return MaterialApp(
      title: 'ComicLover',
      initialRoute: initialRoute,
      routes: {
        '/home': (context) => NavigationBottomBar(),
        '/login': (context) => LoginScreen(),
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
    );
  }
}
