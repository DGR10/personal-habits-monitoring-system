import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:habit_tracker/models/habit_frequency.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';

class AddHabitScreen extends StatefulWidget {
  final Habit? habit;

  const AddHabitScreen({super.key, this.habit});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  
  late int _selectedIconCode;
  late int _selectedColorValue;

  // Frequency State
  late FrequencyType _frequencyType;
  late int _periodValue;
  late List<int> _weekDays;
  late int _targetCount;

  bool _isIconListExpanded = false;

  final List<IconData> _defaultIcons = [
    Icons.book,
    Icons.directions_run,
    Icons.water_drop,
    Icons.code,
  ];

  final List<IconData> _extendedIcons = [
    Icons.music_note,
    Icons.brush,
    Icons.bed,
    Icons.restaurant,
    Icons.work,
    Icons.flight,
    Icons.shopping_cart,
    Icons.pets,
    Icons.fitness_center,
    Icons.local_florist,
    Icons.local_cafe,
    Icons.local_pizza,
    Icons.movie,
    Icons.gamepad,
    Icons.camera_alt,
    Icons.phone_android,
    Icons.computer,
    Icons.directions_car,
    Icons.directions_bike,
    Icons.home,
    Icons.star,
    Icons.favorite,
    Icons.lightbulb,
    Icons.access_time,
  ];

  final List<Color> _colors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.habit?.title ?? '');
    _descriptionController = TextEditingController(text: widget.habit?.description ?? '');
    _selectedIconCode = widget.habit?.iconCode ?? Icons.book.codePoint;
    _selectedColorValue = widget.habit?.colorValue ?? Colors.blue.value;
    
    // Initialize Frequency State
    final freq = widget.habit?.frequency ?? const HabitFrequency(type: FrequencyType.daily);
    _frequencyType = freq.type;
    _periodValue = freq.periodValue;
    _weekDays = List.from(freq.weekDays ?? []);
    _targetCount = freq.targetCount ?? 1;
    
    // If the selected icon is not in the default list, expand the list automatically
    if (!_defaultIcons.any((icon) => icon.codePoint == _selectedIconCode)) {
      _isIconListExpanded = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _deleteHabit(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteHabitTitle),
        content: Text(l10n.deleteHabitConfirmation(widget.habit!.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              if (widget.habit != null) {
                Provider.of<HabitProvider>(context, listen: false)
                    .deleteHabit(widget.habit!.id);
              }
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close screen
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _saveHabit() {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = Provider.of<HabitProvider>(context, listen: false);
      
      final frequency = HabitFrequency(
        type: _frequencyType,
        periodValue: _periodValue,
        weekDays: _frequencyType == FrequencyType.weekly ? _weekDays : null,
        targetCount: _frequencyType == FrequencyType.interval ? _targetCount : null,
      );

      if (widget.habit != null) {
        provider.updateHabit(
          widget.habit!.id,
          _titleController.text,
          _descriptionController.text,
          _selectedIconCode,
          _selectedColorValue,
          frequency,
        );
      } else {
        provider.addHabit(
          _titleController.text,
          _descriptionController.text,
          _selectedIconCode,
          _selectedColorValue,
          frequency,
        );
      }
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final iconsToShow = _isIconListExpanded 
        ? [..._defaultIcons, ..._extendedIcons] 
        : _defaultIcons;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit != null ? l10n.editHabit : l10n.addNewHabit),
        actions: [
          if (widget.habit != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteHabit(l10n),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n.habitTitle,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.habitTitleError;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.descriptionOptional,
                  border: const OutlineInputBorder(),
                ),
              ),
              
              const SizedBox(height: 24),
              Text(l10n.frequency, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _buildFrequencySelector(l10n),
              
              const SizedBox(height: 24),
              Text(l10n.selectIcon, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  ...iconsToShow.map((icon) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIconCode = icon.codePoint;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _selectedIconCode == icon.codePoint
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, size: 28),
                      ),
                    );
                  }),
                  if (!_isIconListExpanded)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isIconListExpanded = true;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.grid_view, size: 28),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isIconListExpanded = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.expand_less, size: 28),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Text(l10n.selectColor, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: _colors.map((color) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColorValue = color.value;
                      });
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: _selectedColorValue == color.value
                            ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 3)
                            : null,
                      ),
                      child: _selectedColorValue == color.value
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saveHabit,
                  child: Text(widget.habit != null ? l10n.updateHabit : l10n.saveHabit),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrequencySelector(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<FrequencyType>(
          value: _frequencyType,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: l10n.frequencyType,
          ),
          items: [
            DropdownMenuItem(value: FrequencyType.daily, child: Text(l10n.dailyEveryXDays)),
            DropdownMenuItem(value: FrequencyType.weekly, child: Text(l10n.weeklySpecificDays)),
            DropdownMenuItem(value: FrequencyType.interval, child: Text(l10n.intervalXTimesInYDays)),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _frequencyType = value;
              });
            }
          },
        ),
        const SizedBox(height: 16),
        if (_frequencyType == FrequencyType.daily) ...[
          Row(
            children: [
              Text('${l10n.every} '),
              SizedBox(
                width: 60,
                child: TextFormField(
                  initialValue: _periodValue.toString(),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  onChanged: (val) {
                    setState(() {
                      _periodValue = int.tryParse(val) ?? 1;
                    });
                  },
                ),
              ),
              Text(' ${l10n.days}'),
            ],
          ),
        ] else if (_frequencyType == FrequencyType.weekly) ...[
          Text(l10n.selectDays),
          Wrap(
            spacing: 8,
            children: List.generate(7, (index) {
              final day = index + 1;
              final isSelected = _weekDays.contains(day);
              // Use DateFormat for short weekdays
               // Note: DateFormat.E() starts with Mon? No, standard is Mon=1?
               // Actually, let's just use a simple list or DateFormat if we can get a date.
               // A trick is to use a known Monday.
              final date = DateTime(2024, 1, 1).add(Duration(days: index)); // Jan 1 2024 is a Monday
              final dayName = DateFormat.E(Localizations.localeOf(context).toString()).format(date);
              
              return FilterChip(
                label: Text(dayName),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _weekDays.add(day);
                    } else {
                      _weekDays.remove(day);
                    }
                  });
                },
              );
            }),
          ),
        ] else if (_frequencyType == FrequencyType.interval) ...[
          Row(
            children: [
              SizedBox(
                width: 60,
                child: TextFormField(
                  initialValue: _targetCount.toString(),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  onChanged: (val) {
                    setState(() {
                      _targetCount = int.tryParse(val) ?? 1;
                    });
                  },
                ),
              ),
              Text(' ${l10n.timesIn} '),
              SizedBox(
                width: 60,
                child: TextFormField(
                  initialValue: _periodValue.toString(),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  onChanged: (val) {
                    setState(() {
                      _periodValue = int.tryParse(val) ?? 1;
                    });
                  },
                ),
              ),
              Text(' ${l10n.days}'),
            ],
          ),
        ],
      ],
    );
  }
}
