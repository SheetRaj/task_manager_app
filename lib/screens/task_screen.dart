import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final List<Task> _tasks = [
    Task(id: '1', title: 'Learn Flutter', isCompleted: false),
    Task(id: '2', title: 'Build App', isCompleted: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
      ),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return ListTile(
            title: Text(task.title),
            trailing: Checkbox(
              value: task.isCompleted,
              onChanged: (value) {
                // We'll handle this later
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // We'll add a task here later
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}