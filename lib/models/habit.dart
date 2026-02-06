import 'habit_frequency.dart';
import 'habit_pause.dart';

class Habit {
  final String id;
  final String title;
  final String description;
  final Set<String> completedDays; // Stores dates as 'YYYY-MM-DD'
  final int iconCode;
  final int colorValue;
  // longestStreak field removed
  final HabitFrequency frequency;
  final DateTime startDate;
  final List<HabitPause> pauseIntervals;

  Habit({
    required this.id,
    required this.title,
    required this.description,
    this.completedDays = const {},
    required this.iconCode,
    required this.colorValue,
    // longestStreak removed from constructor
    HabitFrequency? frequency,
    DateTime? startDate,
    this.pauseIntervals = const [],
  })  : frequency = frequency ?? HabitFrequency.daily(),
        startDate = startDate ?? DateTime.now();

  bool isCompletedOn(DateTime date) {
    final dateString = _formatDate(date);
    return completedDays.contains(dateString);
  }

  bool isPausedOn(DateTime date) {
    for (final pause in pauseIntervals) {
      if (pause.contains(date)) return true;
    }
    return false;
  }

  bool isDueOn(DateTime date) {
    if (isPausedOn(date)) return false;

    // Normalize dates to start of day for calculation
    final checkDate = DateTime(date.year, date.month, date.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);

    if (checkDate.isBefore(start)) return false;

    switch (frequency.type) {
      case FrequencyType.daily:
        // Rolling Window Logic for Daily
        // Check if there is any completion within the last 'periodValue' EFFECTIVE days
        if (frequency.periodValue <= 1) {
           // Simple daily, just check if completed today? No, isDueOn means "Should I do it?"
           // Using rolling logic: If done yesterday, not due today? 
           // If Period=1. Window=1 previous day.
           // If done yesterday. Window [Yesterday]. Found. Not due?
           // WAIT. Daily habit (Period 1) IS due every day.
           // Rolling logic: "Not due if done within last X days".
           // If X=1. Done yesterday. Not due today? That means "Every 2 days".
           // Period=1 means "Every 1 day".
           // Gap allowed = 1.
           // If last done Yesterday. Gap to Today is 1. <= 1.
           // BUT "Is Due" means "Do I need to do it to maintain streak?".
           // If I don't do it Today, tomorrow gap is 2 > 1.
           // So yes, Due Today.
           // Rolling Logic: Is Due if "Gap from last completion to Today" >= Period?
           // If Last=Yesterday. Today-Last = 1. Period=1. 1 >= 1. DUE. Correct.
           // If Period=3. Last=Yesterday. Gap=1. 1 < 3. NOT DUE. Correct.
           
           // So logic is: Find last completion. Current Gap = checkDate - last.
           // If EffectiveGap >= Period, then Due.
           
           // Search backwards for last completion
           DateTime loop = checkDate.subtract(const Duration(days: 1));
           int effectiveDays = 0;
           while (loop.isAfter(start.subtract(const Duration(days: 1)))) {
              if (!isPausedOn(loop)) {
                  effectiveDays++;
                  if (isCompletedOn(loop)) {
                      // Found last completion
                      return effectiveDays >= frequency.periodValue;
                  }
                  // Optimization: If we went back enough days without finding completion, it IS due.
                  if (effectiveDays >= frequency.periodValue) return true;
              }
              loop = loop.subtract(const Duration(days: 1));
           }
           return true; // Never completed or far back
        } else {
           // Replicate logic above for Period > 1
           DateTime loop = checkDate.subtract(const Duration(days: 1));
           int effectiveDays = 0;
           int maxLookback = frequency.periodValue * 10 + 365; // Safety break
           int steps = 0;
           
           while (loop.isAfter(start.subtract(const Duration(days: 1))) && steps < maxLookback) {
              if (!isPausedOn(loop)) {
                  effectiveDays++;
                  if (isCompletedOn(loop)) {
                      return effectiveDays >= frequency.periodValue;
                  }
                  if (effectiveDays >= frequency.periodValue) return true;
              }
              loop = loop.subtract(const Duration(days: 1));
              steps++;
           }
           return true;
        }
      
      case FrequencyType.weekly:
        if (frequency.weekDays == null || frequency.weekDays!.isEmpty) return false;
        return frequency.weekDays!.contains(checkDate.weekday);
      
      case FrequencyType.interval:
        final diff = checkDate.difference(start).inDays;
        final cycleIndex = diff ~/ frequency.periodValue;
        final cycleStart = start.add(Duration(days: cycleIndex * frequency.periodValue));
        
        int completions = 0;
        for (int i = 0; i < frequency.periodValue; i++) {
          final day = cycleStart.add(Duration(days: i));
          if (isCompletedOn(day)) completions++;
        }
        return completions < (frequency.targetCount ?? 1);
    }
  }

