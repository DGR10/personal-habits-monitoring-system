import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:habit_tracker/models/habit_frequency.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Add habit adds to list and saves', () async {
    final provider = HabitProvider();
    await provider.loadHabits();
    
    expect(provider.habits.isEmpty, true);

    // Corrección: Se añadió null al final para reminderTime
    provider.addHabit('Test Habit', 'Description', 0xe198, 0xFF2196F3, HabitFrequency.daily());
    
    expect(provider.habits.length, 1);
    expect(provider.habits.first.title, 'Test Habit');
    expect(provider.habits.first.iconCode, 0xe198);
    expect(provider.habits.first.colorValue, 0xFF2196F3);
  });

  test('Toggle habit completion updates state for specific date', () async {
    final provider = HabitProvider();
    await provider.loadHabits();
    // Corrección: Se añadió null al final para reminderTime
    provider.addHabit('Test Habit', 'Description', 0xe198, 0xFF2196F3, HabitFrequency.daily());
    final id = provider.habits.first.id;
    final today = DateTime.now();

    expect(provider.habits.first.isCompletedOn(today), false);
    expect(provider.habits.first.streak, 0);

    provider.toggleHabitCompletion(id, today);
    
    expect(provider.habits.first.isCompletedOn(today), true);
    expect(provider.habits.first.streak, 1);

    provider.toggleHabitCompletion(id, today);
    
    expect(provider.habits.first.isCompletedOn(today), false);
    expect(provider.habits.first.streak, 0);
  });

  test('Delete habit removes from list', () async {
    final provider = HabitProvider();
    await provider.loadHabits();
    // Corrección: Se añadió null al final para reminderTime
    provider.addHabit('Test Habit', 'Description', 0xe198, 0xFF2196F3, HabitFrequency.daily());
    final id = provider.habits.first.id;

    expect(provider.habits.length, 1);

    provider.deleteHabit(id);
    
    expect(provider.habits.isEmpty, true);
  });

  test('Update habit modifies existing habit', () async {
    final provider = HabitProvider();
    await provider.loadHabits();
    // Corrección: Se añadió null al final para reminderTime
    provider.addHabit('Original Title', 'Original Desc', 0xe198, 0xFF2196F3, HabitFrequency.daily());
    final id = provider.habits.first.id;

    // Corrección: Se añadió null al final para reminderTime
    provider.updateHabit(id, 'Updated Title', 'Updated Desc', 0xe000, 0xFFFF0000, HabitFrequency.daily());

    expect(provider.habits.first.title, 'Updated Title');
    expect(provider.habits.first.description, 'Updated Desc');
    expect(provider.habits.first.iconCode, 0xe000);
    expect(provider.habits.first.colorValue, 0xFFFF0000);
  });

  test('should calculate streaks correctly', () async {
    final provider = HabitProvider();
    await provider.loadHabits();
    // Corrección: Se añadió null al final para reminderTime
    provider.addHabit('Streak Habit', 'Desc', 0xe198, 0xFF2196F3, HabitFrequency.daily());
    
    // Manually update startDate to allow past completions to count
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    
    // We need to access the private list or use a method. 
    // Since we can't easily access private list, we can rely on the fact that provider.habits returns a list we can't modify? 
    // provider.habits is a getter returning _habits.
    // If _habits is returned directly, we can modify it? 
    // Usually providers return UnmodifiableListView or a copy.
    // Let's check HabitProvider.
    // It returns `List<Habit> get habits => _habits;` so it returns the reference.
    // But we need to replace the item in the list.
    
    final habit = provider.habits.first;
    final updatedHabit = habit.copyWith(startDate: yesterday.subtract(const Duration(days: 1)));
    
    // We can't easily inject this back without a method.
    // But wait, the test is running in the same isolate.
    // If HabitProvider exposes `_habits` via getter, we can't modify the list if it's not the same list instance or if we can't set it.
    // `List<Habit> get habits => _habits;`
    // `_habits` is a `List<Habit>`.
    // So `provider.habits` returns the list. We can do `provider.habits[0] = ...` IF the getter returns the actual list.
    // Let's assume it does.
    
    // Actually, a better way is to just mock the time or accept that we need to test with valid dates.
    // Or, we can add a method to provider `updateHabitStartDate`? No.
    
    // Let's try to modify the list directly.
    provider.habits[0] = updatedHabit;
    
    final id = provider.habits.first.id;
    
    // Complete today
    provider.toggleHabitCompletion(id, today);
    expect(provider.habits.first.streak, 1);
    expect(provider.habits.first.longestStreak, 1);
    
    // Complete yesterday
    provider.toggleHabitCompletion(id, yesterday);
    expect(provider.habits.first.streak, 2);
    expect(provider.habits.first.longestStreak, 2);
    
    // Uncomplete yesterday (break streak)
    provider.toggleHabitCompletion(id, yesterday);
    expect(provider.habits.first.streak, 1); // Only today
    expect(provider.habits.first.longestStreak, 1); // Longest is now 1 because we broke the sequence
  });

  test('Vacation mode pauses habit and preserves streak', () async {
    final provider = HabitProvider();
    await provider.loadHabits();
    provider.addHabit('Pause Habit', 'Desc', 0xe198, 0xFF2196F3, HabitFrequency.daily());
    final id = provider.habits.first.id;
    
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    
    // Complete yesterday to start a streak
    // Manually set start date to allow yesterday
    final habit = provider.habits.first;
    provider.habits[0] = habit.copyWith(startDate: yesterday.subtract(const Duration(days: 1)));
    
    provider.toggleHabitCompletion(id, yesterday);
    expect(provider.habits.first.streak, 1);
    
    // Pause today
    provider.pauseHabit(id, today, today);
    
    // Verify it's not due today
    expect(provider.habits.first.isDueOn(today), false);
    
    // Verify streak is preserved (still 1, not broken)
    expect(provider.habits.first.streak, 1);
    
    // Unpause (or check future)
    // If we check tomorrow, and it's not paused, it should be due.
    final tomorrow = today.add(const Duration(days: 1));
    expect(provider.habits.first.isDueOn(tomorrow), true);
  });

  test('Advanced statistics calculations', () async {
    final provider = HabitProvider();
    await provider.loadHabits();
    provider.addHabit('Stats Habit', 'Desc', 0xe198, 0xFF2196F3, HabitFrequency.daily());
    
    final today = DateTime.now();
    // Start date 6 days ago, total 7 days range ending today.
    final start = today.subtract(const Duration(days: 6));
    
    final habit = provider.habits.first.copyWith(startDate: start);
    provider.habits[0] = habit;
    final id = habit.id;
    
    // Pattern:
    // Day 0 (start): Completed
    // Day 1: Completed
    // Day 2: Completed
    // Day 3: Gap
    // Day 4: Gap
    // Day 5: Completed
    // Day 6 (today): Completed
    
    provider.toggleHabitCompletion(id, start);
    provider.toggleHabitCompletion(id, start.add(const Duration(days: 1)));
    provider.toggleHabitCompletion(id, start.add(const Duration(days: 2)));
    // Gap 3, 4
    provider.toggleHabitCompletion(id, start.add(const Duration(days: 5)));
    provider.toggleHabitCompletion(id, start.add(const Duration(days: 6)));
    
    final updatedHabit = provider.habits.first;
    
    // Median Streak: Streaks are [3, 2]. Median is (3+2)/2 = 2.5
    expect(updatedHabit.medianStreak, 2.5);
    
    // Churn Rate: Gap is 2 days. Average gap = 2.0
    expect(updatedHabit.churnRate, 2.0);
    
    // Calculate expected rate dynamically based on month boundary
    double expectedRate;
    if (today.day >= 7) {
       // All 7 days in current month
       // 5 completions / 7 days
       expectedRate = 5 / 7;
    } else {
       // Split across months. 
       // Days in current month = today.day
       // Which indices fall in this month? 
       // Map days 0..6 to dates. If date.month == today.month, count it.
       int due = 0;
       int completed = 0;
       final completionIndices = {0, 1, 2, 5, 6};
       
       for(int i=0; i<7; i++) {
          final d = start.add(Duration(days: i));
          if (d.month == today.month) {
            due++;
            if (completionIndices.contains(i)) completed++;
          }
       }
       expectedRate = due == 0 ? 0.0 : completed / due;
    }
    
    expect(updatedHabit.getCompletionRateForMonth(today), closeTo(expectedRate, 0.01));
  });
}
