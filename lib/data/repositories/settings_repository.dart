import '../daos/settings_dao.dart';

class SettingsRepository {
  final SettingsDao _dao;

  SettingsRepository(this._dao);

  Future<String?> get(String key) => _dao.get(key);

  Stream<String?> watch(String key) => _dao.watch(key);

  Future<void> set(String key, String value) => _dao.set(key, value);

  Future<void> remove(String key) => _dao.remove(key);
}