  int get streak {
    if (frequency.type == FrequencyType.daily) {
      return _calculateRollingStreak();
    }
    return _calculateLegacyStreak();
  }
  
  int _calculateRollingStreak() {
    // 1. Get Sorted Dates
    final sortedDates = completedDays.map((str) => DateTime.parse(str)).toList()
      ..sort((a, b) => a.compareTo(b));
      
    if (sortedDates.isEmpty) return 0;
    
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final lastCompletion = sortedDates.last;
    
    // Check if streak is currently active (head check)
    int gapToNow = _calculateEffectiveGap(lastCompletion, todayNormalized);
    
    // If gap is greater than period, streak is broken.
    // UNLESS today is the due day (Gap == Period).
    // If Gap == Period, we are Due today. Streak is holding on by a thread (previous completions count).
    // If Gap > Period, broken.
    
    if (gapToNow > frequency.periodValue) {
       return 0; 
    }
    
    int currentStreak = 1;
    
    // Count backwards
    for (int i = sortedDates.length - 1; i > 0; i--) {
       final current = sortedDates[i];
       final prev = sortedDates[i-1];
       final gap = _calculateEffectiveGap(prev, current);
       
       if (gap <= frequency.periodValue) {
          currentStreak++;
       } else {
          break; 
       }
    }
    return currentStreak;
  }
  
  int _calculateEffectiveGap(DateTime start, DateTime end) {
      // Returns number of NON-PAUSED days between start and end.
      // E.g. Start Day 0. End Day 2.
      // Loop Day 1. If active, count 1.
      // Gap = 1 (between).
      // Wait, my logic used "distance".
      // Day 0 to Day 2 is difference 2.
      // If Day 1 is paused? Effective diff should be 1.
      
      int days = 0;
      DateTime loop = start.add(const Duration(days: 1));
      while (loop.isBefore(end) || loop.isAtSameMomentAs(end)) {
          if (!isPausedOn(loop)) {
             days++;
          }
          loop = loop.add(const Duration(days: 1));
      }
      return days;
  }

  int _calculateLegacyStreak() {
    int currentStreak = 0;
    DateTime loopDate = DateTime.now();
    
    while ((!isDueOn(loopDate) || isPausedOn(loopDate)) && loopDate.isAfter(startDate)) {
       loopDate = loopDate.subtract(const Duration(days: 1));
    }

    if (!isCompletedOn(loopDate)) {
       if (loopDate.year == DateTime.now().year && 
           loopDate.month == DateTime.now().month && 
           loopDate.day == DateTime.now().day) {
         loopDate = loopDate.subtract(const Duration(days: 1));
         while ((!isDueOn(loopDate) || isPausedOn(loopDate)) && loopDate.isAfter(startDate)) {
            loopDate = loopDate.subtract(const Duration(days: 1));
         }
       } else {
         return 0;
       }
    }
    
    while (loopDate.isAfter(startDate.subtract(const Duration(days: 1)))) {
      if (isPausedOn(loopDate)) {
        loopDate = loopDate.subtract(const Duration(days: 1));
        continue;
      }
      if (isDueOn(loopDate)) {
        if (isCompletedOn(loopDate)) {
          currentStreak++;
        } else {
          break; 
        }
      }
      loopDate = loopDate.subtract(const Duration(days: 1));
    }
    return currentStreak;
  }

  // Calculated property for longestStreak
  int get longestStreak {
    final streaks = _allStreaks;
    if (streaks.isEmpty) return 0;
    return streaks.reduce((a, b) => a > b ? a : b);
  }

