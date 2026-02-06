import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:habit_tracker/models/habit_frequency.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Longest streak should update correctly when past completions are toggled', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = HabitProvider();
    await provider.loadHabits();
    
    // Create habit starting 10 days ago
    final startDate = DateTime.now().subtract(const Duration(days: 10));
    provider.addHabit('Streak Test', 'Testing', 0x1, 0x1, HabitFrequency.daily());
    
    // Hack to set start date (since addHabit uses Now)
    final habitId = provider.habits.first.id;
    // We can't easily set startDate via provider method, but for this test we can modify the list if needed
    // or just rely on the fact that we can toggle completions for "all" days and addHabit uses "today".
    // Wait, addHabit uses DateTime.now() as start date.
    // So we can only complete habits from today onwards? 
    // Habit.isDueOn checks `checkDate.isBefore(start)`.
    // So we can't test historical streaks unless we can set a past startDate.
    
    // Let's modify the habit directly in the list for the test context
    final habit = provider.habits.first;
    final pastHabit = habit.copyWith(startDate: startDate);
    // Use a reflection or just internals if possible? No.
    // We need to use updateHabit but it doesn't expose startDate.
    // We will just directly replace it in the list for testing purposes, assuming the provider exposes the list instance.
    provider.habits[0] = pastHabit;
    
    // Scenario: Complete 5 days in a row.
    // [X, X, X, X, X, _, _, _, _, _]
    for (int i = 0; i < 5; i++) {
        provider.toggleHabitCompletion(habitId, startDate.add(Duration(days: i)));
    }
    
    // Check longest streak
    expect(provider.habits.first.streak, 0); // Not due/done today (current streak is from end) (actually if last due was X days ago and completed, streak might be broke)
    // Actually current streak tracks backwards from now. If we missed days 6,7,8,9,10, streak is 0.
    expect(provider.habits.first.longestStreak, 5); // Should be 5.
    
    // Now Break the streak in the middle!
    // [X, X, _, X, X, ...]
    // Day 2 (index 2)
    provider.toggleHabitCompletion(habitId, startDate.add(const Duration(days: 2)));
    
    // Now we have two streaks of 2.
    // Longest streak should be 2.
    // BUT, implementation likely keeps it at 5 because it only increases monotonically.
    
    expect(provider.habits.first.longestStreak, 2, reason: "Longest streak should decrease if the long sequence is broken");
  });
}
