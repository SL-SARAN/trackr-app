import 'package:drift/drift.dart';
import 'categories_table.dart';

class RecurringExpenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  RealColumn get amount => real()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  // 'daily', 'weekly', 'monthly', 'yearly'
  TextColumn get frequency => text()();
  DateTimeColumn get nextDueDate => dateTime()();
  BoolColumn get autoLog => boolean().withDefault(const Constant(true))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
