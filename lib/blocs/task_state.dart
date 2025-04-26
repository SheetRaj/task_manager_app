import 'package:task_manager_app/models/task.dart';

class TaskState {
  final List<Task> tasks;

  final bool isLoading;

  final String? error;

  const TaskState({
    required this.tasks,
    this.isLoading = false,
    this.error,
  });
}
