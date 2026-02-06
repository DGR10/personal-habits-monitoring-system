import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:habit_tracker/models/habit_frequency.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Backfilled completions should count towards streak even if before original start date', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = HabitProvider();
    await provider.loadHabits();
    
    // Create habit TODAY
    // Frequency: Only even days? No, Interval: Every 3 days.
    provider.addHabit('Backfill Test', 'Desc', 0x1, 0x1, const HabitFrequency(type: FrequencyType.daily, periodValue: 3));
    final habitId = provider.habits.first.id;
    final today = DateTime.now();
    
    // User marks: Today, Today-3, Today-6
    // These align with "Every 3 days" starting from Today going backwards.
    // If StartDate is Today:
    // Today is day 0 (Due).
    // Today-3 is before start date. isDueOn(Today-3) returns false.
    
    final day0 = today;
    final day3 = today.subtract(const Duration(days: 3));
    final day6 = today.subtract(const Duration(days: 6));
    
    provider.toggleHabitCompletion(habitId, day0);
    provider.toggleHabitCompletion(habitId, day3);
    provider.toggleHabitCompletion(habitId, day6);
    
    // Expectation: Streak should be 3.
    // Current Reality likely: 1 (only today counts).
    
    expect(provider.habits.first.streak, 3, reason: "Streak should include backfilled valid intervals");
  });
}
