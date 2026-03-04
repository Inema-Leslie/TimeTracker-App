class Task {
  String id;
  String projectId;
  String name;
  DateTime createdAt;

  Task({
    required this.id,
    required this.projectId,
    required this.name,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      projectId: json['projectId'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}