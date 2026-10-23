import 'dart:convert';

import 'package:drift/drift.dart';

import 'db/database.dart';

/// Erreur de lecture d'une sauvegarde (fichier invalide ou trop récent).
class BackupException implements Exception {
  BackupException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Sauvegarde complète de la base au format JSON (lignes SQL brutes, table par table).
///
/// Indépendant des modèles : une nouvelle colonne est exportée sans changer ce code.
class BackupService {
  BackupService(this._db);

  static const app = 'garden_party';
  static const format = 1;

  final AppDatabase _db;

  /// Données de l'utilisateur, parents avant enfants (clés étrangères) : ordre d'insertion ;
  /// l'inverse sert à l'effacement. Le cache des API n'est pas sauvegardé.
  List<TableInfo> get _tables => [
        _db.spaces,
        _db.openings,
        _db.lightReadings,
        _db.plantSpeciesTable,
        _db.ownedPlants,
        _db.careTasks,
      ];

  Future<String> exportJson({DateTime? now}) async {
    final tables = <String, List<Map<String, Object?>>>{};
    for (final t in _tables) {
      final rows = await _db.customSelect('SELECT * FROM "${t.actualTableName}"', readsFrom: {t}).get();
      tables[t.actualTableName] = [for (final r in rows) r.data];
    }
    return const JsonEncoder.withIndent(' ').convert({
      'app': app,
      'format': format,
      'schemaVersion': _db.schemaVersion,
      'exportedAt': (now ?? DateTime.now()).toIso8601String(),
      'tables': tables,
    });
  }

  /// Remplace tout le contenu de la base par celui de la sauvegarde. Rien n'est modifié en cas d'erreur.
  Future<void> importJson(String source) async {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException {
      throw BackupException('Fichier illisible (JSON invalide).');
    }
    if (decoded is! Map || decoded['app'] != app || decoded['tables'] is! Map) {
      throw BackupException('Ce fichier n\'est pas une sauvegarde GardenParty.');
    }
    final version = decoded['schemaVersion'];
    if (decoded['format'] != format || version is! int || version > _db.schemaVersion) {
      throw BackupException('Sauvegarde créée par une version plus récente de l\'application.');
    }
    final tables = decoded['tables'] as Map;

    await _db.transaction(() async {
      for (final t in _tables.reversed) {
        await _db.delete(t).go();
      }
      for (final t in _tables) {
        final rows = tables[t.actualTableName];
        if (rows == null) continue;
        if (rows is! List) throw BackupException('Table ${t.actualTableName} invalide.');
        // Seules les colonnes connues sont reprises : les noms ne viennent jamais du fichier.
        final columns = {for (final c in t.$columns) c.name};
        for (final row in rows) {
          if (row is! Map) throw BackupException('Ligne invalide dans ${t.actualTableName}.');
          final names = [for (final k in row.keys) if (columns.contains(k)) k as String];
          if (names.isEmpty) continue;
          await _db.customInsert(
            'INSERT INTO "${t.actualTableName}" (${names.map((n) => '"$n"').join(', ')}) '
            'VALUES (${List.filled(names.length, '?').join(', ')})',
            variables: [for (final n in names) Variable<Object>(row[n] as Object?)],
            updates: {t},
          );
        }
      }
    });
  }
}
