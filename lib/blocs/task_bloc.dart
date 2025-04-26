import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager_app/blocs/task_event.dart';
import 'package:task_manager_app/blocs/task_state.dart';
import 'package:task_manager_app/models/task.dart';
import 'package:task_manager_app/services/task_storage_service.dart';

/// Manages the business logic for task-related operations.
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskStorageService _storageService;

  /// Creates a [TaskBloc] with an initial list of tasks loaded from storage.
  TaskBloc({TaskStorageService? storageService})
      : _storageService = storageService ?? TaskStorageService(),
        super(TaskState(tasks: [])) {
    on<AddTaskEvent>((event, emit) async {
      if (event.title.isNotEmpty) {
        final updatedTasks = List<Task>.from(state.tasks)
          ..add(Task(
            id: DateTime.now().toString(),
            title: event.title,
          ));
        emit(TaskState(
          tasks: updatedTasks,
          isLoading: true,
        ));
        try {
          await _storageService.saveTasks(updatedTasks);
          emit(TaskState(tasks: updatedTasks));
        } catch (e) {
          emit(TaskState(
            tasks: updatedTasks,
            error: 'Failed to save tasks: $e',
          ));
        }
      }
    }, transformer: null);

    on<ToggleTaskCompletionEvent>((event, emit) async {
      if (event.index >= 0 && event.index < state.tasks.length) {
        final updatedTasks = List<Task>.from(state.tasks);
        updatedTasks[event.index] =
            updatedTasks[event.index].toggleCompletion();
        emit(TaskState(
          tasks: updatedTasks,
          isLoading: true,
        ));

        try {
          await _storageService.saveTasks(updatedTasks);
          emit(TaskState(tasks: updatedTasks));
        } catch (e) {
          emit(TaskState(
            tasks: updatedTasks,
            error: 'Failed to save tasks: $e',
          ));
        }
      }
    }, transformer: null);
    on<LoadTasksEvent>((event, emit) async {
      emit(const TaskState(
        tasks: [],
        isLoading: true,
      ));

      try {
        final tasks = await _storageService.loadTasks();
        emit(TaskState(tasks: tasks));
      } catch (e) {
        emit(TaskState(
          tasks: [],
          error: 'Failed to load tasks: $e',
        ));
      }
    });

    _initialize();
  }

  Future<void> _initialize() async {
    add(LoadTasksEvent());
  }
}
