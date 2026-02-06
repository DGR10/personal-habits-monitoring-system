import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeStyle {
  material,
  nothing,
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Color _seedColor = Colors.blue;
  AppThemeStyle _themeStyle = AppThemeStyle.material;

  ThemeMode get themeMode => _themeMode;
  Color get seedColor => _seedColor;
  AppThemeStyle get themeStyle => _themeStyle;

  ThemeProvider() {
    loadTheme();
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final String? modeString = prefs.getString('themeMode');
    final int? colorValue = prefs.getInt('seedColor');
    final String? styleString = prefs.getString('themeStyle');

    if (modeString != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == modeString,
        orElse: () => ThemeMode.system,
      );
    }

    if (colorValue != null) {
      _seedColor = Color(colorValue);
    }

    if (styleString != null) {
      _themeStyle = AppThemeStyle.values.firstWhere(
        (e) => e.toString() == styleString,
        orElse: () => AppThemeStyle.material,
      );
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.toString());
  }

  Future<void> setSeedColor(Color color) async {
    _seedColor = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('seedColor', color.value);
  }

  Future<void> setThemeStyle(AppThemeStyle style) async {
    _themeStyle = style;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeStyle', style.toString());
  }
}
