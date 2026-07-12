import 'package:drift/drift.dart';

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  IntColumn get colorValue => integer()();
  // null = no per-category limit set by user
  RealColumn get budgetLimit => real().nullable()();
  // true = system seed (Food, Travel, Entertainment) — blocks deletion
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
  // user-defined display order; lower = appears first
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get type => text().withDefault(const Constant('debit'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
