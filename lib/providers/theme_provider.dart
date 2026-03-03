import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? true;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  ThemeData get theme => _isDarkMode ? _darkTheme : _lightTheme;

  static final _darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFF4FC3F7),
      secondary: const Color(0xFF81D4FA),
      surface: const Color(0xFF0D1B2A),
      background: const Color(0xFF0A1628),
      error: const Color(0xFFFF6B6B),
    ),
    scaffoldBackgroundColor: const Color(0xFF0A1628),
    fontFamily: 'SF Pro Display',
    cardTheme: CardThemeData(
      color: const Color(0xFF1A2744),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );

  static final _lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF0288D1),
      secondary: const Color(0xFF0277BD),
      surface: Colors.white,
      background: const Color(0xFFE3F2FD),
      error: const Color(0xFFE53935),
    ),
    scaffoldBackgroundColor: const Color(0xFFE8F4FD),
    fontFamily: 'SF Pro Display',
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}
