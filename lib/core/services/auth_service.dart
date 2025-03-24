import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String? avatar;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.avatar,
  });
}

class AuthService extends ChangeNotifier {
  bool _isLoading = false;
  bool _isAuthenticated = false;
  User? _currentUser;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  User? get currentUser => _currentUser;
  String? get error => _error;

  // Constructor - kiểm tra xem người dùng đã đăng nhập chưa
  AuthService() {
    _checkLoginStatus();
  }

  // Kiểm tra trạng thái đăng nhập từ SharedPreferences
  Future<void> _checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      if (isLoggedIn) {
        final username = prefs.getString('username') ?? 'User';
        final email = prefs.getString('email') ?? 'user@example.com';

        _isAuthenticated = true;
        _currentUser = User(
          id: '1',
          username: username,
          email: email,
          avatar: null,
        );
      }
    } catch (e) {
      print('Error checking login status: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Đăng nhập với tài khoản hardcode
  Future<bool> login(String email, String password) async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      // Hardcode tài khoản (email: admin@demo.com, password: password)
      // Hoặc (email: user@demo.com, password: password)
      if ((email == 'admin@demo.com' && password == 'password') ||
          (email == 'user@demo.com' && password == 'password')) {
        _isAuthenticated = true;
        _currentUser = User(
          id: email == 'admin@demo.com' ? 'admin_1' : 'user_1',
          username: email == 'admin@demo.com' ? 'Admin' : 'User',
          email: email,
          avatar: null,
        );

        // Lưu trạng thái đăng nhập
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('username', _currentUser!.username);
        await prefs.setString('email', email);

        notifyListeners();
        return true;
      } else {
        _error = 'Email hoặc mật khẩu không đúng';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Đã xảy ra lỗi: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Đăng ký (giả lập)
  Future<bool> register(String username, String email, String password) async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      // Giả lập đăng ký thành công
      _isAuthenticated = true;
      _currentUser = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        username: username,
        email: email,
        avatar: null,
      );

      // Lưu trạng thái đăng nhập
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', username);
      await prefs.setString('email', email);

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Đã xảy ra lỗi: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Đăng xuất
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Xóa trạng thái đăng nhập
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      await prefs.remove('username');
      await prefs.remove('email');

      _isAuthenticated = false;
      _currentUser = null;
    } catch (e) {
      print('Error during logout: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Kiểm tra xem có phải lần đầu sử dụng app không
  Future<bool> isFirstTimeUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirstTime = prefs.getBool('isFirstTime') ?? true;

      if (isFirstTime) {
        await prefs.setBool('isFirstTime', false);
        return true;
      }

      return false;
    } catch (e) {
      print('Error checking first time user: $e');
      return false;
    }
  }

  // Xóa hết dữ liệu (chỉ dùng cho debug)
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      print('Error clearing data: $e');
    }
  }
}
