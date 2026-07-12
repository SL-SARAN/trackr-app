import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/tables/recurring_expenses_table.dart';

part 'recurring_expense_dao.g.dart';

@DriftAccessor(tables: [RecurringExpenses])
class RecurringExpenseDao extends DatabaseAccessor<AppDatabase>
    with _$RecurringExpenseDaoMixin {
  RecurringExpenseDao(super.db);

  Future<List<RecurringExpense>> getActiveRecurringExpenses() =>
      (select(recurringExpenses)..where((t) => t.isActive.equals(true))).get();

  Future<List<RecurringExpense>> getDueRecurringExpenses(DateTime date) =>
      (select(recurringExpenses)
            ..where((t) =>
                t.isActive.equals(true) &
                t.nextDueDate.isSmallerOrEqualValue(date)))
          .get();

  Future<int> insertRecurringExpense(RecurringExpensesCompanion entry) =>
      into(recurringExpenses).insert(entry);

  Future<bool> updateRecurringExpense(RecurringExpense entry) =>
      update(recurringExpenses).replace(entry);

  Future<int> deleteRecurringExpense(int id) =>
      (delete(recurringExpenses)..where((t) => t.id.equals(id))).go();
}
