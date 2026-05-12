import 'package:drift/drift.dart';

/// Simple key-value store for user preferences (currency, theme, etc.)
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
