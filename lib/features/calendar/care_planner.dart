import '../../models/care.dart';
import '../../models/plant.dart';

/// Heure à laquelle un soin est prévu dans la journée.
const careHour = 9;

CareSchedule scheduleFor(PlantSpecies s, CareType type) => switch (type) {
      CareType.watering => s.watering,
      CareType.fertilizing => s.fertilizing,
    };

/// Échéance suivante après [from] : l'intervalle double hors saison.
DateTime nextDue(CareSchedule s, DateTime from) {
  final days = s.activeMonths.contains(from.month) ? s.everyDays : s.everyDays * 2;
  final d = from.add(Duration(days: days));
  return DateTime(d.year, d.month, d.day, careHour);
}

/// Tâches à créer pour que chaque plante ait un arrosage et un engrais en attente.
/// Première fois : prévu aujourd'hui. Sinon : après la dernière validation.
List<CareTask> missingTasks({
  required List<OwnedPlant> plants,
  required Map<String, PlantSpecies> species,
  required List<CareTask> tasks,
  required DateTime now,
  required String Function() newId,
}) {
  final created = <CareTask>[];
  for (final p in plants) {
    final sp = species[p.speciesId];
    if (sp == null) continue;
    for (final type in CareType.values) {
      final mine = tasks.where((t) => t.plantId == p.id && t.type == type);
      if (mine.any((t) => !t.isDone)) continue;
      final last = mine.map((t) => t.doneAt!).fold<DateTime?>(null, (a, b) => a == null || b.isAfter(a) ? b : a);
      final due = last == null ? DateTime(now.year, now.month, now.day, careHour) : nextDue(scheduleFor(sp, type), last);
      created.add(CareTask(id: newId(), plantId: p.id, type: type, dueAt: due));
    }
  }
  return created;
}

/// Occurrence prévue (non enregistrée), pour l'export d'agenda.
class PlannedCare {
  const PlannedCare({required this.key, required this.plantId, required this.type, required this.dueAt});

  final String key;
  final String plantId;
  final CareType type;
  final DateTime dueAt;
}

/// Prévisions jusqu'à [until] à partir des tâches en attente, en supposant chaque soin fait à l'heure.
List<PlannedCare> projection({
  required List<CareTask> pending,
  required Map<String, PlantSpecies> speciesByPlant,
  required DateTime until,
}) {
  final out = <PlannedCare>[];
  for (final t in pending) {
    final sp = speciesByPlant[t.plantId];
    var due = t.dueAt;
    var n = 0;
    while (!due.isAfter(until)) {
      out.add(PlannedCare(key: '${t.id}-$n', plantId: t.plantId, type: t.type, dueAt: due));
      if (sp == null) break;
      due = nextDue(scheduleFor(sp, t.type), due);
      n++;
    }
  }
  out.sort((a, b) => a.dueAt.compareTo(b.dueAt));
  return out;
}

String careLabel(CareType t) => switch (t) {
      CareType.watering => 'Arrosage',
      CareType.fertilizing => 'Engrais',
    };

String careEmoji(CareType t) => switch (t) {
      CareType.watering => '💧',
      CareType.fertilizing => '🌿',
    };
