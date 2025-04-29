import '../models/task.dart';

abstract class TaskRepository {
  Future<List<Task>> loadTasks();
  Future<void> saveTasks(List<Task> tasks);

  Future<List<String>> getCategories();
}
