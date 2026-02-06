import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker/models/habit_frequency.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/providers/habit_provider.dart';

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

  void _deleteHabit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: const Text('Are you sure you want to delete this habit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
    final iconsToShow = _isIconListExpanded 
        ? [..._defaultIcons, ..._extendedIcons] 
        : _defaultIcons;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit != null ? 'Edit Habit' : 'Add New Habit'),
        actions: [
          if (widget.habit != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteHabit,
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
                decoration: const InputDecoration(
                  labelText: 'Habit Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              
              const SizedBox(height: 24),
              Text('Frequency', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _buildFrequencySelector(),
              
              const SizedBox(height: 24),
              Text('Select Icon', style: Theme.of(context).textTheme.titleMedium),
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
              Text('Select Color', style: Theme.of(context).textTheme.titleMedium),
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
                  child: Text(widget.habit != null ? 'Update Habit' : 'Save Habit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrequencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<FrequencyType>(
          value: _frequencyType,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Type',
          ),
          items: const [
            DropdownMenuItem(value: FrequencyType.daily, child: Text('Daily / Every X Days')),
            DropdownMenuItem(value: FrequencyType.weekly, child: Text('Weekly (Specific Days)')),
            DropdownMenuItem(value: FrequencyType.interval, child: Text('Interval (X times in Y days)')),
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
              const Text('Every '),
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
              const Text(' days'),
            ],
          ),
        ] else if (_frequencyType == FrequencyType.weekly) ...[
          const Text('Select Days:'),
          Wrap(
            spacing: 8,
            children: List.generate(7, (index) {
              final day = index + 1;
              final isSelected = _weekDays.contains(day);
              return FilterChip(
                label: Text(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index]),
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
              const Text(' times in '),
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
              const Text(' days'),
            ],
          ),
        ],
      ],
    );
  }
}
