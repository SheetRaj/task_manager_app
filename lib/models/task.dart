class Task {
  final String id;
  final String title;
  final bool isCompleted;
  final String category;
  final DateTime? dueDate;

  const Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.category = 'Uncategorized',
    this.dueDate,
  });

  Task toggleCompletion() {
    return Task(
      id: id,
      title: title,
      isCompleted: !isCompleted,
      category: category,
      dueDate: dueDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'category': category,
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool,
      category: json['category'] as String? ?? 'Uncategorized',
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
    );
  }
}
