class Project {
  String id;
  String name;
  String color;
  DateTime createdAt;

  Project({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
  });

  // Convert Project to JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create Project from JSON
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      color: json['color'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}