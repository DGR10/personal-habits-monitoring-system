import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../providers/theme_provider.dart';
import 'add_habit_screen.dart';
import 'habit_detail_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';
import 'goals_screen.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Main Content
            Expanded(
              child: _selectedIndex == 0
                  ? _buildHabitList()
                  : _selectedIndex == 1
                      ? const StatsScreen()
                      : _selectedIndex == 2 
                          ? const GoalsScreen()
                          : const SettingsScreen(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Provider.of<ThemeProvider>(context).themeStyle == AppThemeStyle.nothing 
          ? _buildNothingNavigationBar(l10n)
          : NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.list),
            label: l10n.habits,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart),
            label: l10n.stats,
          ),
          NavigationDestination(
            icon: const Icon(Icons.flag),
            label: l10n.goals,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings),
            label: l10n.settingsTitle,
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/add');
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildHabitList() {
    final themeStyle = Provider.of<ThemeProvider>(context).themeStyle;
    final l10n = AppLocalizations.of(context)!;
    
    return Consumer<HabitProvider>(
      builder: (context, provider, child) {
        if (provider.habits.isEmpty) {
          return Center(
            child: Text(
              l10n.noHabitsYet,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: provider.habits.length,
          itemBuilder: (context, index) {
            final habit = provider.habits[index];
            final isDueToday = habit.isDueOn(DateTime.now());

            if (themeStyle == AppThemeStyle.nothing) {
              return _buildNothingHabitCard(habit, isDueToday, provider);
            }
            
            return Opacity(
              opacity: isDueToday ? 1.0 : 0.5,
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                elevation: 0,
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HabitDetailScreen(habit: habit),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Color(habit.colorValue).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                IconData(habit.iconCode, fontFamily: 'MaterialIcons'),
                                color: Color(habit.colorValue),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    habit.title,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (!isDueToday)
                                    Text(
                                      l10n.notDueToday,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Builder(
                              builder: (context) {
                                final now = DateTime.now();
                                int completedCount = 0;
                                for (int i = 0; i < 7; i++) {
                                  final date = now.subtract(Duration(days: i));
                                  if (habit.isCompletedOn(date)) {
                                    completedCount++;
                                  }
                                }
                                final adherence = (completedCount / 7 * 100).toStringAsFixed(0);
                                return Text(
                                  '$adherence%',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }
                            ),
                            IconButton(
                              icon: const Icon(Icons.more_horiz),
                              onPressed: () => _showHabitOptions(context, habit),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Days Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(7, (dayIndex) {
                          final date = DateTime.now().subtract(Duration(days: 6 - dayIndex));
                          final isCompleted = habit.isCompletedOn(date);
                          final isDue = habit.isDueOn(date);
                          
                          return GestureDetector(
                            onTap: () {
                              // Allow toggling past days or today if due
                              // Or allow toggling anyway? 
                              // Let's allow toggling but visual indication is different.
                              provider.toggleHabitCompletion(habit.id, date);
                            },
                            child: Column(
                              children: [
                                Text(
                                  _getWeekday(date.weekday),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isCompleted 
                                          ? Color(habit.colorValue) 
                                          : isDue ? Colors.grey : Colors.grey.withOpacity(0.2),
                                      width: 1,
                                    ),
                                    color: isCompleted 
                                        ? Color(habit.colorValue) 
                                        : isDue ? Colors.transparent : Colors.grey.withOpacity(0.1),
                                  ),
                                  child: isCompleted
                                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                                      : null,
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }



  void _showHabitOptions(BuildContext context, dynamic habit) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(l10n.options, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(l10n.deleteHabit, style: const TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context, habit);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: Text(l10n.editHabit),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddHabitScreen(habit: habit),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.habitDetail),
                subtitle: Text(l10n.habitDetailSubtitle),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HabitDetailScreen(habit: habit),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, dynamic habit) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteHabitTitle),
        content: Text(l10n.deleteHabitConfirmation(habit.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Provider.of<HabitProvider>(context, listen: false).deleteHabit(habit.id);
              Navigator.pop(context);
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildNothingHabitCard(dynamic habit, bool isDueToday, HabitProvider provider) {
    final color = Theme.of(context).colorScheme.primary;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(0), // Sharp corners
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
             onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HabitDetailScreen(habit: habit),
                  ),
                );
              },
            child: Row(
              children: [
                 Icon(
                    IconData(habit.iconCode, fontFamily: 'MaterialIcons'),
                    color: color,
                    size: 24,
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    habit.title.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'monospace', 
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                 IconButton(
                    icon: Icon(Icons.more_horiz, color: color),
                    onPressed: () => _showHabitOptions(context, habit),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (dayIndex) {
              final date = DateTime.now().subtract(Duration(days: 6 - dayIndex));
              final isCompleted = habit.isCompletedOn(date);
              final isDue = habit.isDueOn(date);
              final isToday = dayIndex == 6; // last index is today

              if (!isDue && !isCompleted) {
                 return Text('.', style: TextStyle(color: color.withOpacity(0.3), fontWeight: FontWeight.bold));
              }

              return GestureDetector(
                onTap: () => provider.toggleHabitCompletion(habit.id, date),
                child: Container(
                  width: 32, 
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isCompleted ? color : null,
                    border: Border.all(color: color),
                  ),
                  child: isCompleted 
                      ? Icon(Icons.check, size: 20, color: Theme.of(context).colorScheme.onPrimary)
                      : isToday 
                          ? Text('T', style: TextStyle(color: color, fontWeight: FontWeight.bold))
                          : null,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNothingNavigationBar(AppLocalizations l10n) {
    final color = Theme.of(context).colorScheme.primary;
    final items = [
      {'icon': Icons.list, 'label': l10n.habits.toUpperCase()},
      {'icon': Icons.bar_chart, 'label': l10n.stats.toUpperCase()},
      {'icon': Icons.flag, 'label': l10n.goals.toUpperCase()},
      {'icon': Icons.settings, 'label': l10n.settingsTitle.toUpperCase()},
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: color, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isSelected = _selectedIndex == index;
          final item = items[index];
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item['icon'] as IconData,
                  color: isSelected ? color : color.withOpacity(0.5),
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  isSelected ? '[ ${item['label']} ]' : (item['label'] as String),
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    color: isSelected ? color : color.withOpacity(0.5),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  String _getWeekday(int weekday) {
    // This could also be localized if needed, but for now simple English abbreviations are likely fine or can be mapped.
    // Ideally use DateFormat from intl package.
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}
