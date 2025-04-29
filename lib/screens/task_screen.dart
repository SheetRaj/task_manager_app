import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_app/blocs/task_bloc.dart';
import 'package:task_manager_app/blocs/task_event.dart';
import 'package:task_manager_app/blocs/task_state.dart';
import 'package:task_manager_app/widgets/swipe_action_background.dart';

/// A screen that displays a list of tasks and allows adding new ones.
class TaskScreen extends StatefulWidget {
  /// Creates a [TaskScreen].
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final _taskController = TextEditingController();
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  late TaskBloc _taskBloc;

  @override
  void initState() {
    super.initState();
    _taskBloc = context.read<TaskBloc>();
    _showOnboardingIfNeeded();
  }

  Future<void> _showOnboardingIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    const onboardingKey = 'has_seen_swipe_onboarding';
    final hasSeenOnboarding = prefs.getBool(onboardingKey) ?? false;

    if (!hasSeenOnboarding) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        showDialog<void>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Swipe to Manage Tasks'),
              content: const Text(
                'Swipe left on a task to edit it, or swipe right to delete it.\n\n'
                'Look for the arrows on each task card as a hint!',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    prefs.setBool(onboardingKey, true);
                  },
                  child: const Text('Got It'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  void _showAddTaskDialog() {
    _taskController.clear();
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: TextField(
            controller: _taskController,
            decoration: const InputDecoration(hintText: 'Enter task title'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_taskController.text.trim().isEmpty) {
                  _scaffoldMessengerKey.currentState?.showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a task title'),
                    ),
                  );
                } else {
                  _taskBloc.add(AddTaskEvent(_taskController.text));
                  _taskController.clear();
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditTaskDialog(int index, String currentTitle) {
    _taskController.text = currentTitle;
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: TextField(
            controller: _taskController,
            decoration: const InputDecoration(hintText: 'Enter new task title'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_taskController.text.trim().isEmpty) {
                  _scaffoldMessengerKey.currentState?.showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a task title'),
                    ),
                  );
                } else {
                  _taskBloc.add(EditTaskEvent(index, _taskController.text));
                  _taskController.clear();
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Container(
            padding: const EdgeInsets.only(top: 32, left: 16, right: 16),
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.undo, color: Colors.white),
                      onPressed: context.watch<TaskBloc>().state.canUndo
                          ? () {
                              _taskBloc.add(UndoEvent());
                              _scaffoldMessengerKey.currentState?.showSnackBar(
                                const SnackBar(
                                  content: Text('Action undone'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.redo, color: Colors.white),
                      onPressed: context.watch<TaskBloc>().state.canRedo
                          ? () {
                              _taskBloc.add(RedoEvent());
                              _scaffoldMessengerKey.currentState?.showSnackBar(
                                const SnackBar(
                                  content: Text('Action redone'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          : null,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.task_alt,
                      color: Colors.white,
                      size: 30,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Task Manager',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 48), // Spacer for balance
              ],
            ),
          ),
        ),
        body: BlocConsumer<TaskBloc, TaskState>(
          listener: (context, state) {
            if (state.error != null) {
              print('Error received in listener: ${state.error}');
              _scaffoldMessengerKey.currentState?.clearSnackBars();
              _scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(content: Text(state.error!)),
              );
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.tasks.isEmpty) {
              return const Center(
                child: Text('No tasks yet. Add one!'),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(20.0),
              itemCount: state.tasks.length,
              itemBuilder: (context, index) {
                final task = state.tasks[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Dismissible(
                    key: Key(task.id),
                    direction: DismissDirection.horizontal,
                    background: const SwipeActionBackground(
                      alignment: Alignment.centerLeft,
                      color: Colors.blueAccent,
                      icon: Icons.edit,
                      label: 'Edit',
                    ),
                    secondaryBackground: const SwipeActionBackground(
                      alignment: Alignment.centerRight,
                      color: Colors.redAccent,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        Future.delayed(Duration.zero,
                            () => _showEditTaskDialog(index, task.title));
                        return false;
                      } else {
                        return await _showDeleteConfirmDialog(context);
                      }
                    },
                    onDismissed: (direction) {
                      if (direction == DismissDirection.endToStart) {
                        _taskBloc.add(DeleteTaskEvent(index));
                        _scaffoldMessengerKey.currentState?.clearSnackBars();
                        _scaffoldMessengerKey.currentState?.showSnackBar(
                          const SnackBar(
                            content: Text('Task deleted'),
                          ),
                        );
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.fastOutSlowIn,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(18.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 40.0, vertical: 14.0),
                            title: Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                                color: task.isCompleted
                                    ? Colors.grey
                                    : Colors.black87,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            leading: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child, animation) =>
                                  ScaleTransition(
                                      scale: animation, child: child),
                              child: task.isCompleted
                                  ? const Icon(Icons.check_circle,
                                      key: ValueKey(true),
                                      color: Colors.green,
                                      size: 28)
                                  : const Icon(Icons.radio_button_unchecked,
                                      key: ValueKey(false),
                                      color: Colors.grey,
                                      size: 28),
                            ),
                            onTap: () {
                              _taskBloc.add(ToggleTaskCompletionEvent(index));
                            },
                          ),
                          Positioned(
                            left: 10,
                            top: 0,
                            bottom: 0,
                            child: AnimatedOpacity(
                              opacity: 0.6,
                              duration: const Duration(milliseconds: 1000),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.blueAccent,
                                size: 18,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 10,
                            top: 0,
                            bottom: 0,
                            child: AnimatedOpacity(
                              opacity: 0.6,
                              duration: const Duration(milliseconds: 1000),
                              child: Icon(
                                Icons.arrow_back_ios,
                                color: Colors.redAccent,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddTaskDialog,
          child: const Icon(Icons.add_task),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Task?'),
          content: const Text('Do you really want to delete this task?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel')),
            ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete')),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }
}
