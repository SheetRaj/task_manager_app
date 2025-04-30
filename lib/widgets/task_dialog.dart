import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:task_manager_app/blocs/task_bloc.dart';
import 'package:task_manager_app/blocs/task_event.dart';
import 'package:task_manager_app/blocs/task_state.dart';
import 'package:task_manager_app/utils/constants.dart';

class TaskDialog extends StatefulWidget {
  final bool isEditMode;
  final int? index;
  final String? initialTitle;
  final String? initialCategory;
  final DateTime? initialDueDate;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  final TaskBloc taskBloc;

  const TaskDialog({
    super.key,
    required this.isEditMode,
    this.index,
    this.initialTitle,
    this.initialCategory,
    this.initialDueDate,
    required this.scaffoldMessengerKey,
    required this.taskBloc,
  });

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  late TextEditingController _taskController;
  late TextEditingController _categoryController;
  late String _selectedCategory;
  late bool _isAddingNewCategory;
  late DateTime? _selectedDueDate;

  @override
  void initState() {
    super.initState();
    _taskController = TextEditingController(text: widget.initialTitle ?? '');
    _categoryController = TextEditingController();
    _selectedCategory = widget.initialCategory ?? 'Uncategorized';
    _isAddingNewCategory = false;
    _selectedDueDate = widget.initialDueDate;
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _submitTask() {
    if (_taskController.text.trim().isEmpty) {
      widget.scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text(AppConstants.emptyTitleError)),
      );
    } else if (_isAddingNewCategory &&
        _categoryController.text.trim().isEmpty) {
      widget.scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text(AppConstants.emptyCategoryError)),
      );
    } else {
      final category = _isAddingNewCategory
          ? _categoryController.text.trim()
          : _selectedCategory;
      if (widget.isEditMode) {
        widget.taskBloc.add(EditTaskEvent(
          widget.index!,
          _taskController.text,
          category,
          _selectedDueDate,
        ));
      } else {
        widget.taskBloc.add(AddTaskEvent(
          _taskController.text,
          category,
          _selectedDueDate,
        ));
      }
      _taskController.clear();
      _categoryController.clear();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEditMode ? 'Edit Task' : 'Add Task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _taskController,
              decoration: const InputDecoration(hintText: 'Enter task title'),
            ),
            const SizedBox(height: AppConstants.dialogSpacing),
            Row(
              children: [
                const Text('Category: '),
                Expanded(
                  child: Row(
                    children: [
                      Radio<bool>(
                        value: false,
                        groupValue: _isAddingNewCategory,
                        onChanged: (value) {
                          setState(() {
                            _isAddingNewCategory = value!;
                          });
                        },
                      ),
                      const Text('Select'),
                      Radio<bool>(
                        value: true,
                        groupValue: _isAddingNewCategory,
                        onChanged: (value) {
                          setState(() {
                            _isAddingNewCategory = value!;
                          });
                        },
                      ),
                      const Text('Add New'),
                    ],
                  ),
                ),
              ],
            ),
            if (!_isAddingNewCategory)
              BlocBuilder<TaskBloc, TaskState>(
                bloc: widget.taskBloc, // Use the passed TaskBloc instance
                builder: (context, state) {
                  return DropdownButton<String>(
                    value: _selectedCategory,
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                    items: state.categories
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ))
                        .toList(),
                  );
                },
              )
            else
              TextField(
                controller: _categoryController,
                decoration:
                    const InputDecoration(hintText: 'Enter new category'),
              ),
            const SizedBox(height: AppConstants.dialogSpacing),
            Row(
              children: [
                const Text('Due Date: '),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _selectDueDate(context),
                  child: Text(
                    _selectedDueDate == null
                        ? 'Set Due Date'
                        : DateFormat('yyyy-MM-dd HH:mm')
                            .format(_selectedDueDate!),
                  ),
                ),
                if (_selectedDueDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _selectedDueDate = null;
                      });
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _submitTask,
          child: Text(widget.isEditMode ? 'Save' : 'Add'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _taskController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}
