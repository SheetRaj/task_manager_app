import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final int index;
  final Function(int) onToggle;

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