import 'package:drift/drift.dart';
import 'categories_table.dart';
import 'expenses_table.dart';

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  // 'low' | 'medium' | 'high'
  TextColumn get importance => text().withDefault(const Constant('medium'))();
  DateTimeColumn get scheduledAt => dateTime()();
  // Minutes before scheduledAt to fire the reminder notification.
  // null = no reminder.
  IntColumn get reminderMinutes => integer().nullable()();
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
  // 'none' | 'daily' | 'weekly' | 'monthly' | 'yearly'
  TextColumn get recurrenceType => text().withDefault(const Constant('none'))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  // When true, marking this task done auto-creates an expense record.
  BoolColumn get isPlannedExpense => boolean().withDefault(const Constant(false))();
  // FK to the expense created when this task was marked done.
  IntColumn get linkedExpenseId => integer().nullable().references(Expenses, #id)();
  RealColumn get estimatedAmount => real().nullable()();
  IntColumn get categoryId => integer().nullable().references(Categories, #id)();
  // Notification ID stored so we can cancel it if the task is deleted/edited.
  IntColumn get notificationId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
