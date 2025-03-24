import 'package:flutter/material.dart';
import 'package:getting_started/presentation/screens/home/home_screen.dart';
import 'package:getting_started/presentation/screens/notifications/notifications_screen.dart';
import 'package:getting_started/presentation/screens/settings/settings_screen.dart';
import 'package:getting_started/presentation/screens/user/saved.dart';
import 'package:getting_started/presentation/screens/user/user_screen.dart';

class NavigationApp extends StatelessWidget {
  const NavigationApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Không wrap NavigationBottomBar trong MaterialApp
    return const NavigationBottomBar();
  }
}

class NavigationBottomBar extends StatefulWidget {
  const NavigationBottomBar({super.key});

  @override
  State<NavigationBottomBar> createState() => _NavigationState();
}

class _NavigationState extends State<NavigationBottomBar> {
  int currentPageIndex = 0;
  static const TextStyle optionStyle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
  );
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    SavedScreen(),
    UserScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: Center(child: _widgetOptions[currentPageIndex]),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: "Trang chủ",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: "Truyện đã lưu",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Cài đặt"),
        ],
        onTap: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        currentIndex: currentPageIndex,
        selectedItemColor: Color(0xfff61bfa),
        unselectedItemColor: Colors.black45,
        backgroundColor: Colors.deepPurple[50],
      ),
    );
  }
}
