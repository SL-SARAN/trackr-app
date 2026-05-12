import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/tables/budgets_table.dart';
import '../database/tables/expenses_table.dart';

part 'budget_dao.g.dart';

@DriftAccessor(tables: [Budgets, Expenses])
class BudgetDao extends DatabaseAccessor<AppDatabase> with _$BudgetDaoMixin {
  BudgetDao(super.db);

  /// The currently active budget record.
  Future<Budget?> getActive() =>
      (select(budgets)..where((b) => b.isActive.equals(true)))
          .getSingleOrNull();

  Stream<Budget?> watchActive() =>
      (select(budgets)..where((b) => b.isActive.equals(true)))
          .watchSingleOrNull();

  Future<int> insert(BudgetsCompanion entry) => into(budgets).insert(entry);

  /// Deactivate all existing budgets before inserting a new one.
  Future<void> deactivateAll() =>
      (update(budgets)).write(const BudgetsCompanion(isActive: Value(false)));

  Future<bool> updateAmount(int id, double amount) =>
      (update(budgets)..where((b) => b.id.equals(id)))
          .write(BudgetsCompanion(amount: Value(amount)))
          .then((rows) => rows > 0);
}
