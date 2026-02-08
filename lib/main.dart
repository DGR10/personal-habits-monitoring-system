import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/habit_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/goal_provider.dart';
import 'providers/pomodoro_provider.dart';
import 'screens/home_screen.dart';
import 'screens/add_habit_screen.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';
import 'providers/locale_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadTheme()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => HabitProvider()..loadHabits()),
        ChangeNotifierProvider(create: (_) => GoalProvider()..loadGoals()),
        ChangeNotifierProvider(create: (_) => PomodoroProvider()..loadSettings()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp(
            onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
            theme: themeProvider.themeStyle == AppThemeStyle.nothing
                ? _buildNothingTheme(Brightness.light)
                : ThemeData(
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: themeProvider.seedColor,
                      brightness: Brightness.light,
                    ),
                    useMaterial3: true,
                  ),
            darkTheme: themeProvider.themeStyle == AppThemeStyle.nothing
                ? _buildNothingTheme(Brightness.dark)
                : ThemeData(
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: themeProvider.seedColor,
                      brightness: Brightness.dark,
                    ),
                    useMaterial3: true,
                  ),
            themeMode: themeProvider.themeMode,
            locale: localeProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('es'), // Spanish
            ],
            initialRoute: '/',
            routes: {
              '/': (context) => const HomeScreen(),
              '/add': (context) => const AddHabitScreen(),
            },
          );
        },
      ),
    );
  }

  ThemeData _buildNothingTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    const accentColor = Color(0xFFD71921);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        onPrimary: backgroundColor,
        secondary: accentColor,
        onSecondary: Colors.white,
        error: accentColor,
        onError: Colors.white,
        surface: backgroundColor,
        onSurface: primaryColor,
      ),
      fontFamily: 'monospace',
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: primaryColor,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? Colors.white24 : Colors.black12,
        thickness: 1,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: primaryColor,
        textColor: primaryColor,
      ),
      iconTheme: IconThemeData(
        color: primaryColor,
      ),
    );
  }
}
