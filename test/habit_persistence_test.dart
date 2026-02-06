import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:habit_tracker/models/habit_frequency.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('HabitProvider persists data across instances', () async {
    // 1. Setup initial state with mock values
    SharedPreferences.setMockInitialValues({}); // Empty initially
    
    // 2. Create first provider and add data
    final provider1 = HabitProvider();
    await provider1.loadHabits();
    
    provider1.addHabit(
      'Persistent Habit', 
      'Test Desc', 
      0xe198, 
      0xFF2196F3, 
      HabitFrequency.daily()
    );
    
    // Verify it was added to memory
    expect(provider1.habits.length, 1);
    
    // 3. Create second provider (simulating app restart)
    // IMPORTANT: In a real app restart, the SharedPreferences instance persists.
    // In tests, setMockInitialValues sets the backing map for SharedPreferences.
    // However, SharedPreferences.getInstance() returns a singleton. 
    // Writing to one instance updates the singleton's backing store.
    
    final provider2 = HabitProvider();
    await provider2.loadHabits();
    
    // 4. Verify data was loaded
    expect(provider2.habits.length, 1);
    expect(provider2.habits.first.title, 'Persistent Habit');
    expect(provider2.habits.first.description, 'Test Desc');
    
    // 5. Modify in second provider
    final id = provider2.habits.first.id;
    provider2.toggleHabitCompletion(id, DateTime.now());
    
    // 6. Create third provider to verify modification persistence
    final provider3 = HabitProvider();
    await provider3.loadHabits();
    
    expect(provider3.habits.first.isCompletedOn(DateTime.now()), true);
  });
}
