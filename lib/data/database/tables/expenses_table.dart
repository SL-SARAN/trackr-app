import 'package:drift/drift.dart';
import 'categories_table.dart';

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  // Optional note — e.g. "Lunch with team"
  TextColumn get description => text().nullable()();
  // Full datetime of the expense (date + time combined)
  DateTimeColumn get date => dateTime()();
  // Stored string: 'morning' | 'noon' | 'evening' | 'night'
  // Computed from `date` at insert time so queries can filter by it directly.
  TextColumn get timeOfDayTag => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  // 'debit' or 'credit'
  TextColumn get type => text().withDefault(const Constant('debit'))();
}
