import 'package:drift/drift.dart';

import '../../models/garden.dart';
import '../db/database.dart';

/// Pièces/zones du plan avec leurs ouvertures et mesures de lumière.
class GardenRepository {
  GardenRepository(this._db);

  final AppDatabase _db;

  /// Plan complet, mis à jour à chaque changement d'une des trois tables.
  Stream<List<Space>> watchSpaces() async* {
    yield await getSpaces();
    final updates = _db.tableUpdates(TableUpdateQuery.onAllTables([_db.spaces, _db.openings, _db.lightReadings]));
    await for (final _ in updates) {
      yield await getSpaces();
    }
  }

  Future<List<Space>> getSpaces() async {
    final query = _db.select(_db.spaces)..orderBy([(s) => OrderingTerm.asc(s.name)]);
    return _withChildren(await query.get());
  }

  Future<List<Space>> _withChildren(List<SpaceRow> rows) async {
    final openings = await _db.select(_db.openings).get();
    final readings = await _db.select(_db.lightReadings).get();
    return [
      for (final r in rows)
        Space(
          id: r.id,
          name: r.name,
          kind: r.kind,
          x: r.x,
          y: r.y,
          width: r.width,
          height: r.height,
          openings: [
            for (final o in openings.where((o) => o.spaceId == r.id))
              Opening(id: o.id, kind: o.kind, wall: o.wall, offset: o.offset, length: o.length),
          ],
          lightReadings: [
            for (final l in readings.where((l) => l.spaceId == r.id))
              LightReading(
                id: l.id,
                x: l.x,
                y: l.y,
                moment: l.moment,
                estimatedLux: l.estimatedLux,
                takenAt: l.takenAt,
              ),
          ],
        ),
    ];
  }

  /// Insère ou remplace la pièce et synchronise ses ouvertures et mesures.
  Future<void> saveSpace(Space space) => _db.transaction(() async {
        await _db.into(_db.spaces).insertOnConflictUpdate(SpacesCompanion.insert(
              id: space.id,
              name: space.name,
              kind: space.kind,
              x: space.x,
              y: space.y,
              width: space.width,
              height: space.height,
            ));
        await (_db.delete(_db.openings)..where((o) => o.spaceId.equals(space.id))).go();
        await (_db.delete(_db.lightReadings)..where((l) => l.spaceId.equals(space.id))).go();
        await _db.batch((b) {
          b.insertAll(_db.openings, [
            for (final o in space.openings)
              OpeningsCompanion.insert(
                id: o.id,
                spaceId: space.id,
                kind: o.kind,
                wall: o.wall,
                offset: o.offset,
                length: o.length,
              ),
          ]);
          b.insertAll(_db.lightReadings, [
            for (final l in space.lightReadings)
              LightReadingsCompanion.insert(
                id: l.id,
                spaceId: space.id,
                x: l.x,
                y: l.y,
                moment: l.moment,
                estimatedLux: l.estimatedLux,
                takenAt: l.takenAt,
              ),
          ]);
        });
      });

  /// Supprime la pièce ; ouvertures et mesures suivent (cascade), les plantes deviennent non placées.
  Future<void> deleteSpace(String id) => (_db.delete(_db.spaces)..where((s) => s.id.equals(id))).go();
}
