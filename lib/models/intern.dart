class Intern {
  final String id;
  final String name;
  final String email;
  final String department;
  final String joinDate; // You can use DateTime later, but String is simpler for now
  final double progress; // 0.0 to 1.0 (percentage of tasks completed)

  Intern({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.joinDate,
    this.progress = 0.0,
  });

  // Convert from JSON (for Firestore)
  factory Intern.fromJson(Map<String, dynamic> json) {
    return Intern(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      department: json['department'] ?? '',
      joinDate: json['joinDate'] ?? '',
      progress: (json['progress'] ?? 0.0).toDouble(),
    );
  }

  // Convert to JSON (for Firestore)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'department': department,
      'joinDate': joinDate,
      'progress': progress,
    };
  }
}
