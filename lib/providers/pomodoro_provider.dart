import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PomodoroProvider with ChangeNotifier {
  int _focusMinutes = 25;
  int _breakMinutes = 5;
  int _totalReps = 4;
  String _startSound = 'bell';
  String _breakSound = 'digital';
  String _endSound = 'nature';

  int get focusMinutes => _focusMinutes;
  int get breakMinutes => _breakMinutes;
  int get totalReps => _totalReps;
  String get startSound => _startSound;
  String get breakSound => _breakSound;
  String get endSound => _endSound;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _focusMinutes = prefs.getInt('pomodoro_focus') ?? 25;
    _breakMinutes = prefs.getInt('pomodoro_break') ?? 5;
    _totalReps = prefs.getInt('pomodoro_reps') ?? 4;
    _startSound = prefs.getString('pomodoro_start_sound') ?? 'bell';
    _breakSound = prefs.getString('pomodoro_break_sound') ?? 'digital';
    _endSound = prefs.getString('pomodoro_end_sound') ?? 'nature';
    notifyListeners();
  }

  Future<void> updateSettings({
    int? focusMinutes,
    int? breakMinutes,
    int? totalReps,
    String? startSound,
    String? breakSound,
    String? endSound,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (focusMinutes != null) {
      _focusMinutes = focusMinutes;
      await prefs.setInt('pomodoro_focus', focusMinutes);
    }
    if (breakMinutes != null) {
      _breakMinutes = breakMinutes;
      await prefs.setInt('pomodoro_break', breakMinutes);
    }
    if (totalReps != null) {
      _totalReps = totalReps;
      await prefs.setInt('pomodoro_reps', totalReps);
    }
    if (startSound != null) {
      _startSound = startSound;
      await prefs.setString('pomodoro_start_sound', startSound);
    }
    if (breakSound != null) {
      _breakSound = breakSound;
      await prefs.setString('pomodoro_break_sound', breakSound);
    }
    if (endSound != null) {
      _endSound = endSound;
      await prefs.setString('pomodoro_end_sound', endSound);
    }
    notifyListeners();
  }
}
