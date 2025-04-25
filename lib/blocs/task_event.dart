abstract class TaskEvent {}

class AddTaskEvent extends TaskEvent {
  final String title;

  AddTaskEvent(this.title);
}

class ToggleTaskCompletionEvent extends TaskEvent {
  final int index;

  ToggleTaskCompletionEvent(this.index);
}
