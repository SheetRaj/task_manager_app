import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager_app/blocs/task_bloc.dart';
import 'package:task_manager_app/screens/task_screen.dart';

void main() {
  runApp(const TaskManagerApp());
}
/// The main application widget for the Task Manager app.
class TaskManagerApp extends StatelessWidget {
  /// Creates a [TaskManagerApp].
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TaskBloc(),
      child: MaterialApp(
        title: 'Task Manager',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const TaskScreen(),
      ),
    );
  }
}