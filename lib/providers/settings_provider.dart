import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('vi');
  String _currency = 'VND';

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  String get currency => _currency;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('pref_darkMode') ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    
    final langCode = prefs.getString('pref_language') ?? 'vi';
    _locale = Locale(langCode);

    _currency = prefs.getString('pref_currency') ?? 'VND';
    
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pref_darkMode', isDark);
  }

  Future<void> setLanguage(String langCode) async {
    _locale = Locale(langCode);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pref_language', langCode);
  }

  Future<void> setCurrency(String currencyCode) async {
    _currency = currencyCode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pref_currency', currencyCode);
  }
}
