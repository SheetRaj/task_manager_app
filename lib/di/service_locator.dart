import 'package:get_it/get_it.dart';
import 'package:task_manager_app/blocs/task_bloc.dart';
import 'package:task_manager_app/repositories/shared_preferences_task_repository.dart';
import 'package:task_manager_app/repositories/task_repository.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<TaskRepository>(
      () => SharedPreferencesTaskRepository());
  getIt.registerFactory<TaskBloc>(
      () => TaskBloc(taskRepository: getIt<TaskRepository>()));
}
