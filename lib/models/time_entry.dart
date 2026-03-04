class TimeEntry {
  String id;
  String projectId;
  String taskId;
  int totalMinutes;
  DateTime date;
  String notes;
  DateTime createdAt;

  TimeEntry({
    required this.id,
    required this.projectId,
    required this.taskId,
    required this.totalMinutes,
    required this.date,
    required this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'taskId': taskId,
      'totalMinutes': totalMinutes,
      'date': date.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TimeEntry.fromJson(Map<String, dynamic> json) {
    return TimeEntry(
      id: json['id'],
      projectId: json['projectId'],
      taskId: json['taskId'],
      totalMinutes: json['totalMinutes'],
      date: DateTime.parse(json['date']),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}