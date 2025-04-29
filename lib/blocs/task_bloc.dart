import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager_app/blocs/task_event.dart';
import 'package:task_manager_app/blocs/task_state.dart';
import 'package:task_manager_app/commands/task_command.dart';
import 'package:task_manager_app/models/task.dart';
import 'package:task_manager_app/repositories/task_repository.dart';

/// Manages the business logic for task-related operations.
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _taskRepository;
  final List<TaskCommand> _commandHistory = [];
  int _currentCommandIndex = -1;

  TaskBloc({required TaskRepository taskRepository})
      : _taskRepository = taskRepository,
        super(const TaskState(tasks: [])) {
    on<AddTaskEvent>((event, emit) async {
      final task = Task(
        id: DateTime.now().toString(),
        title: event.title,
      );
      final command = AddTaskCommand(task);
      await _executeCommand(command, emit);
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
        final task = state.tasks[event.index];
        final command = DeleteTaskCommand(task, event.index);
        await _executeCommand(command, emit);
      }
    }, transformer: null);

    on<EditTaskEvent>((event, emit) async {
      if (event.index >= 0 && event.index < state.tasks.length) {
        final command = EditTaskCommand(event.index, event.newTitle);
        await _executeCommand(command, emit);
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
        ));
        try {
          await _taskRepository.saveTasks(updatedTasks);
          emit(TaskState(
            tasks: updatedTasks,
            canUndo: _currentCommandIndex >= 0,
            canRedo: _currentCommandIndex < _commandHistory.length - 1,
          ));
        } catch (e) {
          emit(TaskState(
            tasks: updatedTasks,
            error: 'Failed to undo action: $e',
            canUndo: _currentCommandIndex >= 0,
            canRedo: _currentCommandIndex < _commandHistory.length - 1,
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
        ));
        try {
          await _taskRepository.saveTasks(updatedTasks);
          emit(TaskState(
            tasks: updatedTasks,
            canUndo: _currentCommandIndex >= 0,
            canRedo: _currentCommandIndex < _commandHistory.length - 1,
          ));
        } catch (e) {
          emit(TaskState(
            tasks: updatedTasks,
            error: 'Failed to redo action: $e',
            canUndo: _currentCommandIndex >= 0,
            canRedo: _currentCommandIndex < _commandHistory.length - 1,
          ));
        }
      }
    }, transformer: null);

    _initialize();
  }

  Future<void> _initialize() async {
    add(LoadTasksEvent());
  }

  Future<void> _executeCommand(
      TaskCommand command, Emitter<TaskState> emit) async {
    // Clear redo history after a new command
    if (_currentCommandIndex < _commandHistory.length - 1) {
      _commandHistory.removeRange(
          _currentCommandIndex + 1, _commandHistory.length);
    }

    final updatedTasks = List<Task>.from(state.tasks);
    command.execute(updatedTasks);
    _commandHistory.add(command);
    _currentCommandIndex++;

    // Emit the loading state
    emit(TaskState(
      tasks: updatedTasks,
      isLoading: true,
      canUndo: _currentCommandIndex >= 0,
      canRedo: _currentCommandIndex < _commandHistory.length - 1,
    ));

    // Perform the save operation and emit the final state
    try {
      await _taskRepository.saveTasks(updatedTasks);
      emit(TaskState(
        tasks: updatedTasks,
        canUndo: _currentCommandIndex >= 0,
        canRedo: _currentCommandIndex < _commandHistory.length - 1,
      ));
    } catch (e) {
      emit(TaskState(
        tasks: updatedTasks,
        error: 'Failed to save tasks: $e',
        canUndo: _currentCommandIndex >= 0,
        canRedo: _currentCommandIndex < _commandHistory.length - 1,
      ));
    }
  }
}
