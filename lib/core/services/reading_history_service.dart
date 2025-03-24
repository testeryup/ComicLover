import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ReadingHistoryService {
  static const String _historyKey = 'reading_history';
  static const int _maxHistoryItems = 5;

  // Lấy lịch sử đọc truyện
  Future<List<Map<String, dynamic>>> getReadingHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_historyKey) ?? [];
    
    return historyJson
        .map((item) => json.decode(item) as Map<String, dynamic>)
        .toList();
  }

  // Thêm truyện vào lịch sử đọc
  Future<void> addToHistory(Map<String, dynamic> manga) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_historyKey) ?? [];
    
    // Chuyển đổi lịch sử hiện tại thành danh sách đối tượng
    final history = historyJson
        .map((item) => json.decode(item) as Map<String, dynamic>)
        .toList();
    
    // Kiểm tra xem truyện đã có trong lịch sử chưa
    final existingIndex = history.indexWhere((item) => item['_id'] == manga['_id']);
    
    // Nếu đã có, xóa để thêm lại vào đầu danh sách
    if (existingIndex != -1) {
      history.removeAt(existingIndex);
    }
    
    // Thêm truyện mới vào đầu danh sách
    history.insert(0, {
      '_id': manga['_id'],
      'name': manga['name'],
      'thumb_url': manga['thumb_url'],
      'slug': manga['slug'],
      'chaptersLatest': manga['chaptersLatest'],
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    
    // Giới hạn số lượng truyện trong lịch sử
    if (history.length > _maxHistoryItems) {
      history.removeLast();
    }
    
    // Lưu lại lịch sử
    await prefs.setStringList(
      _historyKey,
      history.map((item) => json.encode(item)).toList(),
    );
  }

  // Xóa lịch sử đọc
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
} 