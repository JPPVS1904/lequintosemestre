import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Notificador global de alternância de tema (espelha a alternância isDarkMode do App.svelte)
class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = true; // escuro por padrão como o app Svelte

  ThemeNotifier() {
    _loadFromPrefs();
  }

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggle() {
    _isDarkMode = !_isDarkMode;
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('theme');
    if (saved == 'light') {
      _isDarkMode = false;
    } else {
      _isDarkMode = true;
    }
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', _isDarkMode ? 'dark' : 'light');
  }
}
