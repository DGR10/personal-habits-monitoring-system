import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/goal.dart';

class GoalProvider with ChangeNotifier {
  List<Goal> _goals = [];

  List<Goal> get goals => _goals;

  Future<void> loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final String? goalsJson = prefs.getString('goals');
    if (goalsJson != null) {
      final List<dynamic> decodedList = jsonDecode(goalsJson);
      _goals = decodedList.map((item) => Goal.fromJson(item)).toList();
      // Sort by deadline
      _goals.sort((a, b) => a.deadline.compareTo(b.deadline));
      notifyListeners();
    }
  }

  Future<void> saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = jsonEncode(_goals.map((e) => e.toJson()).toList());
    await prefs.setString('goals', encodedList);
  }

  void addGoal(String title, DateTime deadline, List<String> linkedHabitIds) {
    final newGoal = Goal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      deadline: deadline,
      linkedHabitIds: linkedHabitIds,
    );
    _goals.add(newGoal);
    // Sort by deadline
    _goals.sort((a, b) => a.deadline.compareTo(b.deadline));
    saveGoals();
    notifyListeners();
  }

  void updateGoal(Goal updatedGoal) {
    final index = _goals.indexWhere((g) => g.id == updatedGoal.id);
    if (index != -1) {
      _goals[index] = updatedGoal;
      saveGoals();
      notifyListeners();
    }
  }

  void deleteGoal(String id) {
    _goals.removeWhere((g) => g.id == id);
    saveGoals();
    notifyListeners();
  }
}
