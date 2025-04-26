import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

class TaskStorageService {
  static const String _tasksKey = 'tasks';

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
    final tasksJson = jsonEncode(
      tasks.map(
        (task) {
          return {
            'id': task.id,
            'title': task.title,
            'isCompleted': task.isCompleted,
          };
        },
      ).toList(),
    );
    await prefs.setString(_tasksKey, tasksJson);
  }
}
