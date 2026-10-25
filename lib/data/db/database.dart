import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../models/care.dart';
import '../../models/garden.dart';
import '../../models/plant.dart';
import 'converters.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Spaces, Openings, LightReadings, PlantSpeciesTable, OwnedPlants, CareTasks, ApiCacheEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Base locale de l'appareil (fichier SQLite ; wasm + IndexedDB sur le web).
  factory AppDatabase.local() => AppDatabase(
        driftDatabase(
          name: 'garden_party',
          web: DriftWebOptions(sqlite3Wasm: Uri.parse('sqlite3.wasm'), driftWorker: Uri.parse('drift_worker.js')),
        ),
      );

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) await m.createTable(apiCacheEntries);
          if (from < 3) {
            for (final c in <GeneratedColumn>[
              plantSpeciesTable.sowingMonths,
              plantSpeciesTable.rowSpacingCm,
              plantSpeciesTable.plantSpacingCm,
              plantSpeciesTable.notes,
            ]) {
              await m.addColumn(plantSpeciesTable, c);
            }
          }
        },
        beforeOpen: (_) => customStatement('PRAGMA foreign_keys = ON'),
      );
}
