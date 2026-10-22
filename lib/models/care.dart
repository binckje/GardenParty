enum CareType { watering, fertilizing }

/// Soin à faire ; reste en retard (alerte) tant qu'il n'est pas validé.
class CareTask {
  CareTask({required this.id, required this.plantId, required this.type, required this.dueAt, this.doneAt});

  final String id;
  final String plantId;
  final CareType type;
  final DateTime dueAt;
  DateTime? doneAt;

  bool get isDone => doneAt != null;
  bool isOverdue(DateTime now) => !isDone && now.isAfter(dueAt);
}
