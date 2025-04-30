import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager_app/blocs/task_event.dart';
import 'package:task_manager_app/blocs/task_state.dart';
import 'package:task_manager_app/commands/task_command.dart';
import 'package:task_manager_app/models/task.dart';
import 'package:task_manager_app/repositories/task_repository.dart';
import 'package:task_manager_app/services/notification_service.dart';
import 'package:task_manager_app/di/service_locator.dart';

/// Manages the business logic for task-related operations.
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _taskRepository;
  final NotificationService _notificationService;
  final List<TaskCommand> _commandHistory = [];
  int _currentCommandIndex = -1;

  TaskBloc({required TaskRepository taskRepository})
      : _taskRepository = taskRepository,
        _notificationService = getIt<NotificationService>(),
        super(const TaskState(tasks: [])) {
    on<AddTaskEvent>((event, emit) async {
      final task = Task(
        id: DateTime.now().toString(),
        title: event.title,
        category: event.category,
        dueDate: event.dueDate,
      );
      final command = AddTaskCommand(task);
      await _executeCommand(command, emit);
      if (task.dueDate != null) {
        await _scheduleNotification(task);
      }
    }, transformer: null);

    on<ToggleTaskCompletionEvent>((event, emit) async {
      if (event.index >= 0 && event.index < state.tasks.length) {
        final command = ToggleCompletionCommand(event.index);
        await _executeCommand(command, emit);
      }
    }, transformer: null);

    on<LoadTasksEvent>((event, emit) async {
      emit(const TaskState(
        tasks: [],
        isLoading: true,
      ));
      try {
        final tasks = await _taskRepository.loadTasks();
        final categories = await _taskRepository.getCategories();
        emit(TaskState(
          tasks: tasks,
          categories: categories,
        ));
        // Reschedule notifications for existing tasks with due dates
        for (final task in tasks) {
          if (task.dueDate != null && task.dueDate!.isAfter(DateTime.now())) {
            await _scheduleNotification(task);
          }
        }
      } catch (e) {
        emit(TaskState(
          tasks: [],
          error: 'Failed to load tasks: $e',
        ));
      }
    });

    on<DeleteTaskEvent>((event, emit) async {
      if (event.index >= 0 && event.index < state.tasks.length) {
        final task = state.tasks[event.index];
        final command = DeleteTaskCommand(task, event.index);
        await _executeCommand(command, emit);
        await _notificationService.cancelNotification(task.id.hashCode);
      }
    }, transformer: null);

    on<EditTaskEvent>((event, emit) async {
      if (event.index >= 0 && event.index < state.tasks.length) {
        final oldTask = state.tasks[event.index];
        final command = EditTaskCommand(
          event.index,
          event.newTitle,
          event.newCategory,
          event.newDueDate,
        );
        await _executeCommand(command, emit);
        await _notificationService.cancelNotification(oldTask.id.hashCode);
        final updatedTask = state.tasks[event.index];
        if (updatedTask.dueDate != null) {
          await _scheduleNotification(updatedTask);
        }
      }
    }, transformer: null);

    on<UndoEvent>((event, emit) async {
      if (_currentCommandIndex >= 0) {
        final command = _commandHistory[_currentCommandIndex];
        final updatedTasks = List<Task>.from(state.tasks);
        command.undo(updatedTasks);
        _currentCommandIndex--;
        emit(TaskState(
          tasks: updatedTasks,
          isLoading: true,
          canUndo: _currentCommandIndex >= 0,
          canRedo: _currentCommandIndex < _commandHistory.length - 1,
          filterCategory: state.filterCategory,
          categories: state.categories,
        ));
        try {
          await _taskRepository.saveTasks(updatedTasks);
          final categories = await _taskRepository.getCategories();
          emit(TaskState(
            tasks: updatedTasks,
            canUndo: _currentCommandIndex >= 0,
            canRedo: _currentCommandIndex < _commandHistory.length - 1,
            filterCategory: state.filterCategory,
            categories: categories,
          ));
          for (final task in updatedTasks) {
            if (task.dueDate != null && task.dueDate!.isAfter(DateTime.now())) {
              await _scheduleNotification(task);
            } else {
              await _notificationService.cancelNotification(task.id.hashCode);
            }
          }
        } catch (e) {
          emit(TaskState(
            tasks: updatedTasks,
            error: 'Failed to undo action: $e',
            canUndo: _currentCommandIndex >= 0,
            canRedo: _currentCommandIndex < _commandHistory.length - 1,
            filterCategory: state.filterCategory,
            categories: state.categories,
          ));
        }
      }
    }, transformer: null);

    on<RedoEvent>((event, emit) async {
      if (_currentCommandIndex < _commandHistory.length - 1) {
        _currentCommandIndex++;
        final command = _commandHistory[_currentCommandIndex];
        final updatedTasks = List<Task>.from(state.tasks);
        command.redo(updatedTasks);
        emit(TaskState(
          tasks: updatedTasks,
          isLoading: true,
          canUndo: _currentCommandIndex >= 0,
          canRedo: _currentCommandIndex < _commandHistory.length - 1,
          filterCategory: state.filterCategory,
          categories: state.categories,
        ));
        try {
          await _taskRepository.saveTasks(updatedTasks);
          final categories = await _taskRepository.getCategories();
          emit(TaskState(
            tasks: updatedTasks,
            canUndo: _currentCommandIndex >= 0,
            canRedo: _currentCommandIndex < _commandHistory.length - 1,
            filterCategory: state.filterCategory,
            categories: categories,
          ));
          for (final task in updatedTasks) {
            if (task.dueDate != null && task.dueDate!.isAfter(DateTime.now())) {
              await _scheduleNotification(task);
            } else {
              await _notificationService.cancelNotification(task.id.hashCode);
            }
          }
        } catch (e) {
          emit(TaskState(
            tasks: updatedTasks,
            error: 'Failed to redo action: $e',
            canUndo: _currentCommandIndex >= 0,
            canRedo: _currentCommandIndex < _commandHistory.length - 1,
            filterCategory: state.filterCategory,
            categories: state.categories,
          ));
        }
      }
    }, transformer: null);

    on<SetCategoryFilterEvent>((event, emit) async {
      emit(TaskState(
        tasks: state.tasks,
        canUndo: state.canUndo,
        canRedo: state.canRedo,
        filterCategory: event.category,
        categories: state.categories,
      ));
    }, transformer: null);

    on<LoadCategoriesEvent>((event, emit) async {
      try {
        final categories = await _taskRepository.getCategories();
        emit(TaskState(
          tasks: state.tasks,
          canUndo: state.canUndo,
          canRedo: state.canRedo,
          filterCategory: state.filterCategory,
          categories: categories,
        ));
      } catch (e) {
        emit(TaskState(
          tasks: state.tasks,
          error: 'Failed to load categories: $e',
          canUndo: state.canUndo,
          canRedo: state.canRedo,
          filterCategory: state.filterCategory,
          categories: state.categories,
        ));
      }
    }, transformer: null);

    _initialize();
  }

  Future<void> _initialize() async {
    add(LoadTasksEvent());
    add(LoadCategoriesEvent());
  }

  Future<void> _executeCommand(
      TaskCommand command, Emitter<TaskState> emit) async {
    if (_currentCommandIndex < _commandHistory.length - 1) {
      _commandHistory.removeRange(
          _currentCommandIndex + 1, _commandHistory.length);
    }

    final updatedTasks = List<Task>.from(state.tasks);
    command.execute(updatedTasks);
    _commandHistory.add(command);
    _currentCommandIndex++;

    emit(TaskState(
      tasks: updatedTasks,
      isLoading: true,
      canUndo: _currentCommandIndex >= 0,
      canRedo: _currentCommandIndex < _commandHistory.length - 1,
      filterCategory: state.filterCategory,
      categories: state.categories,
    ));

    try {
      await _taskRepository.saveTasks(updatedTasks);
      final categories = await _taskRepository.getCategories();
      emit(TaskState(
        tasks: updatedTasks,
        canUndo: _currentCommandIndex >= 0,
        canRedo: _currentCommandIndex < _commandHistory.length - 1,
        filterCategory: state.filterCategory,
        categories: categories,
      ));
    } catch (e) {
      emit(TaskState(
        tasks: updatedTasks,
        error: 'Failed to save tasks: $e',
        canUndo: _currentCommandIndex >= 0,
        canRedo: _currentCommandIndex < _commandHistory.length - 1,
        filterCategory: state.filterCategory,
        categories: state.categories,
      ));
    }
  }

  Future<void> _scheduleNotification(Task task) async {
    if (task.dueDate == null || task.dueDate!.isBefore(DateTime.now())) return;

    await _notificationService.scheduleNotification(
      id: task.id.hashCode,
      title: 'Task Due: ${task.title}',
      body: 'Your task "${task.title}" is due soon!',
      scheduledDate: task.dueDate!,
    );
  }
}
