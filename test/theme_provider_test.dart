import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Initial values are correct', () {
    final provider = ThemeProvider();
    expect(provider.themeMode, ThemeMode.system);
    expect(provider.seedColor, Colors.blue);
  });

  test('setThemeMode updates state and persists', () async {
    final provider = ThemeProvider();
    
    await provider.setThemeMode(ThemeMode.dark);
    
    expect(provider.themeMode, ThemeMode.dark);
    
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('themeMode'), ThemeMode.dark.toString());
  });

  test('setSeedColor updates state and persists', () async {
    final provider = ThemeProvider();
    const newColor = Colors.green;
    
    await provider.setSeedColor(newColor);
    
    expect(provider.seedColor.value, newColor.value);
    
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('seedColor'), newColor.value);
  });

  test('Loads from SharedPreferences', () async {
    SharedPreferences.setMockInitialValues({
      'themeMode': ThemeMode.light.toString(),
      'seedColor': Colors.purple.value,
    });

    final provider = ThemeProvider();
    // Wait for loadTheme to complete (it's called in constructor but async)
    // Since we can't await the constructor, we can await a small delay or just check if it updates eventually.
    // A better way for testing might be to expose loadTheme or have a separate init method, 
    // but for now let's just wait a bit as it's a microtask.
    await Future.delayed(Duration.zero);

    expect(provider.themeMode, ThemeMode.light);
    expect(provider.seedColor.value, Colors.purple.value);
  });
}
