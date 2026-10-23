import 'dart:convert';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_party/data/backup.dart';
import 'package:garden_party/data/db/database.dart';
import 'package:garden_party/data/repositories/care_repository.dart';
import 'package:garden_party/data/repositories/garden_repository.dart';
import 'package:garden_party/data/repositories/plant_repository.dart';
import 'package:garden_party/models/care.dart';
import 'package:garden_party/models/garden.dart';
import 'package:garden_party/models/plant.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase source;
  late AppDatabase target;

  setUp(() {
    source = AppDatabase(NativeDatabase.memory());
    target = AppDatabase(NativeDatabase.memory());
  });
  tearDown(() async {
    await source.close();
    await target.close();
  });

  Future<void> fill(AppDatabase db) async {
    await GardenRepository(db).saveSpace(Space(
      id: 's1',
      name: 'Salon',
      kind: SpaceKind.indoorRoom,
      x: 0,
      y: 0,
      width: 5,
      height: 4,
      openings: [Opening(id: 'o1', kind: OpeningKind.door, wall: 2, offset: 1, length: 0.9)],
      lightReadings: [
        LightReading(id: 'l1', x: 1, y: 1, moment: DayMoment.noon, estimatedLux: 3000, takenAt: DateTime(2026, 5, 1)),
      ],
    ));
    await PlantRepository(db).saveSpecies(PlantSpecies(
      id: 'monstera',
      scientificName: 'Monstera deliciosa',
      commonName: 'Monstera',
      light: [LightLevel.brightIndirect],
      minTempC: 15,
      maxTempC: 30,
      soil: 'Terreau drainant',
      watering: const CareSchedule(everyDays: 7, quantity: '500 ml'),
      fertilizing: const CareSchedule(everyDays: 30, quantity: '1 bouchon', activeMonths: [4, 5]),
    ));
    await PlantRepository(db)
        .saveOwnedPlant(OwnedPlant(id: 'p1', speciesId: 'monstera', nickname: 'Momo', spaceId: 's1', x: 1, y: 2));
    await CareRepository(db)
        .saveTask(CareTask(id: 't1', plantId: 'p1', type: CareType.watering, dueAt: DateTime(2026, 6, 1)));
  }

  test('export puis import : données identiques, anciennes données remplacées', () async {
    await fill(source);
    await GardenRepository(target)
        .saveSpace(Space(id: 'old', name: 'Ancien', kind: SpaceKind.outdoorZone, x: 0, y: 0, width: 1, height: 1));

    final json = await BackupService(source).exportJson();
    await BackupService(target).importJson(json);

    final space = (await GardenRepository(target).getSpaces()).single;
    expect(space.name, 'Salon');
    expect(space.openings.single.kind, OpeningKind.door);
    expect(space.lightReadings.single.takenAt, DateTime(2026, 5, 1));
    final species = (await PlantRepository(target).getSpecies('monstera'))!;
    expect(species.fertilizing.activeMonths, [4, 5]);
    expect((await PlantRepository(target).watchOwnedPlants().first).single.nickname, 'Momo');
    expect((await CareRepository(target).watchPending().first).single.dueAt, DateTime(2026, 6, 1));

    // Un nouvel export de la base restaurée donne le même contenu.
    final again = await BackupService(target).exportJson();
    expect(jsonDecode(again)['tables'], jsonDecode(json)['tables']);
  });

  test('fichier invalide : erreur claire et base intacte', () async {
    await fill(target);
    final service = BackupService(target);

    expect(() => service.importJson('pas du json'), throwsA(isA<BackupException>()));
    expect(() => service.importJson('{"app":"autre"}'), throwsA(isA<BackupException>()));
    expect(
      () => service.importJson('{"app":"garden_party","format":1,"schemaVersion":99,"tables":{}}'),
      throwsA(isA<BackupException>()),
    );
    // Ligne cassée au milieu de l'import : la transaction annule tout.
    final broken = jsonEncode({
      'app': 'garden_party',
      'format': 1,
      'schemaVersion': 2,
      'tables': {
        'spaces': [],
        'openings': ['cassé'],
      },
    });
    await expectLater(service.importJson(broken), throwsA(isA<BackupException>()));

    expect((await GardenRepository(target).getSpaces()).single.name, 'Salon');
  });
}
