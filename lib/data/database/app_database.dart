import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/categories_table.dart';
import 'tables/expenses_table.dart';
import 'tables/tasks_table.dart';
import 'tables/budgets_table.dart';
import 'tables/settings_table.dart';
import '../daos/category_dao.dart';
import '../daos/expense_dao.dart';
import '../daos/task_dao.dart';
import '../daos/budget_dao.dart';
import '../daos/settings_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Categories, Expenses, Tasks, Budgets, AppSettings],
  daos: [CategoryDao, ExpenseDao, TaskDao, BudgetDao, SettingsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // Bump this when the schema changes.
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // Future migrations will be added here.
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'trackr.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
