import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/tables/categories_table.dart';
import '../database/tables/expenses_table.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [Categories, Expenses])
class CategoryDao extends DatabaseAccessor<AppDatabase> with _$CategoryDaoMixin {
  CategoryDao(super.db);

  /// All categories ordered by sort_order then created_at.
  Stream<List<Category>> watchAll() =>
      (select(categories)..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
          .watch();

  Future<List<Category>> getAll() =>
      (select(categories)..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
          .get();

  Future<Category?> getById(int id) =>
      (select(categories)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<int> insert(CategoriesCompanion entry) =>
      into(categories).insert(entry);

  Future<bool> updateEntry(CategoriesCompanion entry) =>
      (update(categories)..where((c) => c.id.equals(entry.id.value)))
          .write(entry)
          .then((rows) => rows > 0);

  /// Delete is only called for non-system categories.
  Future<int> deleteById(int id) =>
      (delete(categories)..where((c) => c.id.equals(id))).go();

  /// Returns the sum of expense amounts per category for a given date range.
  /// Only includes debit (expense) type — excludes income.
  Future<Map<int, double>> getSpendingPerCategory({
    required DateTime from,
    required DateTime to,
  }) async {
    final query = selectOnly(expenses)
      ..addColumns([expenses.categoryId, expenses.amount.sum()])
      ..where(expenses.date.isBetweenValues(from, to))
      ..where(expenses.type.equals('debit'))
      ..groupBy([expenses.categoryId]);

    final rows = await query.get();
    return {
      for (final row in rows)
        row.read(expenses.categoryId)!: row.read(expenses.amount.sum()) ?? 0.0,
    };
  }
}