  Habit copyWith({
    String? id,
    String? title,
    String? description,
    Set<String>? completedDays,
    int? iconCode,
    int? colorValue,
    // longestStreak removed
    HabitFrequency? frequency,
    DateTime? startDate,
    List<HabitPause>? pauseIntervals,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completedDays: completedDays ?? this.completedDays,
      iconCode: iconCode ?? this.iconCode,
      colorValue: colorValue ?? this.colorValue,
      // longestStreak removed
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      pauseIntervals: pauseIntervals ?? this.pauseIntervals,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completedDays': completedDays.toList(),
      'iconCode': iconCode,
      'colorValue': colorValue,
      // longestStreak removed
      'frequency': frequency.toJson(),
      'startDate': startDate.toIso8601String(),
      'pauseIntervals': pauseIntervals.map((e) => e.toJson()).toList(),
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      completedDays: (json['completedDays'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toSet() ??
          {},
      iconCode: json['iconCode'] ?? 0xe198,
      colorValue: json['colorValue'] ?? 0xFF2196F3,
      // longestStreak removed
      frequency: json['frequency'] != null 
          ? HabitFrequency.fromJson(json['frequency']) 
          : const HabitFrequency(type: FrequencyType.daily),
      startDate: json['startDate'] != null 
          ? DateTime.parse(json['startDate']) 
          : DateTime.now(),
      pauseIntervals: (json['pauseIntervals'] as List<dynamic>?)
          ?.map((e) => HabitPause.fromJson(e))
          .toList() ?? [],
    );
  }

  // Advanced Statistics

  List<int> get _allStreaks {
    List<int> streaks = [];
    int currentCounter = 0;
    // Normalize start date to midnight
    DateTime loopDate = DateTime(startDate.year, startDate.month, startDate.day);
    final today = DateTime.now();
    final end = DateTime(today.year, today.month, today.day);

    while (loopDate.isBefore(end) || loopDate.isAtSameMomentAs(end)) {
      if (isPausedOn(loopDate)) {
        loopDate = loopDate.add(const Duration(days: 1));
        continue;
      }

      if (isDueOn(loopDate)) {
        if (isCompletedOn(loopDate)) {
          currentCounter++;
        } else {
          if (currentCounter > 0) {
            streaks.add(currentCounter);
            currentCounter = 0;
          }
        }
      }
      loopDate = loopDate.add(const Duration(days: 1));
    }
    if (currentCounter > 0) {
      streaks.add(currentCounter);
    }
    return streaks;
  }

  double get medianStreak {
    final streaks = _allStreaks;
    if (streaks.isEmpty) return 0.0;
    
    streaks.sort();
    final middle = streaks.length ~/ 2;
    if (streaks.length % 2 == 1) {
      return streaks[middle].toDouble();
    } else {
      return (streaks[middle - 1] + streaks[middle]) / 2.0;
    }
  }

  double get churnRate {
    // Average days between streaks (gaps)
    List<int> gaps = [];
    int currentGap = 0;
    bool inGap = false;
    bool hasStarted = false; 
    
    // Normalize start date to midnight
    DateTime loopDate = DateTime(startDate.year, startDate.month, startDate.day);
    final today = DateTime.now();
    final end = DateTime(today.year, today.month, today.day);

    while (loopDate.isBefore(end) || loopDate.isAtSameMomentAs(end)) {
      if (isPausedOn(loopDate)) {
        loopDate = loopDate.add(const Duration(days: 1));
        continue;
      }

      if (isDueOn(loopDate)) {
        if (isCompletedOn(loopDate)) {
          if (inGap) {
            gaps.add(currentGap);
            currentGap = 0;
            inGap = false;
          }
          hasStarted = true;
        } else {
          if (hasStarted) {
             inGap = true;
             currentGap++;
          }
        }
      }
      loopDate = loopDate.add(const Duration(days: 1));
    }
    if (inGap) {
      gaps.add(currentGap);
    }

    if (gaps.isEmpty) return 0.0;
    return gaps.reduce((a, b) => a + b) / gaps.length;
  }

  double getCompletionRateForMonth(DateTime month) {
    int dueCount = 0;
    int completedCount = 0;
    
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);
    
    // Adjust start if habit started mid-month
    DateTime loopDate = startOfMonth.isBefore(startDate) ? startDate : startOfMonth;
    // Normalize loopDate to midnight
    loopDate = DateTime(loopDate.year, loopDate.month, loopDate.day);
    
    final endLoop = endOfMonth.isAfter(DateTime.now()) ? DateTime.now() : endOfMonth;
    // Normalize endLoop to midnight
    final endLoopNormalized = DateTime(endLoop.year, endLoop.month, endLoop.day);

    if (loopDate.isAfter(endLoopNormalized)) return 0.0;

    while (loopDate.isBefore(endLoopNormalized) || loopDate.isAtSameMomentAs(endLoopNormalized)) {
      if (isPausedOn(loopDate)) {
        loopDate = loopDate.add(const Duration(days: 1));
        continue;
      }

      if (isDueOn(loopDate)) {
        dueCount++;
        if (isCompletedOn(loopDate)) {
          completedCount++;
        }
      }
      loopDate = loopDate.add(const Duration(days: 1));
    }

    if (dueCount == 0) return 0.0;
    return completedCount / dueCount;
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
