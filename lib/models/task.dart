class Task {
  final String id;
  final String internId;   // reference to the intern this task belongs to
  final String title;
  final String description;
  final String dueDate;    // you can use DateTime later
  final String status;     // 'pending', 'in-progress', 'completed'

  Task({
    required this.id,
    required this.internId,
    required this.title,
    required this.description,
    required this.dueDate,
    this.status = 'pending',
  });

  // Convert from JSON (Firestore)
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? '',
      internId: json['internId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dueDate: json['dueDate'] ?? '',
      status: json['status'] ?? 'pending',
    );
  }

  // Convert to JSON (Firestore)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'internId': internId,
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'status': status,
    };
  }
}
