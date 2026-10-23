import 'package:drift/drift.dart';

import '../../models/care.dart';
import '../../models/garden.dart';
import 'converters.dart';

/// Les enums sont stockés par leur nom (textEnum) : réordonner un enum ne casse pas la base.
/// Les classes de ligne sont suffixées `Row` pour ne pas masquer les modèles métier.

@DataClassName('SpaceRow')
class Spaces extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get kind => textEnum<SpaceKind>()();
  RealColumn get x => real()();
  RealColumn get y => real()();
  RealColumn get width => real()();
  RealColumn get height => real()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('OpeningRow')
class Openings extends Table {
  TextColumn get id => text()();
  TextColumn get spaceId => text().references(Spaces, #id, onDelete: KeyAction.cascade)();
  TextColumn get kind => textEnum<OpeningKind>()();
  IntColumn get wall => integer()();
  RealColumn get offset => real()();
  RealColumn get length => real()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('LightReadingRow')
class LightReadings extends Table {
  TextColumn get id => text()();
  TextColumn get spaceId => text().references(Spaces, #id, onDelete: KeyAction.cascade)();
  RealColumn get x => real()();
  RealColumn get y => real()();
  TextColumn get moment => textEnum<DayMoment>()();
  RealColumn get estimatedLux => real()();
  DateTimeColumn get takenAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Fiche espèce : les sous-objets (programmes de soin, diagnostics…) sont stockés en JSON.
@DataClassName('PlantSpeciesRow')
class PlantSpeciesTable extends Table {
  @override
  String get tableName => 'plant_species';

  TextColumn get id => text()();
  TextColumn get scientificName => text()();
  TextColumn get commonName => text()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get light => text().map(const LightLevelsConverter())();
  RealColumn get minTempC => real()();
  RealColumn get maxTempC => real()();
  TextColumn get soil => text()();
  TextColumn get watering => text().map(const CareScheduleConverter())();
  TextColumn get fertilizing => text().map(const CareScheduleConverter())();
  TextColumn get diagnostics => text().map(const DiagnosticsConverter())();
  TextColumn get cutting => text().map(const PropagationConverter()).nullable()();
  TextColumn get repotting => text().map(const RepottingConverter()).nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('OwnedPlantRow')
class OwnedPlants extends Table {
  TextColumn get id => text()();
  TextColumn get speciesId => text().references(PlantSpeciesTable, #id)();
  TextColumn get nickname => text()();
  // Retirer une pièce du plan laisse la plante « non placée ».
  TextColumn get spaceId => text().nullable().references(Spaces, #id, onDelete: KeyAction.setNull)();
  RealColumn get x => real().nullable()();
  RealColumn get y => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CareTaskRow')
class CareTasks extends Table {
  TextColumn get id => text()();
  TextColumn get plantId => text().references(OwnedPlants, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => textEnum<CareType>()();
  DateTimeColumn get dueAt => dateTime()();
  DateTimeColumn get doneAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
