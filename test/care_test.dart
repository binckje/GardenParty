import 'dart:convert';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_party/data/db/database.dart';
import 'package:garden_party/data/providers.dart';
import 'package:garden_party/features/calendar/calendar_screen.dart';
import 'package:garden_party/features/calendar/care_planner.dart';
import 'package:garden_party/features/calendar/care_service.dart';
import 'package:garden_party/features/calendar/ics_export.dart';
import 'package:garden_party/features/settings/demo_data.dart';
import 'package:garden_party/models/care.dart';
import 'package:garden_party/models/garden.dart';
import 'package:garden_party/models/plant.dart';
import 'package:garden_party/services/care_notifications.dart';
import 'package:garden_party/services/google/google_calendar_sync.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _species = PlantSpecies(
  id: 'sp',
  scientificName: 'Ocimum basilicum',
  commonName: 'Basilic',
  light: [LightLevel.fullSun],
  minTempC: 12,
  maxTempC: 35,
  soil: 'Terreau',
  watering: const CareSchedule(everyDays: 3, quantity: '200 ml', activeMonths: [6]),
  fertilizing: const CareSchedule(everyDays: 15, quantity: '1 bouchon', activeMonths: [6]),
);

final _plant = OwnedPlant(id: 'p1', speciesId: 'sp', nickname: 'Basilic');

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('planificateur', () {
    var n = 0;
    String id() => 't${n++}';

    test('première fois : arrosage et engrais prévus aujourd\'hui à 9 h', () {
      final now = DateTime(2026, 6, 10, 14);
      final t = missingTasks(plants: [_plant], species: {'sp': _species}, tasks: [], now: now, newId: id);
      expect(t.map((t) => t.type), CareType.values);
      expect(t.every((t) => t.dueAt == DateTime(2026, 6, 10, careHour)), isTrue);
    });

    test('après validation : intervalle normal en saison, doublé hors saison', () {
      final done = CareTask(id: 'a', plantId: 'p1', type: CareType.watering, dueAt: DateTime(2026, 6, 1), doneAt: DateTime(2026, 6, 2, 18));
      final pendingFert = CareTask(id: 'b', plantId: 'p1', type: CareType.fertilizing, dueAt: DateTime(2026, 6, 20));
      final t = missingTasks(
          plants: [_plant], species: {'sp': _species}, tasks: [done, pendingFert], now: DateTime(2026, 6, 3), newId: id);
      expect(t.single.type, CareType.watering);
      expect(t.single.dueAt, DateTime(2026, 6, 5, careHour));
      expect(nextDue(_species.watering, DateTime(2026, 1, 1)), DateTime(2026, 1, 7, careHour));
    });

    test('projection jusqu\'à la date limite', () {
      final pending = [CareTask(id: 'a', plantId: 'p1', type: CareType.watering, dueAt: DateTime(2026, 6, 1, 9))];
      final p = projection(pending: pending, speciesByPlant: {'p1': _species}, until: DateTime(2026, 6, 10));
      expect(p.map((c) => c.dueAt.day), [1, 4, 7]);
      expect(p.map((c) => c.key).toSet().length, 3);
    });
  });

  test('export ics : événements, échappement, lignes de 75 octets max', () {
    final ics = buildIcs(
      [PlannedCare(key: 'k1', plantId: 'p1', type: CareType.watering, dueAt: DateTime.utc(2026, 6, 1, 9))],
      plantName: (_) => 'Basilic, cuisine; ${'très long nom ' * 6}',
      now: DateTime.utc(2026, 5, 1),
    );
    expect(ics, startsWith('BEGIN:VCALENDAR\r\n'));
    expect(ics, contains('UID:k1@gardenparty\r\n'));
    expect(ics, contains('DTSTART:20260601T090000Z\r\n'));
    expect(ics, contains('Basilic\\, cuisine\\;'));
    expect(ics.split('\r\n').every((l) => utf8.encode(l).length <= 75), isTrue);
  });

  test('rappel : soins dus seulement, liste limitée', () {
    final now = DateTime(2026, 6, 10, 10);
    final tasks = [
      for (var i = 0; i < 7; i++) CareTask(id: 'd$i', plantId: 'p$i', type: CareType.watering, dueAt: DateTime(2026, 6, 9)),
      CareTask(id: 'later', plantId: 'px', type: CareType.watering, dueAt: DateTime(2026, 6, 12)),
    ];
    final s = dueSummary(tasks, (id) => 'Plante $id', now)!;
    expect(s.title, '7 soins à faire 🌱');
    expect(s.body.split('\n'), hasLength(6));
    expect(s.key.contains('later'), isFalse);
    expect(dueSummary(tasks.sublist(7), (id) => id, now), isNull);
  });

  test('identifiant d\'événement Google valide (base32hex) et stable', () {
    final id = eventIdFor('5f1c-Ab_é');
    expect(RegExp(r'^[a-v0-9]{5,1024}$').hasMatch(id), isTrue);
    expect(eventIdFor('5f1c-Ab_é'), id);
  });

  test('synchro Google : agenda créé, insertion, mise à jour si existe, suppression des soins faits', () async {
    final calls = <String>[];
    final api = gcal.CalendarApi(MockClient((req) async {
      calls.add('${req.method} ${req.url.path}');
      final json = {'content-type': 'application/json'};
      if (req.url.path.endsWith('/users/me/calendarList')) return http.Response('{"items": []}', 200, headers: json);
      if (req.method == 'POST' && req.url.path.endsWith('/calendars')) {
        return http.Response('{"id": "cal1"}', 200, headers: json);
      }
      if (req.method == 'POST' && req.url.path.endsWith('/events')) {
        final id = (jsonDecode(req.body) as Map)['id'];
        return id == eventIdFor('old')
            ? http.Response('{"error": {"code": 409, "message": "duplicate"}}', 409, headers: json)
            : http.Response(req.body, 200, headers: json);
      }
      if (req.method == 'PUT') return http.Response(req.body, 200, headers: json);
      if (req.method == 'DELETE') return http.Response('', 410);
      return http.Response('{}', 404, headers: json);
    }));
    final sync = GoogleCalendarSync(api);
    final cal = await sync.ensureCalendar(null);
    expect(cal, 'cal1');
    await sync.sync(
      calendarId: cal,
      pending: [
        CareTask(id: 'new', plantId: 'p1', type: CareType.watering, dueAt: DateTime(2026, 6, 1, 9)),
        CareTask(id: 'old', plantId: 'p1', type: CareType.fertilizing, dueAt: DateTime(2026, 6, 1, 9)),
      ],
      done: [CareTask(id: 'gone', plantId: 'p1', type: CareType.watering, dueAt: DateTime(2026, 5, 1), doneAt: DateTime(2026, 5, 1))],
      plantName: (_) => 'Basilic',
    );
    expect(calls.where((c) => c.startsWith('PUT')).single, endsWith('/events/${eventIdFor('old')}'));
    expect(calls.last, 'DELETE /calendar/v3/calendars/cal1/events/${eventIdFor('gone')}');
  });

  group('service et écran', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(overrides: [
        prefsProvider.overrideWithValue(prefs),
        // Pas de minuterie périodique dans les tests.
        clockProvider.overrideWith((ref) => Stream.value(DateTime.now())),
        databaseProvider.overrideWith((ref) {
          final db = AppDatabase(NativeDatabase.memory());
          ref.onDispose(db.close);
          return db;
        }),
      ]);
    });
    tearDown(() => container.dispose());

    test('valider un soin prévoit le suivant', () async {
      await addDemoPlants(container.read(plantRepositoryProvider));
      final care = container.read(careServiceProvider);
      expect(await care.ensureTasks(), 4);
      expect(await care.ensureTasks(), 0);
      final repo = container.read(careRepositoryProvider);
      final watering = (await repo.watchPending().first)
          .firstWhere((t) => t.plantId == 'demo-p2' && t.type == CareType.watering);
      final at = DateTime(2026, 7, 1, 8);
      await care.complete(watering, at: at);
      final next = (await repo.watchPending().first)
          .firstWhere((t) => t.plantId == 'demo-p2' && t.type == CareType.watering);
      expect(next.id, isNot(watering.id));
      expect(next.dueAt, DateTime(2026, 7, 3, careHour));
    });

    testWidgets('écran : soin en retard affiché puis validé', (tester) async {
      await tester.runAsync(() async {
        await container.read(plantRepositoryProvider).saveSpecies(_species);
        await container.read(plantRepositoryProvider).saveOwnedPlant(_plant);
        await container.read(careRepositoryProvider).saveTask(
            CareTask(id: 'late', plantId: 'p1', type: CareType.watering, dueAt: DateTime.now().subtract(const Duration(days: 3))));
      });
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: CalendarScreen()),
      ));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pump();
      expect(find.text('⚠️ En retard'), findsOneWidget);
      expect(find.textContaining('en retard de 3 j'), findsOneWidget);

      await tester.tap(find.text('Fait ✓'));
      // La validation démarre dans la zone de test : on alterne vraie attente et pump jusqu'à sa fin.
      final repo = container.read(careRepositoryProvider);
      for (var i = 0; i < 40; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
        await tester.pump();
        final pending = await tester.runAsync(() => repo.watchPending().first);
        if (pending!.length == 2 && i > 5) break;
      }
      expect(find.text('⚠️ En retard'), findsNothing);
      // Le basilic (engrais) et le nouvel arrosage sont à venir ou dus.
      expect(find.text('Basilic'), findsWidgets);

      // Laisse drift fermer ses flux avant la fin du test.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });
  });
}
