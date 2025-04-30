abstract class TaskEvent {}

class AddTaskEvent extends TaskEvent {
  final String title;

  final String category;

  final DateTime? dueDate;

  AddTaskEvent(this.title, this.category, this.dueDate);
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

  final String newCategory;

  final DateTime? newDueDate;

  EditTaskEvent(this.index, this.newTitle, this.newCategory, this.newDueDate);
}

class UndoEvent extends TaskEvent {
  UndoEvent();
}

class RedoEvent extends TaskEvent {
  RedoEvent();
}

class SetCategoryFilterEvent extends TaskEvent {
  final String? category;

  SetCategoryFilterEvent(this.category);
}

class LoadCategoriesEvent extends TaskEvent {
  LoadCategoriesEvent();
}
