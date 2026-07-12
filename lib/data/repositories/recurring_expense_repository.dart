import 'package:drift/drift.dart';
import '../../domain/entities/recurring_expense_entity.dart';
import '../daos/recurring_expense_dao.dart';
import '../database/app_database.dart';
import 'expense_repository.dart';
import '../../services/notification_service.dart';

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

  Future<void> processDueExpenses(
    DateTime now,
    ExpenseRepository expenseRepo,
    NotificationService notificationService,
  ) async {
    final dueItems = await getDueRecurringExpenses(now);
    for (final item in dueItems) {
      if (item.autoLog) {
        // Log the transaction
        await expenseRepo.create(
          amount: item.amount,
          categoryId: item.categoryId,
          description: item.title,
          date: now,
          type: 'debit',
        );

        // Notify user
        await notificationService.showNotification(
          id: item.id * 10,
          title: 'Recurring Expense Logged',
          body: '${item.title} of ${item.amount} was automatically added.',
        );
      } else {
        // Remind only
        await notificationService.showNotification(
          id: item.id * 10,
          title: 'Recurring Expense Due',
          body: '${item.title} of ${item.amount} is due today.',
        );
      }

      // Calculate next due date
      DateTime nextDue = item.nextDueDate;
      if (item.frequency == 'daily') {
        nextDue = nextDue.add(const Duration(days: 1));
      } else if (item.frequency == 'weekly') {
        nextDue = nextDue.add(const Duration(days: 7));
      } else if (item.frequency == 'monthly') {
        nextDue = DateTime(nextDue.year, nextDue.month + 1, nextDue.day);
      } else if (item.frequency == 'yearly') {
        nextDue = DateTime(nextDue.year + 1, nextDue.month, nextDue.day);
      }

      await updateNextDueDate(item.id, nextDue);
    }
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
