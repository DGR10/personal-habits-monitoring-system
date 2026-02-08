import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../providers/theme_provider.dart';
import 'add_habit_screen.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;

  const HabitDetailScreen({super.key, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  String _selectedRange = 'Month';
  DateTime _currentMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // Re-fetch the habit from provider to ensure we have the latest state
    final habit = Provider.of<HabitProvider>(context).habits.firstWhere(
          (h) => h.id == widget.habit.id,
          orElse: () => widget.habit,
        );
    
    final themeProvider = Provider.of<ThemeProvider>(context);
    final l10n = AppLocalizations.of(context)!;
    final isNothingTheme = themeProvider.themeStyle == AppThemeStyle.nothing;
    final displayColor = isNothingTheme ? Theme.of(context).colorScheme.primary : Color(habit.colorValue);

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddHabitScreen(habit: habit),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: isNothingTheme ? Border.all(color: displayColor) : null,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: displayColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      IconData(habit.iconCode, fontFamily: 'MaterialIcons'),
                      color: displayColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.current,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                children: [
                                  Icon(Icons.local_fire_department, color: isNothingTheme ? displayColor : Colors.orange, size: 20),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      '${habit.streak}',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.longest,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                children: [
                                  Icon(Icons.emoji_events, color: isNothingTheme ? displayColor : Colors.amber, size: 20),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      '${habit.longestStreak}',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Time Range Selector
            if (isNothingTheme)
              _buildNothingTimeSelector(displayColor, l10n)
            else
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(value: 'Month', label: Text(l10n.month)),
                    ButtonSegment(value: 'Year', label: Text(l10n.year)),
                  ],
                  selected: {_selectedRange},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _selectedRange = newSelection.first;
                    });
                  },
                ),
              ),
            const SizedBox(height: 24),

            // Content Area
            Expanded(
              child: _buildContent(habit, displayColor, l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Habit habit, Color displayColor, AppLocalizations l10n) {
    switch (_selectedRange) {
      case 'Month':
        return _buildMonthView(habit, displayColor, l10n);
      case 'Year':
        return _buildYearView(habit, displayColor, l10n);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMonthView(Habit habit, Color displayColor, AppLocalizations l10n) {
    final daysInMonth = DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final weekdayOffset = firstDayOfMonth.weekday - 1; // 0 for Monday, 6 for Sunday
    
    int completedCount = 0;
    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, i);
      if (habit.isCompletedOn(date)) {
        completedCount++;
      }
    }
    final adherence = (completedCount / daysInMonth * 100).toStringAsFixed(0);
    final monthName = DateFormat.MMMM(Localizations.localeOf(context).toString()).format(_currentMonth);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
                });
              },
            ),
            Text(
              '$monthName ${_currentMonth.year}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                setState(() {
                  _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (Provider.of<ThemeProvider>(context).themeStyle == AppThemeStyle.nothing)
           Text(
             '[ ${l10n.monthlyAdherence(adherence)} ]',
             style: TextStyle(
               fontFamily: 'monospace',
               fontWeight: FontWeight.bold,
               color: displayColor,
             ),
           )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              l10n.monthlyAdherence(adherence),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: daysInMonth + weekdayOffset,
            itemBuilder: (context, index) {
              if (index < weekdayOffset) {
                return const SizedBox.shrink();
              }
              
              final day = index - weekdayOffset + 1;
              final date = DateTime(_currentMonth.year, _currentMonth.month, day);
              final isCompleted = habit.isCompletedOn(date);
              final isFuture = date.isAfter(DateTime.now());
              final isToday = date.year == DateTime.now().year && 
                              date.month == DateTime.now().month && 
                              date.day == DateTime.now().day;
              
              return GestureDetector(
                onTap: isFuture
                    ? null
                    : () {
                        Provider.of<HabitProvider>(context, listen: false)
                            .toggleHabitCompletion(habit.id, date);
                      },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted 
                        ? displayColor 
                        : (isToday ? Theme.of(context).colorScheme.primaryContainer : Colors.grey.shade100),
                    border: isToday ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2) : null,
                  ),
                  child: Text(
                    '$day',
                    style: TextStyle(
                      color: isCompleted 
                          ? Theme.of(context).colorScheme.onPrimary
                          : isFuture ? Colors.grey.shade400 : Colors.black87,
                      fontWeight: (isCompleted || isToday) ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildYearView(Habit habit, Color displayColor, AppLocalizations l10n) {
    final now = DateTime.now();
    final yearStart = DateTime(now.year, 1, 1);
    final daysInYear = DateUtils.getDaysInMonth(now.year, 2) == 29 ? 366 : 365;
    
    int completedCount = 0;
    for (int i = 0; i < daysInYear; i++) {
      final date = yearStart.add(Duration(days: i));
      if (habit.isCompletedOn(date)) {
        completedCount++;
      }
    }
    final adherence = (completedCount / daysInYear * 100).toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAdherenceHeader(l10n.yearOverview(now.year.toString()), '$adherence%', displayColor, l10n),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 20, // Dense grid
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
            ),
            itemCount: daysInYear,
            itemBuilder: (context, index) {
              final date = yearStart.add(Duration(days: index));
              
              // Don't show future dates
              if (date.isAfter(now)) {
                return Container(color: Colors.transparent);
              }

              final isCompleted = habit.isCompletedOn(date);
              
              return Container(
                decoration: BoxDecoration(
                  color: isCompleted 
                      ? displayColor 
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(Provider.of<ThemeProvider>(context).themeStyle == AppThemeStyle.nothing ? 0 : 2),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAdherenceHeader(String title, String percentage, Color displayColor, AppLocalizations l10n) {
    if (Provider.of<ThemeProvider>(context).themeStyle == AppThemeStyle.nothing) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title.toUpperCase(), style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, color: displayColor)),
           Text(
             '[ $percentage ]',
             style: TextStyle(
               fontFamily: 'monospace',
               fontWeight: FontWeight.bold,
               color: displayColor,
             ),
           ),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            l10n.complete(percentage),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNothingTimeSelector(Color color, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildNothingSelectorItem('Month', l10n.month, color),
        const SizedBox(width: 32),
        _buildNothingSelectorItem('Year', l10n.year, color),
      ],
    );
  }

  Widget _buildNothingSelectorItem(String value, String label, Color color) {
    final isSelected = _selectedRange == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedRange = value),
      child: Container(
        padding: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          border: isSelected 
              ? Border(bottom: BorderSide(color: color, width: 2))
              : null,
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: isSelected ? color : color.withOpacity(0.5),
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  String _getWeekday(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}
