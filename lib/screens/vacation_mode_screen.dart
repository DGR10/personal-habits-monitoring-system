import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../models/habit.dart';

class VacationModeScreen extends StatefulWidget {
  const VacationModeScreen({super.key});

  @override
  State<VacationModeScreen> createState() => _VacationModeScreenState();
}

class _VacationModeScreenState extends State<VacationModeScreen> {
  final Set<String> _selectedHabitIds = {};
  DateTimeRange? _selectedDateRange;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HabitProvider>(context);
    final habits = provider.habits;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vacation Mode'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Pause Period',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _pickDateRange,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDateRange == null
                                  ? 'Select dates'
                                  : '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}',
                            ),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                final isPaused = habit.isPausedOn(DateTime.now());
                
                return CheckboxListTile(
                  title: Text(habit.title),
                  subtitle: isPaused 
                      ? const Text('Currently Paused', style: TextStyle(color: Colors.orange)) 
                      : null,
                  value: _selectedHabitIds.contains(habit.id),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedHabitIds.add(habit.id);
                      } else {
                        _selectedHabitIds.remove(habit.id);
                      }
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _selectedDateRange != null && _selectedHabitIds.isNotEmpty
                    ? _saveVacationMode
                    : null,
                child: const Text('Apply Vacation Mode'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final DateTime now = DateTime.now();
    final DateTime? start = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Select Start Date',
    );

    if (start != null) {
      if (!mounted) return;
      final DateTime? end = await showDatePicker(
        context: context,
        initialDate: start.add(const Duration(days: 1)),
        firstDate: start,
        lastDate: now.add(const Duration(days: 365)),
        helpText: 'Select End Date',
      );

      if (end != null) {
        setState(() {
          _selectedDateRange = DateTimeRange(start: start, end: end);
        });
      }
    }
  }

  void _saveVacationMode() {
    if (_selectedDateRange == null) return;

    final provider = Provider.of<HabitProvider>(context, listen: false);
    for (final id in _selectedHabitIds) {
      provider.pauseHabit(
        id,
        _selectedDateRange!.start,
        _selectedDateRange!.end,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Vacation mode applied to ${_selectedHabitIds.length} habits')),
    );
    Navigator.pop(context);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
