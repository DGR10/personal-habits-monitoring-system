import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../models/habit.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.insights),
      ),
      body: Consumer<HabitProvider>(
        builder: (context, provider, child) {
          if (provider.habits.isEmpty) {
            return Center(child: Text(l10n.noHabitsToAnalyze));
          }
          
          final habits = provider.habits;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildConsistencyHeatmap(context, habits, l10n),
                const SizedBox(height: 24),
                _buildWeeklyTrendChart(context, habits, l10n),
                const SizedBox(height: 24),
                _buildHighlights(context, habits, l10n),
                const SizedBox(height: 24),
                Text(l10n.habitBreakdown, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildHabitBreakdown(context, habits),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildConsistencyHeatmap(BuildContext context, List<Habit> habits, AppLocalizations l10n) {
    // 3 Months (approx 90 days)
    final now = DateTime.now();
    // Start from 12 weeks ago (84 days) to align weeks better
    final startDate = now.subtract(const Duration(days: 84 - 1)); 
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.consistencyHeatmap, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(l10n.last12Weeks, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            // 7 rows (days), ~12 cols (weeks)
            final itemSize = (constraints.maxWidth - 24) / 12; // 12 weeks roughly
            
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(12, (weekIndex) {
                 return Column(
                   children: List.generate(7, (dayIndex) {
                     final dayOffset = (weekIndex * 7) + dayIndex;
                     final date = startDate.add(Duration(days: dayOffset));
                     
                     if (date.isAfter(now)) {
                        return Container(
                          width: itemSize, 
                          height: itemSize, 
                          margin: const EdgeInsets.all(1),
                        );
                     }

                     double completionRate = _calculateDailyCompletionRate(habits, date);
                     
                     return Container(
                       width: itemSize,
                       height: itemSize,
                       margin: const EdgeInsets.all(1),
                       decoration: BoxDecoration(
                         color: _getHeatmapColor(context, completionRate),
                         borderRadius: BorderRadius.circular(2),
                       ),
                     );
                   }),
                 );
              }),
            );
          },
        ),
      ],
    );
  }

  double _calculateDailyCompletionRate(List<Habit> habits, DateTime date) {
    if (habits.isEmpty) return 0.0;
    
    // In a real app we should check if the habit was created before 'date'
    // For simplicity, we assume all current habits existed. 
    // Ideally: activeHabits = habits.where((h) => h.startDate.isBefore(date)).toList();
    
    int completed = 0;
    for (var habit in habits) {
      if (habit.isCompletedOn(date)) {
        completed++;
      }
    }
    return completed / habits.length;
  }

  Color _getHeatmapColor(BuildContext context, double rate) {
    final baseColor = Theme.of(context).colorScheme.primary;
    if (rate == 0) return Colors.grey.withOpacity(0.1);
    if (rate <= 0.25) return baseColor.withOpacity(0.3);
    if (rate <= 0.50) return baseColor.withOpacity(0.5);
    if (rate <= 0.75) return baseColor.withOpacity(0.7);
    return baseColor;
  }

  Widget _buildWeeklyTrendChart(BuildContext context, List<Habit> habits, AppLocalizations l10n) {
     final now = DateTime.now();
     final weeklyRates = <double>[];
     
     // Last 4 full weeks
     for (int i = 3; i >= 0; i--) {
       double weekSum = 0;
       // A week is 7 days. 
       // Start of this "week bucket"
       // Let's just take last 28 days grouped by 7
       for (int j = 0; j < 7; j++) {
          final date = now.subtract(Duration(days: (i * 7) + j));
          weekSum += _calculateDailyCompletionRate(habits, date);
       }
       weeklyRates.add(weekSum / 7);
     }

     return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.weeklyMomentum, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(
          height: 150,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: weeklyRates.asMap().entries.map((entry) {
              final rate = entry.value;
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('${(rate * 100).toInt()}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Container(
                    width: 30,
                    height: 100 * rate + 10, // Min height 10
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('W${4 - entry.key}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildHighlights(BuildContext context, List<Habit> habits, AppLocalizations l10n) {
    // Best Streak
    habits.sort((a, b) => b.streak.compareTo(a.streak));
    final bestStreakHabit = habits.isNotEmpty ? habits.first : null;

    // Worst Monthly Adherence
    // Recalculate sort for adherence
    // We can't sort the original list again if we want to keep bestStreakHabit valid? 
    // Actually objects are references, so it's fine, but the list order changes.
    // Let's copy or re-sort.
    final adherenceHabits = List<Habit>.from(habits);
    adherenceHabits.sort((a, b) => a.getCompletionRateForMonth(DateTime.now()).compareTo(b.getCompletionRateForMonth(DateTime.now())));
    final focusHabit = adherenceHabits.isNotEmpty ? adherenceHabits.first : null;

    return Row(
      children: [
        Expanded(
          child: _buildHighlightCard(
            context, 
            l10n.onFire, 
            bestStreakHabit?.title ?? '-', 
            '${bestStreakHabit?.streak ?? 0} ${l10n.dayStreak}',
            Colors.orange.shade100,
            Colors.orange.shade800,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildHighlightCard(
            context, 
            l10n.needsFocus, 
            focusHabit?.title ?? '-', 
            '${((focusHabit?.getCompletionRateForMonth(DateTime.now()) ?? 0) * 100).toInt()}% ${l10n.thisMonth}',
            Colors.red.shade100,
            Colors.red.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightCard(BuildContext context, String title, String habitName, String stat, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(habitName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(stat, style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildHabitBreakdown(BuildContext context, List<Habit> habits) {
    // Sort by consistency (monthly rate) descending
    final sortedHabits = List<Habit>.from(habits);
    sortedHabits.sort((a, b) => b.getCompletionRateForMonth(DateTime.now()).compareTo(a.getCompletionRateForMonth(DateTime.now())));

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: sortedHabits.length,
      itemBuilder: (context, index) {
        final habit = sortedHabits[index];
        final rate = habit.getCompletionRateForMonth(DateTime.now());
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            children: [
              Container(
                width: 4, height: 40,
                decoration: BoxDecoration(
                  color: Color(habit.colorValue),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(habit.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: rate,
                      backgroundColor: Colors.grey[200],
                      color: Color(habit.colorValue),
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text('${(rate * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }
}
