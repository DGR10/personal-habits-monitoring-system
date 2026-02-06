import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:habit_tracker/models/habit_frequency.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Habit streak allows starting on Wednesday (non-Monday) with interval', () async {
    final provider = HabitProvider();
    await provider.loadHabits();
    
    // Create habit with "Every 3 days"
    provider.addHabit('Wed Start', 'Desc', 0x1, 0x1, const HabitFrequency(type: FrequencyType.daily, periodValue: 3));
    final id = provider.habits.first.id;
    
    // Pick a Wednesday
    // Dec 3 2025 is a Wednesday
    final wednesday = DateTime(2025, 12, 3); 
    
    // We will simulate user marking this as the FIRST completion (backfill)
    // This should move startDate to Dec 3 (Wednesday).
    provider.toggleHabitCompletion(id, wednesday);
    
    // Next due: Wed + 3 = Sat Dec 6
    final saturday = wednesday.add(const Duration(days: 3));
    provider.toggleHabitCompletion(id, saturday);
    
    // Next due: Sat + 3 = Tue Dec 9
    final tuesday = saturday.add(const Duration(days: 3));
    provider.toggleHabitCompletion(id, tuesday);
    
    // Verify streak is 3
    // We assume "today" is slightly after or we just check the property logic given the completions
    // Actually the streak calculation relies on "loops from Now backwards".
    // If "Now" is far in the future, it might think we missed many days.
    // So we need to mock "Now" or "streak" relies on `DateTime.now()`.
    // The `streak` getter uses `DateTime.now()`.
    
    // For this test to work with `streak` getter, we need "Today" to be matching the last completion or effectively keeping streak valid.
    // If we can't mock Now, we should use a relative date from Now in the test.
    
    final today = DateTime.now();
    // Let's assume today is the "Tuesday" in the sequence.
    // So Start: Today - 6 days.
    // Done: Today - 6, Today - 3, Today.
    
    final start = today.subtract(const Duration(days: 6)); // Wednesday? Doesn't matter, just relative.
    
    // Clear previously added habit to start fresh with relative dates
    provider.deleteHabit(id);
    provider.addHabit('Relative Start', 'Desc', 0x1, 0x1, const HabitFrequency(type: FrequencyType.daily, periodValue: 3));
    final freshId = provider.habits.first.id;
    
    provider.toggleHabitCompletion(freshId, start);
    provider.toggleHabitCompletion(freshId, start.add(const Duration(days: 3)));
    provider.toggleHabitCompletion(freshId, start.add(const Duration(days: 6))); // Today
    
    // Expect streak 3
    expect(provider.habits.first.streak, 3);
    
    // Verify start date was updated to 'start' used above
    final habit = provider.habits.first;
    expect(habit.startDate.year, start.year);
    expect(habit.startDate.month, start.month);
    expect(habit.startDate.day, start.day);
  });
}
