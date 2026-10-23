import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../models/care.dart';
import '../../models/garden.dart';
import '../../models/plant.dart';
import 'converters.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Spaces, Openings, LightReadings, PlantSpeciesTable, OwnedPlants, CareTasks])
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
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (_) => customStatement('PRAGMA foreign_keys = ON'),
      );
}
