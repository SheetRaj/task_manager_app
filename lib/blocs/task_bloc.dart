import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager_app/blocs/task_event.dart';
import 'package:task_manager_app/blocs/task_state.dart';
import 'package:task_manager_app/models/task.dart';
import 'package:task_manager_app/services/task_storage_service.dart';

/// Manages the business logic for task-related operations.
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskStorageService _storageService;
  Task? _lastDeletedTask;
  int? _lastDeletedIndex;

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

    on<DeleteTaskEvent>((event, emit) async {
      if (event.index >= 0 && event.index < state.tasks.length) {
        final updatedTasks = List<Task>.from(state.tasks);
        _lastDeletedTask = updatedTasks[event.index];
        _lastDeletedIndex = event.index;
        updatedTasks.removeAt(event.index);
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
            error: 'Failed to delete task: $e',
          ));
        }
      }
    }, transformer: null);

    on<EditTaskEvent>((event, emit) async {
      if (event.index >= 0 && event.index < state.tasks.length) {
        final updatedTasks = List<Task>.from(state.tasks);
        final taskToEdit = updatedTasks[event.index];
        updatedTasks[event.index] = Task(
            id: taskToEdit.id,
            title: event.newTitle,
            isCompleted: taskToEdit.isCompleted);
        emit(TaskState(tasks: updatedTasks, isLoading: true));

        try {
          await _storageService.saveTasks(updatedTasks);
          emit(TaskState(tasks: updatedTasks));
        } catch (e) {
          emit(TaskState(
            tasks: updatedTasks,
            error: 'Failed to edit task: $e',
          ));
        }
      }
    });

    on<UndoDeleteTaskEvent>((event, emit) async {
      if (_lastDeletedTask != null && _lastDeletedIndex != null) {
        final updatedTasks = List<Task>.from(state.tasks);
        updatedTasks.insert(_lastDeletedIndex!, _lastDeletedTask!);
        emit(TaskState(
          tasks: updatedTasks,
          isLoading: true,
        ));

        try {
          await _storageService.saveTasks(updatedTasks);
          print('After saving (undo): $updatedTasks');
          emit(TaskState(tasks: updatedTasks));
          _lastDeletedTask = null;
          _lastDeletedIndex = null;
        } catch (e) {
          emit(TaskState(
            tasks: updatedTasks,
            error: 'Failed to undo deletion: $e',
          ));
        }
      }
    }, transformer: null);

    _initialize();
  }

  Future<void> _initialize() async {
    add(LoadTasksEvent());
  }
}
