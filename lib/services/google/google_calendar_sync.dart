import 'dart:convert';

import 'package:googleapis/calendar/v3.dart' as gcal;

import '../../features/calendar/care_planner.dart';
import '../../models/care.dart';

/// Accès limité aux agendas créés par l'app : rien d'autre dans le compte Google n'est lisible.
const googleCalendarScopes = [gcal.CalendarApi.calendarAppCreatedScope];

const _calendarName = 'GardenParty 🌱';

/// Identifiant d'événement Google (base32hex) déduit de l'id de tâche : rejouer la synchro ne crée pas de doublon.
String eventIdFor(String taskId) => 'gp${utf8.encode(taskId).map((b) => b.toRadixString(16).padLeft(2, '0')).join()}';

/// Pousse les soins vers un agenda « GardenParty » dédié du compte Google.
class GoogleCalendarSync {
  GoogleCalendarSync(this._api);

  final gcal.CalendarApi _api;

  /// Agenda dédié : réutilise [knownId] s'il existe encore, sinon le crée. La portée
  /// `calendar.app.created` ne permet pas de lister les agendas : l'id est donc mémorisé par l'app.
  Future<String> ensureCalendar(String? knownId) async {
    if (knownId != null) {
      try {
        await _api.calendars.get(knownId);
        return knownId;
      } on gcal.DetailedApiRequestError catch (e) {
        // 404 : agenda supprimé ; 403 : agenda d'un autre compte Google.
        if (e.status != 404 && e.status != 403) rethrow;
      }
    }
    final created = await _api.calendars.insert(gcal.Calendar(summary: _calendarName, timeZone: 'Europe/Paris'));
    return created.id!;
  }

  /// Crée ou met à jour les tâches en attente ; retire de l'agenda celles validées.
  Future<void> sync({
    required String calendarId,
    required List<CareTask> pending,
    required List<CareTask> done,
    required String Function(String plantId) plantName,
  }) async {
    for (final t in pending) {
      final title = '${careEmoji(t.type)} ${careLabel(t.type)} : ${plantName(t.plantId)}';
      final event = gcal.Event(
        id: eventIdFor(t.id),
        summary: title,
        description: 'À valider dans GardenParty.',
        start: gcal.EventDateTime(dateTime: t.dueAt.toUtc()),
        end: gcal.EventDateTime(dateTime: t.dueAt.add(const Duration(minutes: 15)).toUtc()),
        reminders: gcal.EventReminders(useDefault: false, overrides: [gcal.EventReminder(method: 'popup', minutes: 0)]),
      );
      try {
        await _api.events.insert(event, calendarId);
      } on gcal.DetailedApiRequestError catch (e) {
        if (e.status != 409) rethrow;
        await _api.events.update(event, calendarId, event.id!);
      }
    }
    for (final t in done) {
      try {
        await _api.events.delete(calendarId, eventIdFor(t.id));
      } on gcal.DetailedApiRequestError catch (e) {
        // Déjà supprimé, ou jamais synchronisé.
        if (e.status != 404 && e.status != 410) rethrow;
      }
    }
  }
}
