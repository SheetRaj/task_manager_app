import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_manager_app/blocs/task_bloc.dart';
import 'package:task_manager_app/blocs/task_event.dart';
import 'package:task_manager_app/models/task.dart';
import 'package:task_manager_app/utils/constants.dart';
import 'package:task_manager_app/widgets/swipe_action_background.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final int originalIndex;
  final TaskBloc taskBloc;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  final Future<bool?> Function(BuildContext) showDeleteConfirmDialog;
  final void Function(int, String, String, DateTime?) showEditTaskDialog;

  const TaskTile({
    super.key,
    required this.task,
    required this.originalIndex,
    required this.taskBloc,
    required this.scaffoldMessengerKey,
    required this.showDeleteConfirmDialog,
    required this.showEditTaskDialog,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppConstants.taskItemBottomPadding),
      child: Dismissible(
        key: Key(task.id),
        direction: DismissDirection.horizontal,
        background: const SwipeActionBackground(
          alignment: Alignment.centerLeft,
          color: AppConstants.swipeEditColor,
          icon: Icons.edit,
          label: 'Edit',
        ),
        secondaryBackground: const SwipeActionBackground(
          alignment: Alignment.centerRight,
          color: AppConstants.swipeDeleteColor,
          icon: Icons.delete,
          label: 'Delete',
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            Future.delayed(
                Duration.zero,
                () => showEditTaskDialog(
                    originalIndex, task.title, task.category, task.dueDate));
            return false;
          } else {
            return await showDeleteConfirmDialog(context);
          }
        },
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            taskBloc.add(DeleteTaskEvent(originalIndex));
            scaffoldMessengerKey.currentState?.clearSnackBars();
            scaffoldMessengerKey.currentState?.showSnackBar(
              const SnackBar(content: Text(AppConstants.taskDeletedMessage)),
            );
          }
        },
        child: AnimatedContainer(
          duration: AppConstants.animationDuration,
          curve: Curves.fastOutSlowIn,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(18.0),
            boxShadow: [
              BoxShadow(
                color: AppConstants.shadowColor,
                blurRadius: AppConstants.shadowBlurRadius,
                offset: AppConstants.shadowOffset,
              ),
            ],
          ),
          child: Stack(
            children: [
              ListTile(
                contentPadding: AppConstants.listTilePadding,
                title: Text(
                  task.title,
                  style: AppConstants.taskTitleStyle.copyWith(
                    color: task.isCompleted ? Colors.grey : Colors.black87,
                    decoration:
                        task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category: ${task.category}',
                      style: AppConstants.subtitleStyle,
                    ),
                    if (task.dueDate != null)
                      Text(
                        'Due: ${DateFormat('yyyy-MM-dd HH:mm').format(task.dueDate!)}',
                        style: AppConstants.subtitleStyle.copyWith(
                          color: task.dueDate!.isBefore(DateTime.now())
                              ? AppConstants.overdueColor
                              : AppConstants.subtitleColor,
                        ),
                      ),
                  ],
                ),
                leading: AnimatedSwitcher(
                  duration: AppConstants.animationDuration,
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: task.isCompleted
                      ? const Icon(
                          Icons.check_circle,
                          key: ValueKey(true),
                          color: AppConstants.completedColor,
                          size: AppConstants.taskIconSize,
                        )
                      : const Icon(
                          Icons.radio_button_unchecked,
                          key: ValueKey(false),
                          color: AppConstants.uncompletedColor,
                          size: AppConstants.taskIconSize,
                        ),
                ),
                onTap: () {
                  taskBloc.add(ToggleTaskCompletionEvent(originalIndex));
                },
              ),
              Positioned(
                left: 10,
                top: 0,
                bottom: 0,
                child: AnimatedOpacity(
                  opacity: 0.6,
                  duration: AppConstants.swipeOpacityDuration,
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: AppConstants.swipeEditColor,
                    size: AppConstants.swipeIconSize,
                  ),
                ),
              ),
              Positioned(
                right: 10,
                top: 0,
                bottom: 0,
                child: AnimatedOpacity(
                  opacity: 0.6,
                  duration: AppConstants.swipeOpacityDuration,
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: AppConstants.swipeDeleteColor,
                    size: AppConstants.swipeIconSize,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
