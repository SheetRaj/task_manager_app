import 'package:flutter/material.dart';

class AppConstants {
  // Colors
  static const Color appBarColor = Colors.black;
  static const Color iconColor = Colors.white;
  static const Color completedColor = Colors.green;
  static const Color uncompletedColor = Colors.grey;
  static const Color overdueColor = Colors.red;
  static const Color swipeEditColor = Colors.blueAccent;
  static const Color swipeDeleteColor = Colors.redAccent;
  static const Color subtitleColor = Colors.black54;
  static const Color shadowColor = Colors.black12;

  // Padding and Sizes
  static const EdgeInsets appBarPadding =
      EdgeInsets.only(top: 32, left: 16, right: 16);
  static const EdgeInsets listViewPadding = EdgeInsets.all(20.0);
  static const EdgeInsets listTilePadding =
      EdgeInsets.symmetric(horizontal: 40.0, vertical: 14.0);
  static const EdgeInsets filterRowPadding = EdgeInsets.all(16.0);
  static const double taskItemBottomPadding = 16.0;
  static const double appBarHeight = 70.0;
  static const double iconSize = 30.0;
  static const double taskIconSize = 28.0;
  static const double swipeIconSize = 18.0;
  static const double shadowBlurRadius = 10.0;
  static const Offset shadowOffset = Offset(0, 5);
  static const double dialogSpacing = 16.0;

  // Text Styles
  static const TextStyle appBarTitleStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  static const TextStyle taskTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 14,
    color: subtitleColor,
  );

  static const TextStyle filterLabelStyle = TextStyle(fontSize: 16);

  // Animation Durations
  static const Duration animationDuration = Duration(milliseconds: 200);
  static const Duration swipeOpacityDuration = Duration(milliseconds: 1000);
  static const Duration snackBarDuration = Duration(seconds: 2);

  // Strings
  static const String appTitle = 'Task Manager';
  static const String noTasksMessage = 'No tasks yet. Add one!';
  static const String loadingMessage = 'Loading...';
  static const String taskDeletedMessage = 'Task deleted';
  static const String actionUndoneMessage = 'Action undone';
  static const String actionRedoneMessage = 'Action redone';
  static const String emptyTitleError = 'Please enter a task title';
  static const String emptyCategoryError = 'Please enter a category';
}
