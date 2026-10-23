import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_party/data/db/database.dart';
import 'package:garden_party/data/repositories/plant_repository.dart';
import 'package:garden_party/features/plants/catalog_screen.dart';
import 'package:garden_party/models/plant.dart';

List<PlantSpecies> _catalog() => [
      for (final j in jsonDecode(File('assets/plants_fr.json').readAsStringSync()) as List)
        PlantSpecies.fromJson(j as Map<String, dynamic>),
    ];

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('base locale : 25 espèces valides, identifiants uniques', () {
    final species = _catalog();
    expect(species, hasLength(25));
    expect(species.map((s) => s.id).toSet(), hasLength(25));
    for (final s in species) {
      expect(s.light, isNotEmpty, reason: s.id);
      expect(s.minTempC, lessThan(s.maxTempC), reason: s.id);
      expect(s.watering.activeMonths.every((m) => m >= 1 && m <= 12), isTrue, reason: s.id);
      expect(s.imageUrl, isNotEmpty, reason: s.id);
    }
  });

  test('addMissingSpecies n\'écrase pas une espèce déjà en base', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = PlantRepository(db);
    final species = _catalog();
    final edited = species.first;
    await repo.saveSpecies(PlantSpecies(
      id: edited.id,
      scientificName: edited.scientificName,
      commonName: 'Modifiée',
      light: edited.light,
      minTempC: edited.minTempC,
      maxTempC: edited.maxTempC,
      soil: edited.soil,
      watering: edited.watering,
      fertilizing: edited.fertilizing,
    ));

    await repo.addMissingSpecies(species);
    expect(await repo.watchSpecies().first, hasLength(25));
    expect((await repo.getSpecies(edited.id))!.commonName, 'Modifiée');
  });

  test('recherche insensible aux accents et à la casse', () {
    expect(normalize('Géranium'), 'geranium');
    expect(normalize('Fleur de LUNE'), contains('lune'));
  });
}
