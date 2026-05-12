import 'package:drift/drift.dart';

class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  // First day of the budget period (month start).
  DateTimeColumn get periodStart => dateTime()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}
