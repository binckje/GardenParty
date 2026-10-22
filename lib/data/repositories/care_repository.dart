import 'package:drift/drift.dart';

import '../../models/care.dart';
import '../db/database.dart';

/// Tâches d'entretien (arrosage, engrais).
class CareRepository {
  CareRepository(this._db);

  final AppDatabase _db;

  Stream<List<CareTask>> watchTasks({String? plantId}) {
    final query = _db.select(_db.careTasks)..orderBy([(t) => OrderingTerm.asc(t.dueAt)]);
    if (plantId != null) query.where((t) => t.plantId.equals(plantId));
    return query.map(_task).watch();
  }

  /// Tâches non validées, y compris celles en retard.
  Stream<List<CareTask>> watchPending() {
    final query = _db.select(_db.careTasks)
      ..where((t) => t.doneAt.isNull())
      ..orderBy([(t) => OrderingTerm.asc(t.dueAt)]);
    return query.map(_task).watch();
  }

  Future<void> saveTask(CareTask t) => _db.into(_db.careTasks).insertOnConflictUpdate(
        CareTasksCompanion.insert(id: t.id, plantId: t.plantId, type: t.type, dueAt: t.dueAt, doneAt: Value(t.doneAt)),
      );

  Future<void> markDone(String id, DateTime at) =>
      (_db.update(_db.careTasks)..where((t) => t.id.equals(id))).write(CareTasksCompanion(doneAt: Value(at)));

  Future<void> deleteTask(String id) => (_db.delete(_db.careTasks)..where((t) => t.id.equals(id))).go();

  CareTask _task(CareTaskRow r) => CareTask(id: r.id, plantId: r.plantId, type: r.type, dueAt: r.dueAt, doneAt: r.doneAt);
}
