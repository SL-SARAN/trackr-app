import 'package:drift/drift.dart';
import '../../domain/entities/recurring_expense_entity.dart';
import '../daos/recurring_expense_dao.dart';
import '../database/app_database.dart';

class RecurringExpenseRepository {
  final RecurringExpenseDao _dao;

  RecurringExpenseRepository(this._dao);

  Future<List<RecurringExpenseEntity>> getActiveRecurringExpenses() async {
    final expenses = await _dao.getActiveRecurringExpenses();
    return expenses.map((e) => _mapToEntity(e)).toList();
  }

  Future<List<RecurringExpenseEntity>> getDueRecurringExpenses(DateTime date) async {
    final expenses = await _dao.getDueRecurringExpenses(date);
    return expenses.map((e) => _mapToEntity(e)).toList();
  }

  Future<int> addRecurringExpense({
    required String title,
    required double amount,
    required int categoryId,
    required String frequency,
    required DateTime nextDueDate,
    required bool autoLog,
  }) async {
    return _dao.insertRecurringExpense(
      RecurringExpensesCompanion.insert(
        title: title,
        amount: amount,
        categoryId: categoryId,
        frequency: frequency,
        nextDueDate: nextDueDate,
        autoLog: Value(autoLog),
      ),
    );
  }

  Future<bool> updateNextDueDate(int id, DateTime newDate) async {
    final list = await _dao.getActiveRecurringExpenses();
    final item = list.firstWhere((e) => e.id == id);
    return _dao.updateRecurringExpense(item.copyWith(nextDueDate: newDate));
  }

  Future<bool> disableRecurringExpense(int id) async {
    final list = await _dao.getActiveRecurringExpenses();
    final item = list.firstWhere((e) => e.id == id);
    return _dao.updateRecurringExpense(item.copyWith(isActive: false));
  }

  RecurringExpenseEntity _mapToEntity(RecurringExpense model) {
    return RecurringExpenseEntity(
      id: model.id,
      title: model.title,
      amount: model.amount,
      categoryId: model.categoryId,
      frequency: model.frequency,
      nextDueDate: model.nextDueDate,
      autoLog: model.autoLog,
      isActive: model.isActive,
      createdAt: model.createdAt,
    );
  }
}
