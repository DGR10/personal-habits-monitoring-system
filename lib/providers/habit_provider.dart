import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';
import '../models/habit_frequency.dart';
import '../models/habit_pause.dart';

class HabitProvider with ChangeNotifier {
  List<Habit> _habits = [];

  List<Habit> get habits => _habits;

  Future<void> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final String? habitsJson = prefs.getString('habits');
    if (habitsJson != null) {
      final List<dynamic> decodedList = jsonDecode(habitsJson);
      _habits = decodedList.map((item) => Habit.fromJson(item)).toList();
      notifyListeners();
    }
  }

  Future<void> saveHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = jsonEncode(_habits.map((h) => h.toJson()).toList());
    await prefs.setString('habits', encodedList);
  }

  void addHabit(String title, String description, int iconCode, int colorValue, HabitFrequency frequency) {
    final newHabit = Habit(
      id: DateTime.now().toString(),
      title: title,
      description: description,
      iconCode: iconCode,
      colorValue: colorValue,
      frequency: frequency,
      startDate: DateTime.now(),
    );
    _habits.add(newHabit);
    saveHabits();
    notifyListeners();
  }

  void updateHabit(String id, String title, String description, int iconCode, int colorValue, HabitFrequency frequency) {
    final index = _habits.indexWhere((habit) => habit.id == id);
    if (index != -1) {
      _habits[index] = _habits[index].copyWith(
        title: title,
        description: description,
        iconCode: iconCode,
        colorValue: colorValue,
        frequency: frequency,
      );
      saveHabits();
      notifyListeners();
    }
  }

  void pauseHabit(String id, DateTime startDate, DateTime endDate) {
    final index = _habits.indexWhere((habit) => habit.id == id);
    if (index != -1) {
      final currentPauses = List<HabitPause>.from(_habits[index].pauseIntervals);
      currentPauses.add(HabitPause(startDate: startDate, endDate: endDate));
      
      _habits[index] = _habits[index].copyWith(
        pauseIntervals: currentPauses,
      );
      saveHabits();
      notifyListeners();
    }
  }

  void unpauseHabit(String id) {
    // Logic to remove active pauses? Or clear all?
    // For now, let's assume we clear all future/current pauses or just the last one?
    // The requirement implies "taking a break".
    // Let's just clear all pauses for simplicity or maybe we don't need unpause if the date range expires.
    // But if user wants to come back early?
    // Let's remove any pause that contains today or is in the future.
    
    final index = _habits.indexWhere((habit) => habit.id == id);
    if (index != -1) {
      final now = DateTime.now();
      final currentPauses = List<HabitPause>.from(_habits[index].pauseIntervals);
      
      currentPauses.removeWhere((pause) => 
        pause.endDate.isAfter(now) || pause.contains(now)
      );
      
      _habits[index] = _habits[index].copyWith(
        pauseIntervals: currentPauses,
      );
      saveHabits();
      notifyListeners();
    }
  }

  void deleteHabit(String id) {
    _habits.removeWhere((habit) => habit.id == id);
    saveHabits();
    notifyListeners();
  }

  void toggleHabitCompletion(String id, DateTime date) {
    final index = _habits.indexWhere((habit) => habit.id == id);
    if (index != -1) {
      final habit = _habits[index];
      final dateString = _formatDate(date);
      final Set<String> newCompletedDays = Set.from(habit.completedDays);

      DateTime newStartDate = habit.startDate;
      if (newCompletedDays.contains(dateString)) {
        newCompletedDays.remove(dateString);
      } else {
        newCompletedDays.add(dateString);
        // If the new completion is before the current start date, update start date
        // to allow streaks to be calculated from this point backwards/forwards correctly
        if (date.isBefore(habit.startDate)) {
          newStartDate = date;
        }
      }

      final tempHabit = habit.copyWith(
        completedDays: newCompletedDays,
        startDate: newStartDate,
      );
      _habits[index] = tempHabit;
      saveHabits();
      notifyListeners();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
