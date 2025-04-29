import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_app/repositories/task_repository.dart';

import '../models/task.dart';

class SharedPreferencesTaskRepository implements TaskRepository {
  static const String _tasksKey = 'tasks';
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(milliseconds: 500);
  static const Duration _postSaveDelay = Duration(milliseconds: 100);

  // Loads tasks from shared preferences.
  @override
  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString(_tasksKey);
    print('Loaded tasks JSON: $tasksJson');
    if (tasksJson == null) return [];

    final tasksList = jsonDecode(tasksJson) as List<dynamic>;
    final tasks = tasksList.map((taskJson) {
      return Task(
        id: taskJson['id'] as String,
        title: taskJson['title'] as String,
        isCompleted: taskJson['isCompleted'] as bool,
      );
    }).toList();
    print('Loaded tasks: $tasks');
    return tasks;
  }

  // Saves the given [tasks] to shared preferences.
  @override
  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = jsonEncode(tasks.map((task) {
      return {
        'id': task.id,
        'title': task.title,
        'isCompleted': task.isCompleted,
      };
    }).toList());
    print('Saving tasks JSON: $tasksJson');

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        await prefs.setString(_tasksKey, tasksJson);
        await prefs.reload();
        final savedJson = prefs.getString(_tasksKey);
        print('Verified saved tasks JSON: $savedJson');
        await Future<void>.delayed(_postSaveDelay);
        return;
      } catch (e) {
        if (attempt == _maxRetries) {
          throw Exception(
              'Failed to save tasks after $_maxRetries attempts: $e');
        }
        await Future<void>.delayed(_retryDelay);
      }
    }
  }
}
