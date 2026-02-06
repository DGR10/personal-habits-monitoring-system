import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/goal_provider.dart';
import '../providers/habit_provider.dart';
import '../models/goal.dart';
import '../models/habit.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals'),
      ),
      body: Consumer<GoalProvider>(
        builder: (context, provider, child) {
          if (provider.goals.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flag_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No goals set.\nAim high!', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.goals.length,
            itemBuilder: (context, index) {
              final goal = provider.goals[index];
              return _buildGoalCard(context, goal);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGoalDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New Goal'),
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, Goal goal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    goal.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _showEditGoalDialog(context, goal),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Deadline: ${DateFormat.yMMMd().format(goal.deadline)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Progress', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                Text('${(goal.progress * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: goal.progress,
              backgroundColor: Colors.grey[200],
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            if (goal.linkedHabitIds.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 8),
              const Text('Linked Habits:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 30,
                child: Consumer<HabitProvider>(
                  builder: (context, habitProvider, child) {
                    final linkedHabits = habitProvider.habits.where((h) => goal.linkedHabitIds.contains(h.id)).toList();
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: linkedHabits.length,
                      itemBuilder: (context, index) {
                        final habit = linkedHabits[index];
                        return Container(
                           margin: const EdgeInsets.only(right: 8),
                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                           decoration: BoxDecoration(
                             color: Color(habit.colorValue).withOpacity(0.2),
                             borderRadius: BorderRadius.circular(12),
                           ),
                           child: Row(
                             children: [
                               Icon(IconData(habit.iconCode, fontFamily: 'MaterialIcons'), size: 14, color: Color(habit.colorValue)),
                               const SizedBox(width: 4),
                               Text(habit.title, style: TextStyle(fontSize: 10, color: Color(habit.colorValue))),
                             ],
                           ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    final titleController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));
    List<String> selectedHabitIds = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('New Goal'),
            content: SizedBox(
               width: double.maxFinite,
               child: SingleChildScrollView(
                 child: Column(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     TextField(
                       controller: titleController,
                       decoration: const InputDecoration(labelText: 'Goal Title', hintText: 'e.g. Run a Marathon'),
                     ),
                     const SizedBox(height: 16),
                     ListTile(
                       title: const Text('Deadline'),
                       subtitle: Text(DateFormat.yMMMd().format(selectedDate)),
                       trailing: const Icon(Icons.calendar_today),
                       onTap: () async {
                         final picked = await showDatePicker(
                           context: context,
                           initialDate: selectedDate,
                           firstDate: DateTime.now(),
                           lastDate: DateTime(2030),
                         );
                         if (picked != null) setState(() => selectedDate = picked);
                       },
                     ),
                     const SizedBox(height: 16),
                     const Text('Link Habits', style: TextStyle(fontWeight: FontWeight.bold)),
                     const SizedBox(height: 8),
                     Consumer<HabitProvider>(
                       builder: (context, habitProvider, child) {
                         return Wrap(
                           spacing: 8,
                           children: habitProvider.habits.map((habit) {
                             final isSelected = selectedHabitIds.contains(habit.id);
                             return FilterChip(
                               label: Text(habit.title),
                               selected: isSelected,
                               onSelected: (selected) {
                                 setState(() {
                                   if (selected) {
                                     selectedHabitIds.add(habit.id);
                                   } else {
                                     selectedHabitIds.remove(habit.id);
                                   }
                                 });
                               },
                             );
                           }).toList(),
                         );
                       },
                     ),
                   ],
                 ),
               ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              FilledButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty) {
                    context.read<GoalProvider>().addGoal(titleController.text, selectedDate, selectedHabitIds);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Goal created!')));
                  }
                },
                child: const Text('Create'),
              ),
            ],
          );
        },
      ),
    );
  }
  
  void _showEditGoalDialog(BuildContext context, Goal goal) {
    final titleController = TextEditingController(text: goal.title);
    double progress = goal.progress;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Update Goal'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                 TextField(
                   controller: titleController,
                   decoration: const InputDecoration(labelText: 'Title'),
                 ),
                 const SizedBox(height: 24),
                 Text('Progress: ${(progress * 100).toInt()}%'),
                 Slider(
                   value: progress,
                   onChanged: (val) => setState(() => progress = val),
                 ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                   context.read<GoalProvider>().deleteGoal(goal.id);
                   Navigator.pop(context);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
              FilledButton(
                onPressed: () {
                   final updated = goal.copyWith(title: titleController.text, progress: progress);
                   context.read<GoalProvider>().updateGoal(updated);
                   Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}
