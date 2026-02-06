enum FrequencyType {
  daily,
  weekly,
  interval,
}

class HabitFrequency {
  final FrequencyType type;
  final int periodValue; // For daily: every N days. For interval: in N days.
  final List<int>? weekDays; // For weekly: 1=Mon, 7=Sun
  final int? targetCount; // For interval: X times

  const HabitFrequency({
    required this.type,
    this.periodValue = 1,
    this.weekDays,
    this.targetCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'periodValue': periodValue,
      'weekDays': weekDays,
      'targetCount': targetCount,
    };
  }

  factory HabitFrequency.fromJson(Map<String, dynamic> json) {
    return HabitFrequency(
      type: FrequencyType.values[json['type'] as int],
      periodValue: json['periodValue'] as int? ?? 1,
      weekDays: (json['weekDays'] as List<dynamic>?)?.cast<int>(),
      targetCount: json['targetCount'] as int?,
    );
  }

  // Helper to create default daily
  factory HabitFrequency.daily() => const HabitFrequency(type: FrequencyType.daily, periodValue: 1);
}
