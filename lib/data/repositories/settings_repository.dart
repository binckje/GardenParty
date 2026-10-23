import '../db/database.dart';

/// Réglages clé/valeur.
class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  Future<double?> getDouble(String key) async {
    final row = await (_db.select(_db.settings)..where((s) => s.key.equals(key))).getSingleOrNull();
    return row == null ? null : double.tryParse(row.value);
  }

  Future<void> setDouble(String key, double value) =>
      _db.into(_db.settings).insertOnConflictUpdate(SettingsCompanion.insert(key: key, value: value.toString()));
}
