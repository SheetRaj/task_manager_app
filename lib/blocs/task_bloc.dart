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
        super(TaskState([])) {
    // Register event handlers
    on<AddTaskEvent>(onAddTask);
    on<ToggleTaskCompletionEvent>(onToggleTaskCompletion);
    on<LoadTasksEvent>(onLoadTasks);

    _initialize();
  }

  Future<void> _initialize() async {
    add(LoadTasksEvent());
  }

  @override
  void onEvent(TaskEvent event) {
    super.onEvent(event);
    // Save tasks whenever an event is processed and the state changes
    if (event is AddTaskEvent || event is ToggleTaskCompletionEvent) {
      _saveTasks();
    }
  }

  Future<void> _saveTasks() async {
    await _storageService.saveTasks(state.tasks);
  }

  /// Handles the [LoadTasksEvent] by loading tasks from storage.
  void onLoadTasks(LoadTasksEvent event, Emitter<TaskState> emit) async {
    final tasks = await _storageService.loadTasks();
    emit(TaskState(tasks));
  }

  /// Handles the [AddTaskEvent] by adding a new task to the list.
  void onAddTask(AddTaskEvent event, Emitter<TaskState> emit) async {
    if (event.title.isNotEmpty) {
      final updatedTasks = List<Task>.from(state.tasks)
        ..add(Task(
          id: DateTime.now().toString(),
          title: event.title,
        ));
      emit(TaskState(updatedTasks));
      await _saveTasks();
    }
  }

  /// Handles the [ToggleTaskCompletionEvent] by toggling the completion status of a task.
  void onToggleTaskCompletion(
      ToggleTaskCompletionEvent event, Emitter<TaskState> emit) {
    if (event.index >= 0 && event.index < state.tasks.length) {
      final updatedTasks = List<Task>.from(state.tasks);
      updatedTasks[event.index] = updatedTasks[event.index].toggleCompletion();
      emit(TaskState(updatedTasks));
      _saveTasks();
    }
  }
}
