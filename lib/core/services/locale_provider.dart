import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('vi', '');

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocaleFromPrefs();
  }

  Future<void> _loadLocaleFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String langCode = prefs.getString('language_code') ?? 'vi';
    _locale = Locale(langCode, '');
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (locale == _locale) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);

    _locale = locale;
    notifyListeners();
  }

  Future<void> toggleLocale() async {
    final newLocale =
        _locale.languageCode == 'vi'
            ? const Locale('en', '')
            : const Locale('vi', '');
    await setLocale(newLocale);
  }
}
