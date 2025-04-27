import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

class TaskStorageService {
  static const String _tasksKey = 'tasks';
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(milliseconds: 500);

  // Loads tasks from shared preferences.
  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString(_tasksKey);
    if (tasksJson == null) return [];

    final tasksList = jsonDecode(tasksJson) as List<dynamic>;
    return tasksList.map(
      (taskJson) {
        return Task(
          id: taskJson['id'] as String,
          title: taskJson['title'] as String,
          isCompleted: taskJson['isCompleted'] as bool,
        );
      },
    ).toList();
  }

  // Saves the given [tasks] to shared preferences.
  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = jsonEncode(tasks.map(
      (task) {
        return {
          'id': task.id,
          'title': task.title,
          'isCompleted': task.isCompleted,
        };
      },
    ).toList());

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        await prefs.setString(_tasksKey, tasksJson);
        return;
      } catch (e) {
        if (attempt == _maxRetries) {
          throw Exception('Failed to save tasks after $_maxRetries attempts');
        }
        await Future<void>.delayed(_retryDelay);
      }
    }
  }
}
