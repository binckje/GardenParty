import 'package:drift/drift.dart';

import '../../models/plant.dart';
import '../db/database.dart';

/// Fiches espèces (cache local) et plantes possédées.
class PlantRepository {
  PlantRepository(this._db);

  final AppDatabase _db;

  Stream<List<PlantSpecies>> watchSpecies() {
    final query = _db.select(_db.plantSpeciesTable)..orderBy([(s) => OrderingTerm.asc(s.commonName)]);
    return query.map(_species).watch();
  }

  Future<PlantSpecies?> getSpecies(String id) =>
      (_db.select(_db.plantSpeciesTable)..where((s) => s.id.equals(id))).map(_species).getSingleOrNull();

  /// Fiches dont le visuel est encore une adresse web (photo pas encore gardée hors ligne).
  Future<List<PlantSpecies>> speciesWithWebImage() =>
      (_db.select(_db.plantSpeciesTable)..where((s) => s.imageUrl.like('http%'))).map(_species).get();

  Future<void> saveSpecies(PlantSpecies s) => _db.into(_db.plantSpeciesTable).insertOnConflictUpdate(_speciesRow(s));

  /// Ajoute les espèces absentes sans écraser celles déjà en base (catalogue relu à chaque lancement).
  Future<void> addMissingSpecies(List<PlantSpecies> species) => _db.batch(
        (b) => b.insertAll(_db.plantSpeciesTable, species.map(_speciesRow), mode: InsertMode.insertOrIgnore),
      );

  PlantSpeciesTableCompanion _speciesRow(PlantSpecies s) => PlantSpeciesTableCompanion.insert(
        id: s.id,
        scientificName: s.scientificName,
        commonName: s.commonName,
        imageUrl: Value(s.imageUrl),
        light: s.light,
        minTempC: s.minTempC,
        maxTempC: s.maxTempC,
        soil: s.soil,
        watering: s.watering,
        fertilizing: s.fertilizing,
        diagnostics: s.diagnostics,
        cutting: Value(s.cutting),
        repotting: Value(s.repotting),
      );

  Stream<List<OwnedPlant>> watchOwnedPlants() {
    final query = _db.select(_db.ownedPlants)..orderBy([(p) => OrderingTerm.asc(p.nickname)]);
    return query.map(_owned).watch();
  }

  Future<void> saveOwnedPlant(OwnedPlant p) => _db.into(_db.ownedPlants).insertOnConflictUpdate(
        OwnedPlantsCompanion.insert(
          id: p.id,
          speciesId: p.speciesId,
          nickname: p.nickname,
          spaceId: Value(p.spaceId),
          x: Value(p.x),
          y: Value(p.y),
        ),
      );

  /// Supprime la plante et ses tâches d'entretien (cascade).
  Future<void> deleteOwnedPlant(String id) => (_db.delete(_db.ownedPlants)..where((p) => p.id.equals(id))).go();

  PlantSpecies _species(PlantSpeciesRow r) => PlantSpecies(
        id: r.id,
        scientificName: r.scientificName,
        commonName: r.commonName,
        imageUrl: r.imageUrl,
        light: r.light,
        minTempC: r.minTempC,
        maxTempC: r.maxTempC,
        soil: r.soil,
        watering: r.watering,
        fertilizing: r.fertilizing,
        diagnostics: r.diagnostics,
        cutting: r.cutting,
        repotting: r.repotting,
      );

  OwnedPlant _owned(OwnedPlantRow r) =>
      OwnedPlant(id: r.id, speciesId: r.speciesId, nickname: r.nickname, spaceId: r.spaceId, x: r.x, y: r.y);
}
