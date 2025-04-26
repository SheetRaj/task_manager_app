# Task Manager App - Architectural Documentation

## Overview
The Task Manager App is a simple Flutter application that allows users to manage tasks by adding, editing, deleting, and toggling their completion status. The app follows a modular architecture with separation of concerns, using the `Bloc` pattern for state management and `shared_preferences` for persistence.

## Architecture
The app is structured using a loose MVC (Model-View-Controller) pattern:
- **Model**: Represents the data layer.
    - `Task` (`lib/models/task.dart`): A data model for tasks with properties like `id`, `title`, and `isCompleted`.
- **View**: Handles the UI layer.
    - `TaskScreen` (`lib/screens/task_screen.dart`): The main screen displaying the list of tasks, with dialogs for adding and editing tasks.
    - `TaskItem` (`lib/widgets/task_item.dart`): A reusable widget for rendering individual tasks.
- **Controller**: Manages the business logic and state.
    - `TaskBloc` (`lib/blocs/task_bloc.dart`): Handles state management using the `Bloc` pattern, processing events like adding, editing, deleting, and toggling tasks.
    - `TaskEvent` (`lib/blocs/task_event.dart`): Defines events like `AddTaskEvent`, `EditTaskEvent`, `DeleteTaskEvent`, `ToggleTaskCompletionEvent`, and `LoadTasksEvent`.
    - `TaskState` (`lib/blocs/task_state.dart`): Represents the state of the task list, including `tasks`, `isLoading`, and `error`.

### Persistence
- **TaskStorageService** (`lib/services/task_storage_service.dart`): Handles saving and loading tasks using `shared_preferences`. Tasks are serialized to JSON and stored under a single key.

### File Structure
lib/
├── blocs/                # State management logic
│   ├── task_bloc.dart
│   ├── task_event.dart
│   └── task_state.dart
├── models/               # Data models
│   └── task.dart
├── screens/              # UI screens
│   └── task_screen.dart
├── services/             # Business logic services
│   └── task_storage_service.dart
├── widgets/              # Reusable UI components
│   └── task_item.dart
└── main.dart             # Entry point of the app



## Key Design Decisions
1. **State Management with `Bloc`**:
    - **Why**: The `Bloc` pattern was chosen to enforce a unidirectional data flow, making the app easier to test and maintain as it grows.
    - **Impact**: Events like `AddTaskEvent` and `EditTaskEvent` are processed by `TaskBloc`, which updates the `TaskState` and notifies the UI via `BlocConsumer`.

2. **Persistence with `shared_preferences`**:
    - **Why**: `shared_preferences` was selected for its simplicity, as the app currently handles a small number of tasks. It’s sufficient for storing a list of tasks in JSON format.
    - **Impact**: Tasks persist between app sessions, but this approach may need to be replaced with a database (e.g., `sqflite`) if the app scales to handle larger datasets.

3. **Swipe-to-Delete and Swipe-to-Edit with `Dismissible`**:
    - **Why**: The `Dismissible` widget was chosen to provide a modern, mobile-friendly UX for deleting and editing tasks. Swiping left deletes a task, and swiping right opens an edit dialog.
    - **Impact**: This improves the user experience by leveraging familiar mobile patterns, with a confirmation dialog for deletion to prevent accidental actions.

4. **Loading and Error States**:
    - **Why**: Added `isLoading` and `error` to `TaskState` to provide feedback during async operations (e.g., saving/loading tasks) and handle errors gracefully.
    - **Impact**: Users see a loading indicator during persistence operations, and errors are displayed via snackbars, improving reliability and UX.

## UI Design
- **AppBar**: Custom-designed with a black background, a task icon, and a bold "Task Manager" title.
- **Task List**: Uses `ListView.builder` with styled `ListTile` widgets inside `AnimatedContainer` for smooth animations. Tasks have rounded cards with shadows, and completion status is shown with animated checkmarks.
- **Swipe Actions**: Swiping left (delete) shows a red background, and swiping right (edit) shows a blue background, both with appropriate icons.

## Future Considerations
- **Scalability**: If the task list grows large, consider replacing `shared_preferences` with a local database like `sqflite` or `hive`.
- **Async Operations**: Handle app lifecycle events (e.g., saving tasks when the app is paused) to ensure no data is lost during abrupt closures.
- **UI Patterns**: Explore additional UI patterns (e.g., undo functionality for deletions) in Section 8.
- **Concurrency**: Optimize persistence operations using background tasks in Section 9.

## How to Extend the App
- To add a new feature (e.g., task categories):
    1. Update the `Task` model to include a `category` field.
    2. Add a new event (e.g., `SetTaskCategoryEvent`) in `task_event.dart`.
    3. Handle the event in `TaskBloc` to update the task’s category and save the changes.
    4. Update the UI in `TaskScreen` and `TaskItem` to display and modify categories.