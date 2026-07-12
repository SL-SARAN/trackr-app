import 'package:drift/drift.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/expense_entity.dart';
import '../daos/expense_dao.dart';
import '../database/app_database.dart';

class ExpenseRepository {
  final ExpenseDao _dao;

  ExpenseRepository(this._dao);

  Stream<List<ExpenseEntity>> watchAll() =>
      _dao.watchAll().map((rows) => rows.map(_toEntity).toList());

  Future<List<ExpenseEntity>> getFiltered({
    DateTime? from,
    DateTime? to,
    int? categoryId,
    String? searchQuery,
    String? type,
    int limit = 50,
    int offset = 0,
  }) async {
    final rows = await _dao.getFiltered(
      from: from,
      to: to,
      categoryId: categoryId,
      searchQuery: searchQuery,
      type: type,
      limit: limit,
      offset: offset,
    );
    return rows.map(_toEntity).toList();
  }

  Future<double> getTotalSpent({required DateTime from, required DateTime to, String type = 'debit'}) =>
      _dao.getTotalSpent(from: from, to: to, type: type);

  Future<Map<DateTime, double>> getDailyTotals({
    required DateTime from,
    required DateTime to,
    String type = 'debit',
  }) =>
      _dao.getDailyTotals(from: from, to: to, type: type);

  Future<int> create({
    required double amount,
    required int categoryId,
    String? description,
    required DateTime date,
    required String type,
  }) async {
    final tag = DateHelper.timeOfDayTagString(date);
    return _dao.insert(ExpensesCompanion.insert(
      amount: amount,
      categoryId: categoryId,
      description: Value(description),
      date: date,
      timeOfDayTag: tag,
      type: Value(type),
    ));
  }

  Future<bool> update({
    required int id,
    double? amount,
    int? categoryId,
    String? description,
    DateTime? date,
  }) {
    final tag = date != null ? DateHelper.timeOfDayTagString(date) : null;
    return _dao.updateEntry(ExpensesCompanion(
      id: Value(id),
      amount: amount != null ? Value(amount) : const Value.absent(),
      categoryId: categoryId != null ? Value(categoryId) : const Value.absent(),
      description: description != null ? Value(description) : const Value.absent(),
      date: date != null ? Value(date) : const Value.absent(),
      timeOfDayTag: tag != null ? Value(tag) : const Value.absent(),
    ));
  }

  Future<int> delete(int id) => _dao.deleteById(id);

  ExpenseEntity _toEntity(Expense row) => ExpenseEntity(
        id: row.id,
        amount: row.amount,
        categoryId: row.categoryId,
        description: row.description,
        date: row.date,
        timeOfDayTag: TimeOfDayTagX.fromString(row.timeOfDayTag),
        createdAt: row.createdAt,
        type: row.type,
      );
}
