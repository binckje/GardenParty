import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_party/data/providers.dart';
import 'package:garden_party/data/repositories/plant_repository.dart';
import 'package:garden_party/features/light/suggested_spots.dart';
import 'package:garden_party/models/garden.dart';
import 'package:garden_party/models/plant.dart';

class _FakePlantRepo implements PlantRepository {
  final saved = <OwnedPlant>[];

  @override
  Future<void> saveOwnedPlant(OwnedPlant p) async => saved.add(p.copy());

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

LightReading _r(String id, double x, double y, double lux) =>
    LightReading(id: id, x: x, y: y, moment: DayMoment.noon, estimatedLux: lux, takenAt: DateTime(2026, 6, 1));

void main() {
  testWidgets('fiche plante : emplacements conseillés et « Placer ici »', (tester) async {
    final species = [
      for (final j in jsonDecode(File('assets/plants_fr.json').readAsStringSync()) as List)
        PlantSpecies.fromJson(j as Map<String, dynamic>),
    ].firstWhere((s) => s.light.contains(LightLevel.brightIndirect) && !s.light.contains(LightLevel.shade));
    final salon = Space(
      id: 's',
      name: 'Salon',
      kind: SpaceKind.indoorRoom,
      x: 2,
      y: 1,
      width: 4,
      height: 3,
      lightReadings: [_r('a', 3, 2, 3000), _r('b', 5, 3, 100)],
    );
    final plant = OwnedPlant(id: 'p', speciesId: species.id, nickname: 'Pilou', spaceId: 's', x: 3, y: 2);
    final repo = _FakePlantRepo();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        spacesProvider.overrideWith((ref) => Stream.value([salon])),
        plantRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp(home: Scaffold(body: SuggestedSpots(plant: plant, species: species))),
    ));
    await tester.pump();

    // La plante est sur le point sombre : signalé, un seul point conseillé.
    expect(find.textContaining('ne lui convient pas'), findsOneWidget);
    expect(find.textContaining('Salon ·'), findsOneWidget);
    await tester.tap(find.text('Placer ici'));
    expect(repo.saved.single.x, 1);
    expect(repo.saved.single.y, 1);
  });
}
