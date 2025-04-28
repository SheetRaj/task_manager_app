abstract class TaskEvent {}

class AddTaskEvent extends TaskEvent {
  final String title;

  AddTaskEvent(this.title);
}

class ToggleTaskCompletionEvent extends TaskEvent {
  final int index;

  ToggleTaskCompletionEvent(this.index);
}

class LoadTasksEvent extends TaskEvent {
  LoadTasksEvent();
}

class DeleteTaskEvent extends TaskEvent {
  final int index;

  DeleteTaskEvent(this.index);
}

class EditTaskEvent extends TaskEvent {
  final int index;
  final String newTitle;

  EditTaskEvent(this.index, this.newTitle);
}

class UndoDeleteTaskEvent extends TaskEvent {
  UndoDeleteTaskEvent();
}

