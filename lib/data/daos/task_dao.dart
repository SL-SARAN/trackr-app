import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/tables/tasks_table.dart';

part 'task_dao.g.dart';

@DriftAccessor(tables: [Tasks])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

  /// Stream of all incomplete tasks, ordered by importance then scheduled time.
  Stream<List<Task>> watchPending() => (select(tasks)
        ..where((t) => t.isCompleted.equals(false))
        ..orderBy([
          (t) => OrderingTerm(
                expression: t.importance,
                // 'high' sorts before 'medium' before 'low' alphabetically reversed.
                // We handle proper ordering in the repository layer.
              ),
          (t) => OrderingTerm.asc(t.scheduledAt),
        ]))
      .watch();

  /// The next [limit] upcoming incomplete tasks from now,
  /// high importance first, then by scheduled time.
  Future<List<Task>> getNextUp(int limit) async {
    final now = DateTime.now();
    final allPending = await (select(tasks)
          ..where((t) => t.isCompleted.equals(false) & t.scheduledAt.isBiggerOrEqualValue(now))
          ..orderBy([(t) => OrderingTerm.asc(t.scheduledAt)]))
        .get();

    // Sort: high > medium > low, then by scheduledAt
    allPending.sort((a, b) {
      final imp = _importanceOrder(b.importance).compareTo(_importanceOrder(a.importance));
      if (imp != 0) return imp;
      return a.scheduledAt.compareTo(b.scheduledAt);
    });

    return allPending.take(limit).toList();
  }

  int _importanceOrder(String importance) {
    switch (importance) {
      case 'high':
        return 2;
      case 'medium':
        return 1;
      default:
        return 0;
    }
  }

  /// All tasks scheduled for a specific date.
  Future<List<Task>> getForDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (select(tasks)
          ..where((t) => t.scheduledAt.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.asc(t.scheduledAt)]))
        .get();
  }

  Future<Task?> getById(int id) =>
      (select(tasks)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insert(TasksCompanion entry) => into(tasks).insert(entry);

  Future<bool> updateEntry(TasksCompanion entry) =>
      (update(tasks)..where((t) => t.id.equals(entry.id.value)))
          .write(entry)
          .then((rows) => rows > 0);

  Future<bool> markDone(int id, {int? linkedExpenseId}) =>
      (update(tasks)..where((t) => t.id.equals(id)))
          .write(TasksCompanion(
            isCompleted: const Value(true),
            linkedExpenseId: linkedExpenseId != null
                ? Value(linkedExpenseId)
                : const Value.absent(),
          ))
          .then((rows) => rows > 0);

  Future<int> deleteById(int id) =>
      (delete(tasks)..where((t) => t.id.equals(id))).go();
}
