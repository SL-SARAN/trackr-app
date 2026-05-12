import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/tables/settings_table.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [AppSettings])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<String?> get(String key) async {
    final row = await (select(appSettings)
          ..where((s) => s.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Stream<String?> watch(String key) =>
      (select(appSettings)..where((s) => s.key.equals(key)))
          .watchSingleOrNull()
          .map((row) => row?.value);

  Future<void> set(String key, String value) =>
      into(appSettings).insertOnConflictUpdate(
        AppSettingsCompanion.insert(key: key, value: value),
      );

  Future<void> remove(String key) =>
      (delete(appSettings)..where((s) => s.key.equals(key))).go();
}
