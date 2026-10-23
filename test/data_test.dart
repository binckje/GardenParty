import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_party/data/db/database.dart';
import 'package:garden_party/data/providers.dart';
import 'package:garden_party/models/care.dart';
import 'package:garden_party/models/garden.dart';
import 'package:garden_party/models/plant.dart';

PlantSpecies _monstera() => PlantSpecies(
      id: 'monstera',
      scientificName: 'Monstera deliciosa',
      commonName: 'Monstera',
      light: [LightLevel.brightIndirect, LightLevel.partialSun],
      minTempC: 15,
      maxTempC: 30,
      soil: 'Terreau drainant',
      watering: const CareSchedule(everyDays: 7, quantity: '500 ml'),
      fertilizing: const CareSchedule(everyDays: 30, quantity: '1 bouchon', activeMonths: [4, 5, 6]),
      diagnostics: const [Diagnostic(symptom: 'Feuilles jaunes', cause: 'Excès d\'eau', treatment: 'Espacer')],
      cutting: const PropagationInfo(possible: true, method: 'Bouture de tige avec nœud'),
    );

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(overrides: [
      databaseProvider.overrideWith((ref) {
        final db = AppDatabase(NativeDatabase.memory());
        ref.onDispose(db.close);
        return db;
      }),
    ]);
  });
  tearDown(() => container.dispose());

  test('pièce sauvegardée avec ouvertures et mesures', () async {
    final repo = container.read(gardenRepositoryProvider);
    await repo.saveSpace(Space(
      id: 's1',
      name: 'Salon',
      kind: SpaceKind.indoorRoom,
      x: 0,
      y: 0,
      width: 5,
      height: 4,
      openings: [Opening(id: 'o1', kind: OpeningKind.window, wall: 1, offset: 1, length: 1.2)],
      lightReadings: [
        LightReading(id: 'l1', x: 1, y: 1, moment: DayMoment.noon, estimatedLux: 3000, takenAt: DateTime(2026, 5, 1)),
      ],
    ));

    final spaces = await repo.getSpaces();
    expect(spaces.single.name, 'Salon');
    expect(spaces.single.openings.single.kind, OpeningKind.window);
    expect(spaces.single.lightReadings.single.level, LightLevel.brightIndirect);
    expect(spaces.single.lightReadings.single.takenAt, DateTime(2026, 5, 1));
  });

  test('espèce : sous-objets JSON relus à l\'identique', () async {
    final repo = container.read(plantRepositoryProvider);
    await repo.saveSpecies(_monstera());

    final s = (await repo.getSpecies('monstera'))!;
    expect(s.light, [LightLevel.brightIndirect, LightLevel.partialSun]);
    expect(s.fertilizing.activeMonths, [4, 5, 6]);
    expect(s.diagnostics.single.symptom, 'Feuilles jaunes');
    expect(s.cutting!.method, contains('nœud'));
    expect(s.repotting, isNull);
  });

  test('suppression pièce : plante non placée ; suppression plante : tâches supprimées', () async {
    final garden = container.read(gardenRepositoryProvider);
    final plants = container.read(plantRepositoryProvider);
    final care = container.read(careRepositoryProvider);

    await garden.saveSpace(Space(id: 's1', name: 'Balcon', kind: SpaceKind.outdoorZone, x: 0, y: 0, width: 2, height: 1));
    await plants.saveSpecies(_monstera());
    await plants.saveOwnedPlant(OwnedPlant(id: 'p1', speciesId: 'monstera', nickname: 'Momo', spaceId: 's1', x: 1, y: 0.5));
    await care.saveTask(CareTask(id: 't1', plantId: 'p1', type: CareType.watering, dueAt: DateTime(2026, 6, 1)));

    await garden.deleteSpace('s1');
    final owned = await plants.watchOwnedPlants().first;
    expect(owned.single.spaceId, isNull);

    await plants.deleteOwnedPlant('p1');
    expect(await care.watchTasks().first, isEmpty);
  });

  test('markDone retire la tâche des tâches en attente', () async {
    final plants = container.read(plantRepositoryProvider);
    final care = container.read(careRepositoryProvider);
    await plants.saveSpecies(_monstera());
    await plants.saveOwnedPlant(OwnedPlant(id: 'p1', speciesId: 'monstera', nickname: 'Momo'));
    await care.saveTask(CareTask(id: 't1', plantId: 'p1', type: CareType.watering, dueAt: DateTime(2026, 6, 1)));

    expect(await care.watchPending().first, hasLength(1));
    await care.markDone('t1', DateTime(2026, 6, 2));
    expect(await care.watchPending().first, isEmpty);
  });

  test('spacesProvider réagit aux changements', () async {
    final sub = container.listen(spacesProvider, (_, __) {});
    expect(await container.read(spacesProvider.future), isEmpty);

    await container
        .read(gardenRepositoryProvider)
        .saveSpace(Space(id: 's1', name: 'Cuisine', kind: SpaceKind.indoorRoom, x: 0, y: 0, width: 3, height: 3));
    await pumpEventQueue();
    expect(sub.read().value!.single.name, 'Cuisine');
  });
}
