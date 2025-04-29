import 'package:task_manager_app/models/task.dart';

class TaskState {
  final List<Task> tasks;

  final bool isLoading;

  final String? error;

  final bool canUndo;

  final bool canRedo;

  const TaskState({
    required this.tasks,
    this.isLoading = false,
    this.error,
    this.canUndo = false,
    this.canRedo = false,
  });
}
