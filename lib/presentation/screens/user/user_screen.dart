import 'package:flutter/material.dart';
import 'package:getting_started/presentation/screens/auth/login_screen.dart';
import 'package:getting_started/presentation/widgets/language_switcher.dart';
import 'package:provider/provider.dart';
import 'package:getting_started/core/services/auth_service.dart';
import 'package:getting_started/core/services/localization_service.dart'; // Thêm import này

class UserScreen extends StatelessWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        if (authService.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!authService.isAuthenticated) {
          // Nếu chưa đăng nhập, chuyển hướng đến trang đăng nhập
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/login');
          });
          return const SizedBox.shrink();
        }

        final user = authService.currentUser!;

        return Scaffold(
          appBar: AppBar(title: Text(context.tr('profile'))), // Đa ngôn ngữ
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Phần header profile giữ nguyên
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          user.username[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.username,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.email,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                // Menu items với đa ngôn ngữ
                ListTile(
                  leading: const Icon(Icons.bookmark),
                  title: Text(context.tr('saved')),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pushNamed(context, '/saved');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.supervised_user_circle),
                  title: Text(context.tr('team_member')),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pushNamed(context, '/authors');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(context.tr('reading_history')),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.tr('feature_developing'))),
                    );
                  },
                ),
                const Divider(),

                ListTile(
                  leading: const Icon(Icons.settings),
                  title: Text(context.tr('settings')),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.tr('feature_developing'))),
                    );
                  },
                ),
                const Divider(),

                // Language switcher giữ nguyên
                const LanguageSwitcher(),
                const Divider(),

                // Đăng xuất đa ngôn ngữ
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.red[700]),
                  title: Text(
                    context.tr('logout'),
                    style: TextStyle(color: Colors.red[700]),
                  ),
                  onTap: () => _handleLogout(context, authService),
                ),

                // Thông tin ứng dụng đa ngôn ngữ
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        context.tr('device_info'),
                        style: const TextStyle(color: Colors.grey),
                      ),
                      // const SizedBox(height: 8),
                      // Text(
                      //   context.tr('student_info1'),
                      //   style: const TextStyle(color: Colors.grey),
                      // ),
                      // const SizedBox(height: 8),
                      // Text(
                      //   context.tr('student_info2'),
                      //   style: const TextStyle(color: Colors.grey),
                      // ),
                      // const SizedBox(height: 8),
                      // Text(
                      //   context.tr('student_info3'),
                      //   style: const TextStyle(color: Colors.grey),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Tách logic đăng xuất ra thành một phương thức riêng - thêm đa ngôn ngữ
  Future<void> _handleLogout(
    BuildContext context,
    AuthService authService,
  ) async {
    // Dialog xác nhận đa ngôn ngữ
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(context.tr('logout')),
            content: Text(context.tr('logout_confirm')),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(context.tr('cancel')),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(context.tr('logout')),
              ),
            ],
          ),
    );

    // Phần còn lại không đổi
    if (shouldLogout == true && context.mounted) {
      try {
        await authService.logout();
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Đã xảy ra lỗi: $e')));
        }
      }
    }
  }
}
