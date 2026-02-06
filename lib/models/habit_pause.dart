class HabitPause {
  final DateTime startDate;
  final DateTime endDate;

  const HabitPause({
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }

  factory HabitPause.fromJson(Map<String, dynamic> json) {
    return HabitPause(
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
    );
  }

  bool contains(DateTime date) {
    final checkDate = DateTime(date.year, date.month, date.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    return (checkDate.isAtSameMomentAs(start) || checkDate.isAfter(start)) &&
           (checkDate.isAtSameMomentAs(end) || checkDate.isBefore(end));
  }
}
