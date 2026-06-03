import 'package:get_it/get_it.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/budget_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/task_repository.dart';
import '../../services/notification_service.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // --- Database ---
  sl.registerLazySingleton<AppDatabase>(AppDatabase.new);

  // --- DAOs (accessed through the database) ---
  sl.registerLazySingleton(() => sl<AppDatabase>().categoryDao);
  sl.registerLazySingleton(() => sl<AppDatabase>().expenseDao);
  sl.registerLazySingleton(() => sl<AppDatabase>().taskDao);
  sl.registerLazySingleton(() => sl<AppDatabase>().budgetDao);
  sl.registerLazySingleton(() => sl<AppDatabase>().settingsDao);

  // --- Repositories ---
  sl.registerLazySingleton(() => CategoryRepository(sl()));
  sl.registerLazySingleton(() => ExpenseRepository(sl()));
  sl.registerLazySingleton(() => TaskRepository(sl()));
  sl.registerLazySingleton(() => BudgetRepository(sl()));
  sl.registerLazySingleton(() => SettingsRepository(sl()));

  // --- Services ---
  sl.registerLazySingleton(() => NotificationService());
}
