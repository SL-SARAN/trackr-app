import 'package:drift/drift.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/task_entity.dart';
import '../../core/constants/app_constants.dart';
import '../daos/task_dao.dart';
import '../database/app_database.dart';

class TaskRepository {
  final TaskDao _dao;

  TaskRepository(this._dao);

  Stream<List<TaskEntity>> watchPending() =>
      _dao.watchPending().map((rows) => rows.map(_toEntity).toList());

  Future<List<TaskEntity>> getNextUp() async {
    final rows = await _dao.getNextUp(AppConstants.nextUpCount);
    return rows.map(_toEntity).toList();
  }

  Future<TaskEntity?> getById(int id) async {
    final row = await _dao.getById(id);
    return row == null ? null : _toEntity(row);
  }

  Future<int> create({
    required String title,
    String? description,
    required ImportanceLevel importance,
    required DateTime scheduledAt,
    int? reminderMinutes,
    required bool isRecurring,
    required RecurrenceType recurrenceType,
    required bool isPlannedExpense,
    double? estimatedAmount,
    int? categoryId,
    int? notificationId,
  }) =>
      _dao.insert(TasksCompanion.insert(
        title: title,
        description: Value(description),
        importance: Value(importance.value),
        scheduledAt: scheduledAt,
        reminderMinutes: Value(reminderMinutes),
        isRecurring: Value(isRecurring),
        recurrenceType: Value(recurrenceType.value),
        isPlannedExpense: Value(isPlannedExpense),
        estimatedAmount: Value(estimatedAmount),
        categoryId: Value(categoryId),
        notificationId: Value(notificationId),
      ));

  Future<bool> markDone(int id, {int? linkedExpenseId}) =>
      _dao.markDone(id, linkedExpenseId: linkedExpenseId);

  Future<int> delete(int id) => _dao.deleteById(id);

  TaskEntity _toEntity(Task row) => TaskEntity(
        id: row.id,
        title: row.title,
        description: row.description,
        importance: ImportanceLevelX.fromString(row.importance),
        scheduledAt: row.scheduledAt,
        reminderMinutes: row.reminderMinutes,
        isRecurring: row.isRecurring,
        recurrenceType: RecurrenceTypeX.fromString(row.recurrenceType),
        isCompleted: row.isCompleted,
        isPlannedExpense: row.isPlannedExpense,
        linkedExpenseId: row.linkedExpenseId,
        estimatedAmount: row.estimatedAmount,
        categoryId: row.categoryId,
        notificationId: row.notificationId,
        createdAt: row.createdAt,
      );
}
