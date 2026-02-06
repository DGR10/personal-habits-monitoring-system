import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:habit_tracker/models/habit_frequency.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Doing habit every 2 days for a "Every 3 days" habit should maintain streak', () async {
    final provider = HabitProvider();
    await provider.loadHabits();
    
    // Create habit with "Every 3 days"
    provider.addHabit('Flexible Test', 'Desc', 0x1, 0x1, const HabitFrequency(type: FrequencyType.daily, periodValue: 3));
    final id = provider.habits.first.id;
    
    final today = DateTime.now();
    // Schedule: Day 0, 3, 6...
    // User does: Day 0, 2, 4, 6...
    // Currently: 
    // Day 0: OK.
    // Day 2: Extra.
    // Day 3: MISSED (break).
    // Day 4: Extra.
    // Day 6: OK (New streak starts).
    // Result: Streak 1 (Day 6).
    
    // We want Result: Streak... 4? (0, 2, 4, 6 are 4 checks).
    // Or at least it shouldn't be 1.
    
    // Dates:
    final day0 = today.subtract(const Duration(days: 6));
    final day2 = today.subtract(const Duration(days: 4));
    final day4 = today.subtract(const Duration(days: 2));
    final day6 = today; // Today
    
    // To ensure "Day 0" is start date
    // We toggle Day 0 first.
    provider.toggleHabitCompletion(id, day0); // Start date adjusts to day0
    
    provider.toggleHabitCompletion(id, day2);
    provider.toggleHabitCompletion(id, day4);
    provider.toggleHabitCompletion(id, day6);
    
    // Expectation: 4
    expect(provider.habits.first.streak, 4, reason: "Streak should count all completions as long as gap <= 3");
  });
}
