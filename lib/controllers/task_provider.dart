import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  final List<Task> _tasks = [
    Task(id: '1', title: 'Learn Flutter', isCompleted: false),
    Task(id: '2', title: 'Build App', isCompleted: true),
  ];

  List<Task> get tasks => _tasks;

  void addTask(String title) {
    if (title.isNotEmpty) {
      _tasks.add(Task(
        id: DateTime.now().toString(),
        title: title,
      ));
      notifyListeners();
    }
  }

  void toggleTaskCompletion(int index) {
    _tasks[index] = _tasks[index].toggleCompletion();
    notifyListeners();
  }
}