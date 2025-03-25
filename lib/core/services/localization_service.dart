import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService with ChangeNotifier {
  static const String _prefsKey = 'app_language';

  // Mặc định là tiếng Việt
  Locale _currentLocale = const Locale('vi');

  Locale get currentLocale => _currentLocale;

  // Các ngôn ngữ hỗ trợ
  static final List<Locale> supportedLocales = [
    const Locale('vi'),
    const Locale('en'),
  ];

  // Tên hiển thị của các ngôn ngữ
  static final Map<String, String> languageNames = {
    'vi': 'Tiếng Việt',
    'en': 'English',
  };

  // Ngôn ngữ mặc định
  static const Locale fallbackLocale = Locale('vi');

  // Dữ liệu dịch
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'ComicLover',
      'home': 'Home',
      'saved': 'Saved Comics',
      'settings': 'Settings',
      'profile': 'Profile',
      'search': 'Search',
      'reading_history': 'Reading History',
      'logout': 'Log Out',
      'logout_confirm': 'Are you sure you want to log out?',
      'cancel': 'Cancel',
      'continue_reading': 'Continue reading',
      'chapter': 'Chapter',
      'popular': 'Popular',
      'new_comics': 'New Comics',
      'recently_updated': 'Recently Updated',
      'view_all': 'View all',
      'device_info': 'Mobile Device N01',
      'student_info1': 'Nguyễn Mạnh Đạt - 22010220',
      'student_info2': 'Hoàng Thị Thảo Nhi - 22010062',
      'student_info3': 'Nguyễn Đức Phong - 22010481',
      'no_saved_comics': 'No saved comics',
      'add_comics': 'Add comics to read later',
      'sort_by_name': 'Sort by name',
      'sort_by_recent': 'Sort by recent',
      'sort_by_progress': 'Sort by progress',
      'feature_developing': 'Feature in development',
      'language': 'Language',
      'vietnamese': 'Vietnamese',
      'english': 'English',
      'detail': 'Detail',
      'continue_reading_chapter': 'Continue reading (Chapter',
      'start_reading': 'Start reading',
      'delete_from_the_list': 'Delete from the list',
      'sort_by': 'Sort by',
      'undo': 'Undo',
      'deleted': 'Deleted',
      'no_result': 'No result found',
      'search_manga': 'Search manga',
      'sort_by': 'Sort by',
      'name_asc': 'Name (A-Z)',
      'name_desc': 'Name (Z-A)',
      'latest_update': 'Latest Update',
      'trending_manga': 'Trending Manga',
      'no_manga_found': 'No manga found',
      'top_readers': 'Top Readers',
      'clear': 'Clear',
      'no_reading_history': 'No reading history yet',
      'stay_trending': 'Stay trending!',
      'manga_reader': 'Manga Reader',
      'from_category': 'From', // Used in "From {category}"
      'chapter': 'Chapter',
      'ongoing': 'Ongoing',
      'completed': 'Completed',
      'unknown': 'Unknown',
      'latest': 'Latest',
      'welcome': 'Welcome',
      'sign_in_to_start': 'Sign in to start',
      'email': 'Email',
      'password': 'Password',
      'continue_with_google': 'Continue with Google',
      'continue_with_meta': 'Continue with Meta',
      'no_account': 'Haven\'t account?',
      'sign_up': 'Sign up!',
      'continue': 'Continue',
      'forgot_password': 'Forgot password?',
      'enter_email_password': 'Please enter email and password',
      'login_failed': 'Login failed',
      'error_occurred': 'An error occurred',
      'account_hint': 'Hint: admin@demo.com / password',
      'sign_up_to_start': 'Sign up to start',
      'username': 'Username',
      'confirm_password': 'Confirm Password',
      'passwords_dont_match': 'Passwords don\'t match',
      'fill_all_fields': 'Please fill in all fields',
      'registration_failed': 'Registration failed',
      'already_have_account': 'Already have an account?',
      'sign_in': 'Sign in!',
      'google_login_not_impl': 'Google login not implemented yet',
      'meta_login_not_impl': 'Meta login not implemented yet',
      'google_register_not_impl': 'Google sign up not implemented yet',
      'meta_register_not_impl': 'Meta sign up not implemented yet',
      'forgot_password_not_impl': 'Forgot password feature not implemented yet',
      'manga_detail': 'Manga Details',
      'chapters_list': 'Chapters List',
      'description': 'Description',
      'status': 'Status',
      'genres': 'Genres',
      'reading_progress': 'Reading Progress',
      'continue_reading': 'Continue Reading',
      'continue_reading_chapter': 'Continue Reading (Chapter',
      'start_reading': 'Start Reading',
      'read_from_beginning': 'Read From Beginning',
      'no_chapters': 'No chapters available',
      'try_again': 'Try Again',
      'manga_not_found': 'Manga information not found',
      'reverse_order': 'Reverse Order',
      'next_chapter': 'Next Chapter',
      'previous_chapter': 'Previous Chapter',
      'chapter': 'Chapter',
      'cannot_load_image': 'Failed to load image',
      'no_images': 'No images available',
      'error_loading_chapter': 'Error loading chapter data',
      'save_manga': 'Save Manga',
      'remove_from_list': 'Remove From List',
      'added_to_list': 'Added to your list',
      'removed_from_list': 'Removed from your list',
      'ongoing': 'Ongoing',
      'completed': 'Completed',
      'error_loading_manga': 'Error loading manga',
      'already_on_newest_chapter': 'You have already read the newest chapter',
      'team_member': 'Team members',
    },
    'vi': {
      'app_title': 'ComicLover',
      'home': 'Trang chủ',
      'saved': 'Truyện đã lưu',
      'settings': 'Cài đặt',
      'profile': 'Tài khoản',
      'search': 'Tìm kiếm',
      'reading_history': 'Lịch sử đọc',
      'logout': 'Đăng xuất',
      'logout_confirm': 'Bạn có chắc chắn muốn đăng xuất?',
      'cancel': 'Hủy',
      'continue_reading': 'Tiếp tục đọc',
      'chapter': 'Chương',
      'popular': 'Phổ biến',
      'new_comics': 'Truyện mới',
      'recently_updated': 'Mới cập nhật',
      'view_all': 'Xem tất cả',
      'device_info': 'Thiết bị di động N01',
      'student_info1': 'Nguyễn Mạnh Đạt - 22010220',
      'student_info2': 'Hoàng Thị Thảo Nhi - 22010062',
      'student_info3': 'Nguyễn Đức Phong - 22010481',
      'no_saved_comics': 'Chưa có truyện nào được lưu',
      'add_comics': 'Thêm truyện để đọc sau',
      'sort_by_name': 'Sắp xếp theo tên',
      'sort_by_recent': 'Sắp xếp theo gần đây',
      'sort_by_progress': 'Sắp xếp theo tiến độ',
      'feature_developing': 'Tính năng đang phát triển',
      'language': 'Ngôn ngữ',
      'vietnamese': 'Tiếng Việt',
      'english': 'English',
      'detail': 'Xem chi tiết',
      'continue_reading_chapter': 'Tiếp tục đọc (Chương',
      'start_reading': 'Bắt đầu đọc',
      'delete_from_the_list': 'Xóa khỏi danh sách',
      'sort_by': 'Sắp xếp theo',
      'undo': 'Hoàn tác',
      'deleted': 'Đã xoá',
      'no_result': 'Không tìm thấy kết quả',
      'search_manga': 'Tìm truyện',
      'sort_by': 'Sắp xếp theo',
      'name_asc': 'Tên (A-Z)',
      'name_desc': 'Tên (Z-A)',
      'latest_update': 'Cập nhật mới nhất',
      'trending_manga': 'Truyện thịnh hành',
      'no_manga_found': 'Không tìm thấy truyện',
      'top_readers': 'Đọc nhiều nhất',
      'clear': 'Xóa',
      'no_reading_history': 'Chưa có lịch sử đọc',
      'stay_trending': 'Theo dõi xu hướng!',
      'manga_reader': 'Đọc Truyện',
      'from_category': 'Thể loại', // Used in "Thể loại {category}"
      'chapter': 'Chương',
      'ongoing': 'Đang cập nhật',
      'completed': 'Hoàn thành',
      'unknown': 'Không rõ',
      'latest': 'Mới nhất',
      'welcome': 'Xin chào',
      'sign_in_to_start': 'Đăng nhập để bắt đầu',
      'email': 'Email',
      'password': 'Mật khẩu',
      'continue_with_google': 'Tiếp tục với Google',
      'continue_with_meta': 'Tiếp tục với Meta',
      'no_account': 'Chưa có tài khoản?',
      'sign_up': 'Đăng ký!',
      'continue': 'Tiếp tục',
      'forgot_password': 'Quên mật khẩu?',
      'enter_email_password': 'Vui lòng nhập email và mật khẩu',
      'login_failed': 'Đăng nhập thất bại',
      'error_occurred': 'Đã xảy ra lỗi',
      'account_hint': 'Gợi ý: admin@demo.com / password',
      'sign_up_to_start': 'Đăng ký để bắt đầu',
      'username': 'Tên người dùng',
      'confirm_password': 'Xác nhận mật khẩu',
      'passwords_dont_match': 'Mật khẩu không khớp',
      'fill_all_fields': 'Vui lòng điền đầy đủ thông tin',
      'registration_failed': 'Đăng ký thất bại',
      'already_have_account': 'Đã có tài khoản?',
      'sign_in': 'Đăng nhập!',
      'google_login_not_impl':
          'Tính năng đăng nhập Google chưa được triển khai',
      'meta_login_not_impl': 'Tính năng đăng nhập Meta chưa được triển khai',
      'google_register_not_impl':
          'Tính năng đăng ký Google chưa được triển khai',
      'meta_register_not_impl': 'Tính năng đăng ký Meta chưa được triển khai',
      'forgot_password_not_impl':
          'Tính năng quên mật khẩu chưa được triển khai',
      'manga_detail': 'Chi Tiết Truyện',
      'chapters_list': 'Danh Sách Chương',
      'description': 'Nội Dung',
      'status': 'Trạng Thái',
      'genres': 'Thể Loại',
      'reading_progress': 'Tiến Độ Đọc',
      'continue_reading': 'Tiếp Tục Đọc',
      'continue_reading_chapter': 'Tiếp Tục Đọc (Chương',
      'start_reading': 'Bắt Đầu Đọc',
      'read_from_beginning': 'Đọc Lại Từ Đầu',
      'no_chapters': 'Chưa có chương nào',
      'try_again': 'Thử Lại',
      'manga_not_found': 'Không tìm thấy thông tin truyện',
      'reverse_order': 'Đảo Thứ Tự',
      'next_chapter': 'Chương Sau',
      'previous_chapter': 'Chương Trước',
      'cannot_load_image': 'Không thể tải hình ảnh',
      'no_images': 'Không có hình ảnh nào',
      'error_loading_chapter': 'Lỗi khi tải dữ liệu chapter',
      'save_manga': 'Lưu Truyện',
      'remove_from_list': 'Xóa Khỏi Danh Sách',
      'added_to_list': 'Đã thêm vào danh sách',
      'removed_from_list': 'Đã xóa khỏi danh sách',

      'error_loading_manga': 'Lỗi khi tải truyện',
      'already_on_newest_chapter': 'Bạn đã đọc đến chapter mới nhất',
      'team_member': 'Danh sách thành viên của nhóm',
    },
  };

  LocalizationService() {
    _loadSavedLocale();
  }

  // Lấy văn bản theo key
  String translate(String key) {
    return _localizedValues[_currentLocale.languageCode]?[key] ?? key;
  }

  // Chuyển đổi ngôn ngữ
  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale) || locale == _currentLocale) return;

    _currentLocale = locale;

    // Lưu vào SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, locale.languageCode);

    notifyListeners();
  }

  // Lấy ngôn ngữ đã lưu
  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_prefsKey);

      if (languageCode != null) {
        final locale = Locale(languageCode);
        if (supportedLocales.contains(locale)) {
          _currentLocale = locale;
        }
      }
    } catch (e) {
      debugPrint('Error loading locale: $e');
    }

    notifyListeners();
  }

  Future<void> toggleLocale() async {
    final newLocale =
        _currentLocale.languageCode == 'vi'
            ? const Locale('en')
            : const Locale('vi');
    await setLocale(newLocale);
  }

  // Danh sách các ngôn ngữ có thể chọn
  List<Map<String, dynamic>> get availableLanguages =>
      supportedLocales
          .map(
            (locale) => {
              'code': locale.languageCode,
              'name': languageNames[locale.languageCode] ?? locale.languageCode,
            },
          )
          .toList();
}

// Extension để dễ dàng sử dụng
extension TranslateExtension on BuildContext {
  LocalizationService get localization =>
      Provider.of<LocalizationService>(this, listen: false);
  String tr(String key) => localization.translate(key);
}
