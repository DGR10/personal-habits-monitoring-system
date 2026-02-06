import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/screens/pomodoro_screen.dart';
import 'package:habit_tracker/providers/pomodoro_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createScreen() {
    return ChangeNotifierProvider(
      create: (_) => PomodoroProvider(),
      child: const MaterialApp(home: PomodoroScreen()),
    );
  }

  testWidgets('PomodoroScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createScreen());

    expect(find.text('Pomodoro Timer'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);
  });

  testWidgets('PomodoroScreen starts timer', (WidgetTester tester) async {
    await tester.pumpWidget(createScreen());

    await tester.tap(find.text('Start'));
    await tester.pump();

    // The provider might need a moment or pump to update
    await tester.pump();

    expect(find.text('Pause'), findsOneWidget);
    expect(find.text('Focus'), findsOneWidget);
  });
}

