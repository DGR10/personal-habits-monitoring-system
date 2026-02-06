class Goal {
  final String id;
  final String title;
  final DateTime deadline;
  final List<String> linkedHabitIds;
  final double progress; // 0.0 to 1.0

  Goal({
    required this.id,
    required this.title,
    required this.deadline,
    required this.linkedHabitIds,
    this.progress = 0.0,
  });

  Goal copyWith({
    String? id,
    String? title,
    DateTime? deadline,
    List<String>? linkedHabitIds,
    double? progress,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      deadline: deadline ?? this.deadline,
      linkedHabitIds: linkedHabitIds ?? this.linkedHabitIds,
      progress: progress ?? this.progress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'deadline': deadline.toIso8601String(),
      'linkedHabitIds': linkedHabitIds,
      'progress': progress,
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      title: json['title'],
      deadline: DateTime.parse(json['deadline']),
      linkedHabitIds: List<String>.from(json['linkedHabitIds']),
      progress: json['progress'],
    );
  }
}
