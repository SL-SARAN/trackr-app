import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/tables/expenses_table.dart';

part 'expense_dao.g.dart';

@DriftAccessor(tables: [Expenses])
class ExpenseDao extends DatabaseAccessor<AppDatabase> with _$ExpenseDaoMixin {
  ExpenseDao(super.db);

  /// Live stream of all expenses, newest first.
  Stream<List<Expense>> watchAll() =>
      (select(expenses)..orderBy([(e) => OrderingTerm.desc(e.date)])).watch();

  /// Paginated query with optional filters.
  Future<List<Expense>> getFiltered({
    DateTime? from,
    DateTime? to,
    int? categoryId,
    String? searchQuery,
    int limit = 50,
    int offset = 0,
  }) {
    final query = select(expenses)
      ..orderBy([(e) => OrderingTerm.desc(e.date)])
      ..limit(limit, offset: offset);

    query.where((e) {
      Expression<bool> condition = const Constant(true);
      if (from != null) condition = condition & e.date.isBiggerOrEqualValue(from);
      if (to != null) condition = condition & e.date.isSmallerOrEqualValue(to);
      if (categoryId != null) condition = condition & e.categoryId.equals(categoryId);
      if (searchQuery != null && searchQuery.isNotEmpty) {
        condition = condition & e.description.like('%$searchQuery%');
      }
      return condition;
    });

    return query.get();
  }

  /// Daily spending totals for the trend chart (last N days).
  Future<Map<DateTime, double>> getDailyTotals({
    required DateTime from,
    required DateTime to,
  }) async {
    final query = selectOnly(expenses)
      ..addColumns([expenses.date, expenses.amount.sum()])
      ..where(expenses.date.isBetweenValues(from, to))
      ..groupBy([expenses.date]);

    final rows = await query.get();
    final Map<DateTime, double> result = {};
    for (final row in rows) {
      final rawDate = row.read(expenses.date);
      if (rawDate == null) continue;
      final day = DateTime(rawDate.year, rawDate.month, rawDate.day);
      result[day] = (result[day] ?? 0) + (row.read(expenses.amount.sum()) ?? 0);
    }
    return result;
  }

  /// Total spent between two datetimes (for budget progress).
  Future<double> getTotalSpent({
    required DateTime from,
    required DateTime to,
  }) async {
    final query = selectOnly(expenses)
      ..addColumns([expenses.amount.sum()])
      ..where(expenses.date.isBetweenValues(from, to));
    final row = await query.getSingleOrNull();
    return row?.read(expenses.amount.sum()) ?? 0.0;
  }

  Future<int> insert(ExpensesCompanion entry) =>
      into(expenses).insert(entry);

  Future<bool> updateEntry(ExpensesCompanion entry) =>
      (update(expenses)..where((e) => e.id.equals(entry.id.value)))
          .write(entry)
          .then((rows) => rows > 0);

  Future<int> deleteById(int id) =>
      (delete(expenses)..where((e) => e.id.equals(id))).go();
}
