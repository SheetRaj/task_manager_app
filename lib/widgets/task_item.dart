import 'package:flutter/material.dart';
import 'package:task_manager_app/models/task.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final int index;
  final void Function(int) onToggle;

  const TaskItem({
    super.key,
    required this.task,
    required this.index,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(task.title),
      trailing: Checkbox(
        value: task.isCompleted,
        onChanged: (value) {
          onToggle(index);
        },
      ),
    );
  }
}