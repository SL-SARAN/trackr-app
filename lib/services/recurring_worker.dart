import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import '../core/di/injection.dart';
import '../data/repositories/expense_repository.dart';
import '../data/repositories/recurring_expense_repository.dart';
import '../services/notification_service.dart';

const String recurringTaskName = 'checkRecurringExpenses';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('Native called background task: \$task');

    if (task == recurringTaskName) {
      try {
        // We need to initialize dependencies in the background isolate
        await initDependencies(); // Make sure this is safe to call here (no UI dependencies)
        
        final recurringRepo = sl<RecurringExpenseRepository>();
        final expenseRepo = sl<ExpenseRepository>();
        final notificationService = sl<NotificationService>();

        final now = DateTime.now();
        await recurringRepo.processDueExpenses(now, expenseRepo, notificationService);
      } catch (e) {
        debugPrint('Background task error: $e');
        return Future.value(false);
      }
    }

    return Future.value(true);
  });
}
