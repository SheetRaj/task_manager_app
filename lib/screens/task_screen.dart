import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_app/blocs/task_bloc.dart';
import 'package:task_manager_app/blocs/task_event.dart';
import 'package:task_manager_app/blocs/task_state.dart';
import 'package:task_manager_app/utils/constants.dart';
import 'package:task_manager_app/widgets/task_app_bar.dart';
import 'package:task_manager_app/widgets/task_dialog.dart';
import 'package:task_manager_app/widgets/task_tile.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
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
    showDialog<void>(
      context: context,
      builder: (context) => TaskDialog(
        isEditMode: false,
        scaffoldMessengerKey: _scaffoldMessengerKey,
        taskBloc: _taskBloc,
      ),
    );
  }

  void _showEditTaskDialog(
      int index, String title, String category, DateTime? dueDate) {
    showDialog<void>(
      context: context,
      builder: (context) => TaskDialog(
        isEditMode: true,
        index: index,
        initialTitle: title,
        initialCategory: category,
        initialDueDate: dueDate,
        scaffoldMessengerKey: _scaffoldMessengerKey,
        taskBloc: _taskBloc,
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
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
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
        appBar: TaskAppBar(scaffoldMessengerKey: _scaffoldMessengerKey),
        body: Column(
          children: [
            Padding(
              padding: AppConstants.filterRowPadding,
              child: BlocBuilder<TaskBloc, TaskState>(
                builder: (context, state) {
                  return Row(
                    children: [
                      const Text(
                        'Filter by Category:',
                        style: AppConstants.filterLabelStyle,
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<String?>(
                        value: state.filterCategory,
                        hint: const Text('All'),
                        onChanged: (value) {
                          _taskBloc.add(SetCategoryFilterEvent(value));
                        },
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('All'),
                          ),
                          ...state.categories
                              .map((category) => DropdownMenuItem<String>(
                                    value: category,
                                    child: Text(category),
                                  )),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            Expanded(
              child: BlocConsumer<TaskBloc, TaskState>(
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
                  final tasksToShow = state.filteredTasks;
                  if (tasksToShow.isEmpty) {
                    return const Center(
                      child: Text(AppConstants.noTasksMessage),
                    );
                  }
                  return ListView.builder(
                    padding: AppConstants.listViewPadding,
                    itemCount: tasksToShow.length,
                    itemBuilder: (context, index) {
                      final task = tasksToShow[index];
                      final originalIndex = state.tasks.indexOf(task);
                      return TaskTile(
                        task: task,
                        originalIndex: originalIndex,
                        taskBloc: _taskBloc,
                        scaffoldMessengerKey: _scaffoldMessengerKey,
                        showDeleteConfirmDialog: _showDeleteConfirmDialog,
                        showEditTaskDialog: _showEditTaskDialog,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddTaskDialog,
          child: const Icon(Icons.add_task),
        ),
      ),
    );
  }
}
