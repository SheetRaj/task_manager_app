import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager_app/blocs/task_event.dart';
import 'package:task_manager_app/blocs/task_state.dart';
import 'package:task_manager_app/models/task.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc()
      : super(TaskState([
          Task(id: '1', title: 'Learn Flutter', isCompleted: false),
          Task(id: '2', title: 'Build App', isCompleted: true),
        ])) {
    on<AddTaskEvent>((event, emit) {
      if (event.title.isNotEmpty) {
        final updatedTasks = List<Task>.from(state.tasks)
          ..add(Task(
            id: DateTime.now().toString(),
            title: event.title,
          ));
        emit(TaskState(updatedTasks));
      }
    });

    on<ToggleTaskCompletionEvent>((event, emit) {
      final updatedTasks = List<Task>.from(state.tasks);
      updatedTasks[event.index] = updatedTasks[event.index].toggleCompletion();
      emit(TaskState(updatedTasks));
    });
  }
}
