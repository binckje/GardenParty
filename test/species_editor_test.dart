import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_party/data/db/database.dart';
import 'package:garden_party/data/repositories/plant_repository.dart';
import 'package:garden_party/data/providers.dart';
import 'package:garden_party/features/plants/species_editor.dart';
import 'package:garden_party/models/garden.dart';
import 'package:garden_party/models/plant.dart';

/// Dépôt qui garde les fiches enregistrées en mémoire.
class _Repo extends PlantRepository {
  _Repo(super.db);

  final saved = <PlantSpecies>[];

  @override
  Future<void> saveSpecies(PlantSpecies s) async => saved.add(s);
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  Future<_Repo> pump(WidgetTester tester, {PlantSpecies? initial}) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _Repo(db);
    tester.view.physicalSize = const Size(800, 6000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [plantRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(home: SpeciesEditorScreen(initial: initial)),
    ));
    return repo;
  }

  testWidgets('création : champs obligatoires, puis fiche perso enregistrée', (tester) async {
    final repo = await pump(tester);
    await tester.tap(find.byTooltip('Enregistrer'));
    await tester.pump();
    expect(find.text('Obligatoire'), findsNWidgets(2));
    expect(repo.saved, isEmpty);

    await tester.enterText(find.widgetWithText(TextFormField, 'Nom commun'), 'Bégonia maculata');
    await tester.enterText(find.widgetWithText(TextFormField, 'Nom latin'), 'Begonia maculata');
    await tester.tap(find.text('Lumineux sans soleil direct'));
    await tester.pump();
    await tester.tap(find.byTooltip('Enregistrer'));
    await tester.pumpAndSettle();

    final s = repo.saved.single;
    expect(s.id, startsWith('perso-'));
    expect(s.commonName, 'Bégonia maculata');
    expect(s.light, [LightLevel.brightIndirect]);
    expect(s.watering.everyDays, 7);
  });

  testWidgets('modification : identifiant conservé, valeurs reprises', (tester) async {
    final initial = PlantSpecies(
      id: 'monstera',
      scientificName: 'Monstera deliciosa',
      commonName: 'Monstera',
      imageUrl: '🌿',
      light: const [LightLevel.partialSun],
      minTempC: 15,
      maxTempC: 30,
      soil: 'Terreau',
      watering: const CareSchedule(everyDays: 7, quantity: '500 ml'),
      fertilizing: const CareSchedule(everyDays: 15, quantity: 'Demi-dose'),
      diagnostics: const [Diagnostic(symptom: 'Feuilles jaunes', cause: 'Trop d\'eau', treatment: 'Espacer')],
    );
    final repo = await pump(tester, initial: initial);
    await tester.enterText(find.widgetWithText(TextFormField, 'Tous les … jours').first, '10');
    await tester.tap(find.byTooltip('Enregistrer'));
    await tester.pumpAndSettle();

    final s = repo.saved.single;
    expect(s.id, 'monstera');
    expect(s.imageUrl, '🌿');
    expect(s.watering.everyDays, 10);
    expect(s.diagnostics.single.symptom, 'Feuilles jaunes');
  });
}
