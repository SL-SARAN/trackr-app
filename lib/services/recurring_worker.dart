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
        final dueItems = await recurringRepo.getDueRecurringExpenses(now);

        for (final item in dueItems) {
          if (item.autoLog) {
            // Log it automatically
            await expenseRepo.create(
              amount: item.amount,
              categoryId: item.categoryId,
              description: item.title,
              date: now,
              type: 'debit', // Currently recurring items are expenses
            );
            
            // Notify user it was logged
            await notificationService.showNotification(
              id: item.id * 10,
              title: 'Recurring Expense Logged',
              body: '\${item.title} of \${item.amount} was automatically added.',
            );
          } else {
            // Remind only
            await notificationService.showNotification(
              id: item.id * 10,
              title: 'Recurring Expense Due',
              body: '\${item.title} of \${item.amount} is due today.',
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
          
          await recurringRepo.updateNextDueDate(item.id, nextDue);
        }
      } catch (e) {
        debugPrint('Background task error: \$e');
        return Future.value(false);
      }
    }

    return Future.value(true);
  });
}
