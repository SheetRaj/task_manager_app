// lib/commands/task_command.dart
import 'package:task_manager_app/models/task.dart';
import 'package:meta/meta.dart';

/// An interface for commands that can be executed, undone, and redone.
abstract class TaskCommand {
  /// Executes the command.
  void execute(List<Task> tasks);

  /// Undoes the command.
  void undo(List<Task> tasks);

  /// Redoes the command by default calls execute.
  @nonVirtual
  void redo(List<Task> tasks) => execute(tasks);
}

/// A command to add a task.
class AddTaskCommand extends TaskCommand {
  final Task task;

  AddTaskCommand(this.task);

  @override
  void execute(List<Task> tasks) {
    tasks.add(task);
  }

  @override
  void undo(List<Task> tasks) {
    tasks.remove(task);
  }
}

/// A command to delete a task.
class DeleteTaskCommand extends TaskCommand {
  final Task task;
  final int index;

  DeleteTaskCommand(this.task, this.index);

  @override
  void execute(List<Task> tasks) {
    tasks.removeAt(index);
  }

  @override
  void undo(List<Task> tasks) {
    tasks.insert(index, task);
  }
}

/// A command to edit a task's title.
class EditTaskCommand extends TaskCommand {
  final int index;
  final String newTitle;
  String? _oldTitle;

  EditTaskCommand(this.index, this.newTitle);

  @override
  void execute(List<Task> tasks) {
    _oldTitle = tasks[index].title;
    tasks[index] = Task(
      id: tasks[index].id,
      title: newTitle,
      isCompleted: tasks[index].isCompleted,
    );
  }

  @override
  void undo(List<Task> tasks) {
    tasks[index] = Task(
      id: tasks[index].id,
      title: _oldTitle!,
      isCompleted: tasks[index].isCompleted,
    );
  }
}

/// A command to toggle a task's completion status.
class ToggleCompletionCommand extends TaskCommand {
  final int index;

  ToggleCompletionCommand(this.index);

  @override
  void execute(List<Task> tasks) {
    tasks[index] = tasks[index].toggleCompletion();
  }

  @override
  void undo(List<Task> tasks) {
    tasks[index] = tasks[index].toggleCompletion();
  }
}
