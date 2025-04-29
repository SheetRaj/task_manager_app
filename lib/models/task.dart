class Task {
  final String id;
  final String title;
  final bool isCompleted;
  final String category;

  const Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.category = 'Uncategorized',
  });

  Task toggleCompletion() {
    return Task(
      id: id,
      title: title,
      isCompleted: !isCompleted,
      category: category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'category': category,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool,
      category: json['category'] as String? ?? 'Uncategorized',
    );
  }
}
