import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager_app/blocs/task_bloc.dart';
import 'package:task_manager_app/blocs/task_event.dart';
import 'package:task_manager_app/utils/constants.dart';

class TaskAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  const TaskAppBar({super.key, required this.scaffoldMessengerKey});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppConstants.appBarPadding,
      decoration: const BoxDecoration(
        color: AppConstants.appBarColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.undo, color: AppConstants.iconColor),
                onPressed: context.watch<TaskBloc>().state.canUndo
                    ? () {
                        context.read<TaskBloc>().add(UndoEvent());
                        scaffoldMessengerKey.currentState?.showSnackBar(
                          const SnackBar(
                            content: Text(AppConstants.actionUndoneMessage),
                            duration: AppConstants.snackBarDuration,
                          ),
                        );
                      }
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.redo, color: AppConstants.iconColor),
                onPressed: context.watch<TaskBloc>().state.canRedo
                    ? () {
                        context.read<TaskBloc>().add(RedoEvent());
                        scaffoldMessengerKey.currentState?.showSnackBar(
                          const SnackBar(
                            content: Text(AppConstants.actionRedoneMessage),
                            duration: AppConstants.snackBarDuration,
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
                color: AppConstants.iconColor,
                size: AppConstants.iconSize,
              ),
              const SizedBox(width: 8),
              Text(
                AppConstants.appTitle,
                style: AppConstants.appBarTitleStyle,
              ),
            ],
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(AppConstants.appBarHeight);
}
