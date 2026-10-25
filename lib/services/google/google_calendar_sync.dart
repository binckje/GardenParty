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
  GoogleCalendarSync(this._api, {this.retryDelay = const Duration(seconds: 1)});

  final gcal.CalendarApi _api;

  /// Premier délai d'attente après un « Rate Limit Exceeded », doublé à chaque essai.
  final Duration retryDelay;

  static bool _rateLimited(gcal.DetailedApiRequestError e) =>
      e.status == 429 ||
      (e.status == 403 &&
          ((e.message ?? '').toLowerCase().contains('rate limit') ||
              e.errors.any((d) => (d.reason ?? '').toLowerCase().contains('ratelimit'))));

  /// Rejoue [call] avec attente exponentielle tant que Google renvoie une limite de débit.
  Future<T> _retry<T>(Future<T> Function() call) async {
    var delay = retryDelay;
    for (var attempt = 0;; attempt++) {
      try {
        return await call();
      } on gcal.DetailedApiRequestError catch (e) {
        if (!_rateLimited(e) || attempt >= 4) rethrow;
        await Future<void>.delayed(delay);
        delay *= 2;
      }
    }
  }

  /// Événements déjà présents dans l'agenda, indexés par id (une requête par page de 2500).
  Future<Map<String, gcal.Event>> _existing(String calendarId) async {
    final byId = <String, gcal.Event>{};
    String? page;
    do {
      final res = await _retry(() => _api.events.list(calendarId, maxResults: 2500, pageToken: page));
      for (final e in res.items ?? const <gcal.Event>[]) {
        if (e.id != null) byId[e.id!] = e;
      }
      page = res.nextPageToken;
    } while (page != null);
    return byId;
  }

  /// Agenda dédié : réutilise [knownId] s'il existe encore, sinon le crée. La portée
  /// `calendar.app.created` ne permet pas de lister les agendas : l'id est donc mémorisé par l'app.
  Future<String> ensureCalendar(String? knownId) async {
    if (knownId != null) {
      try {
        await _retry(() => _api.calendars.get(knownId));
        return knownId;
      } on gcal.DetailedApiRequestError catch (e) {
        // 404 : agenda supprimé ; 403 (hors limite de débit) : agenda d'un autre compte Google.
        if (e.status != 404 && (e.status != 403 || _rateLimited(e))) rethrow;
      }
    }
    final created = await _retry(() => _api.calendars.insert(gcal.Calendar(summary: _calendarName, timeZone: 'Europe/Paris')));
    return created.id!;
  }

  /// Crée ou met à jour les tâches en attente ; retire de l'agenda celles validées.
  /// Seuls les événements absents ou modifiés sont envoyés, pour rester sous les quotas Google.
  Future<void> sync({
    required String calendarId,
    required List<CareTask> pending,
    required List<CareTask> done,
    required String Function(String plantId) plantName,
  }) async {
    final existing = await _existing(calendarId);
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
      final current = existing[event.id];
      if (current == null) {
        try {
          await _retry(() => _api.events.insert(event, calendarId));
        } on gcal.DetailedApiRequestError catch (e) {
          // 409 : événement supprimé (annulé) ou hors de la liste : on le remplace.
          if (e.status != 409) rethrow;
          await _retry(() => _api.events.update(event, calendarId, event.id!));
        }
      } else if (current.summary != event.summary ||
          current.status == 'cancelled' ||
          current.start?.dateTime?.toUtc() != event.start!.dateTime) {
        await _retry(() => _api.events.update(event, calendarId, event.id!));
      }
    }
    for (final t in done) {
      if (!existing.containsKey(eventIdFor(t.id))) continue;
      try {
        await _retry(() => _api.events.delete(calendarId, eventIdFor(t.id)));
      } on gcal.DetailedApiRequestError catch (e) {
        // Déjà supprimé, ou jamais synchronisé.
        if (e.status != 404 && e.status != 410) rethrow;
      }
    }
  }
}
