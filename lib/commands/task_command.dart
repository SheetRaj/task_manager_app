import 'package:task_manager_app/models/task.dart';

abstract class TaskCommand {
  void execute(List<Task> tasks);
  void undo(List<Task> tasks);
  void redo(List<Task> tasks) => execute(tasks);
}

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

class EditTaskCommand extends TaskCommand {
  final int index;
  final String newTitle;
  final String newCategory;
  final DateTime? newDueDate;
  String? _oldTitle;
  String? _oldCategory;
  DateTime? _oldDueDate;

  EditTaskCommand(this.index, this.newTitle, this.newCategory, this.newDueDate);

  @override
  void execute(List<Task> tasks) {
    _oldTitle = tasks[index].title;
    _oldCategory = tasks[index].category;
    _oldDueDate = tasks[index].dueDate;
    tasks[index] = Task(
      id: tasks[index].id,
      title: newTitle,
      isCompleted: tasks[index].isCompleted,
      category: newCategory,
      dueDate: newDueDate,
    );
  }

  @override
  void undo(List<Task> tasks) {
    tasks[index] = Task(
      id: tasks[index].id,
      title: _oldTitle!,
      isCompleted: tasks[index].isCompleted,
      category: _oldCategory!,
      dueDate: _oldDueDate,
    );
  }
}

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
