import 'package:task_manager_app/models/task.dart';

class TaskState {
  final List<Task> tasks;

  final bool isLoading;

  final String? error;

  final bool canUndo;

  final bool canRedo;

  final String? filterCategory;

  final List<String> categories;

  const TaskState({
    required this.tasks,
    this.isLoading = false,
    this.error,
    this.canUndo = false,
    this.canRedo = false,
    this.filterCategory,
    this.categories = const ['Uncategorized'],
  });

  List<Task> get filteredTasks {
    if (filterCategory == null) return tasks;
    return tasks.where((task) => task.category == filterCategory).toList();
  }
}
