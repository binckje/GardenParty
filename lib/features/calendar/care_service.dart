import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../data/providers.dart';
import '../../models/care.dart';
import '../../models/plant.dart';
import '../../services/care_notifications.dart';
import '../../services/google/google_auth.dart';
import '../../services/google/google_calendar_sync.dart';
import 'care_planner.dart';
import 'ics_export.dart';

/// Préférences locales ; chargées dans `main()` puis injectées par override.
final prefsProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError('prefsProvider non initialisé'));

final notificationsProvider = Provider((ref) => CareNotifications(ref.watch(prefsProvider)));
final googleAuthProvider = Provider((ref) => GoogleAuth.create(ref.watch(prefsProvider)));
final careServiceProvider = Provider(CareService.new);

/// Heure courante, rafraîchie chaque minute : les retards apparaissent sans action.
final clockProvider = StreamProvider<DateTime>(
    (ref) => Stream.periodic(const Duration(minutes: 1), (_) => DateTime.now()).startWith(DateTime.now()));

extension<T> on Stream<T> {
  Stream<T> startWith(T first) async* {
    yield first;
    yield* this;
  }
}

const _calendarIdKey = 'google.calendarId';
const _lastSyncKey = 'google.lastSync';

class GoogleSyncState {
  const GoogleSyncState({this.connected = false, this.busy = false, this.lastSync, this.error});

  final bool connected, busy;
  final DateTime? lastSync;
  final String? error;
}

final googleSyncProvider = NotifierProvider<GoogleSyncNotifier, GoogleSyncState>(GoogleSyncNotifier.new);

class GoogleSyncNotifier extends Notifier<GoogleSyncState> {
  @override
  GoogleSyncState build() {
    final prefs = ref.watch(prefsProvider);
    final last = prefs.getString(_lastSyncKey);
    return GoogleSyncState(connected: prefs.getString(_calendarIdKey) != null, lastSync: last == null ? null : DateTime.parse(last));
  }

  /// [interactive] : ouvre le consentement Google si besoin (bouton « Connecter »).
  Future<void> sync({bool interactive = false}) async {
    if (!googleConfigured || state.busy) return;
    if (!interactive && !state.connected) return;
    state = GoogleSyncState(connected: state.connected, busy: true, lastSync: state.lastSync);
    try {
      final client = await ref.read(googleAuthProvider).client(interactive: interactive);
      if (client == null) {
        state = GoogleSyncState(connected: state.connected, lastSync: state.lastSync);
        return;
      }
      final prefs = ref.read(prefsProvider);
      final sync = GoogleCalendarSync(gcal.CalendarApi(client));
      final calendarId = await sync.ensureCalendar(prefs.getString(_calendarIdKey));
      await prefs.setString(_calendarIdKey, calendarId);
      final data = await ref.read(careServiceProvider).snapshot();
      final since = state.lastSync;
      final now = DateTime.now();
      await sync.sync(
        calendarId: calendarId,
        pending: data.tasks.where((t) => !t.isDone).toList(),
        done: since == null ? const [] : data.tasks.where((t) => t.isDone && t.doneAt!.isAfter(since)).toList(),
        plantName: data.plantName,
      );
      await prefs.setString(_lastSyncKey, now.toIso8601String());
      state = GoogleSyncState(connected: true, lastSync: now);
    } catch (e) {
      debugPrint('Synchro Google : $e');
      state = GoogleSyncState(connected: state.connected, lastSync: state.lastSync, error: '$e');
    }
  }

  Future<void> disconnect() async {
    await ref.read(googleAuthProvider).signOut();
    final prefs = ref.read(prefsProvider);
    await prefs.remove(_calendarIdKey);
    await prefs.remove(_lastSyncKey);
    state = const GoogleSyncState();
  }
}

/// Plantes, espèces et tâches lues d'un coup.
class CareSnapshot {
  CareSnapshot(this.plants, this.species, this.tasks);

  final Map<String, String> plants;
  final Map<String, PlantSpecies> species;
  final List<CareTask> tasks;

  String plantName(String plantId) => plants[plantId] ?? 'Plante';
}

/// Génération des tâches, validation, alertes et export.
class CareService {
  CareService(this._ref);

  final Ref _ref;

  Future<CareSnapshot> snapshot() async {
    final plants = await _ref.read(plantRepositoryProvider).watchOwnedPlants().first;
    final species = await _ref.read(plantRepositoryProvider).watchSpecies().first;
    final tasks = await _ref.read(careRepositoryProvider).watchTasks().first;
    final byId = {for (final s in species) s.id: s};
    return CareSnapshot(
      {for (final p in plants) p.id: p.nickname},
      {for (final p in plants) if (byId[p.speciesId] != null) p.id: byId[p.speciesId]!},
      tasks,
    );
  }

  /// Crée les tâches manquantes (nouvelle plante, soin validé) ; renvoie leur nombre.
  Future<int> ensureTasks({DateTime? now}) async {
    final plants = await _ref.read(plantRepositoryProvider).watchOwnedPlants().first;
    final species = await _ref.read(plantRepositoryProvider).watchSpecies().first;
    final repo = _ref.read(careRepositoryProvider);
    final created = missingTasks(
      plants: plants,
      species: {for (final s in species) s.id: s},
      tasks: await repo.watchTasks().first,
      now: now ?? DateTime.now(),
      newId: const Uuid().v4,
    );
    for (final t in created) {
      await repo.saveTask(t);
    }
    return created.length;
  }

  /// Valide un soin, prévoit le suivant et met à jour Google Agenda si connecté.
  Future<void> complete(CareTask t, {DateTime? at}) async {
    final when = at ?? DateTime.now();
    await _ref.read(careRepositoryProvider).markDone(t.id, when);
    await ensureTasks(now: when);
    await refreshAlerts();
    unawaited(_ref.read(googleSyncProvider.notifier).sync());
  }

  Future<void> refreshAlerts() async {
    final data = await snapshot();
    await _ref.read(notificationsProvider).refresh(data.tasks.where((t) => !t.isDone).toList(), data.plantName, DateTime.now());
  }

  /// Agenda .ics des 90 prochains jours.
  Future<String> buildIcsExport() async {
    final data = await snapshot();
    final now = DateTime.now();
    final items = projection(
      pending: data.tasks.where((t) => !t.isDone).toList(),
      speciesByPlant: data.species,
      until: now.add(const Duration(days: 90)),
    );
    return buildIcs(items, plantName: data.plantName, now: now);
  }
}
