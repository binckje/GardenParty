import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_party/data/api/api_cache.dart';
import 'package:garden_party/data/api/api_config.dart';
import 'package:garden_party/data/api/gbif_client.dart';
import 'package:garden_party/data/api/perenual_client.dart';
import 'package:garden_party/data/api/plant_lookup_service.dart';
import 'package:garden_party/data/api/plantnet_client.dart';
import 'package:garden_party/data/db/database.dart';
import 'package:garden_party/data/providers.dart';
import 'package:garden_party/data/repositories/plant_repository.dart';
import 'package:garden_party/features/plants/catalog_screen.dart';
import 'package:garden_party/models/plant.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;

/// Service dont seule la recherche par nom est simulée.
class _FakeLookup extends PlantLookupService {
  _FakeLookup(AppDatabase db, this.result)
      : super(
          perenual: PerenualClient(ApiCache(db, MockClient((_) async => http.Response('', 500))), 'k'),
          gbif: GbifClient(ApiCache(db, MockClient((_) async => http.Response('', 500)))),
          plantnet: PlantNetClient(MockClient((_) async => http.Response('', 500)), 'k'),
          plants: PlantRepository(db),
        );

  final Future<List<OnlineHit>> Function(String) result;
  final queries = <String>[];

  @override
  Future<PlantSpecies> fetchHit(OnlineHit hit) async => throw ApiException('Quota atteint sur perenual.com.');

  @override
  Future<List<OnlineHit>> searchByName(String query) {
    queries.add(query);
    return result(query);
  }
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  Future<_FakeLookup> pumpCatalog(WidgetTester tester, Future<List<OnlineHit>> Function(String) result) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final lookup = _FakeLookup(db, result);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        speciesProvider.overrideWith((ref) => Stream.value(const [])),
        plantLookupProvider.overrideWithValue(lookup),
      ],
      // Navigateur imbriqué, comme l'onglet Plantes sous go_router.
      child: MaterialApp(
        home: Navigator(onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => const CatalogScreen())),
      ),
    ));
    await tester.pump();
    return lookup;
  }

  testWidgets('recherche en ligne lancée à la demande, résultats affichés', (tester) async {
    final lookup = await pumpCatalog(
      tester,
      (_) async => const [OnlineHit(perenualId: 42, commonName: 'swiss cheese plant', scientificName: 'Monstera deliciosa')],
    );
    await tester.enterText(find.byType(TextField), 'monstera');
    await tester.pump();
    expect(lookup.queries, isEmpty, reason: 'pas d\'appel réseau à chaque frappe');

    await tester.tap(find.text('Chercher « monstera » en ligne'));
    await tester.pumpAndSettle();
    expect(lookup.queries, ['monstera']);
    expect(find.text('swiss cheese plant'), findsOneWidget);
    expect(find.text('Monstera deliciosa'), findsOneWidget);
  });

  testWidgets('erreur API affichée en français', (tester) async {
    await pumpCatalog(tester, (_) async => throw ApiException('Quota journalier atteint sur perenual.com, réessaie demain.'));
    await tester.enterText(find.byType(TextField), 'rose');
    await tester.pump();
    await tester.tap(find.text('Chercher « rose » en ligne'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Quota journalier'), findsOneWidget);
  });

  testWidgets('échec du chargement d\'une fiche : attente fermée, catalogue toujours affiché', (tester) async {
    await pumpCatalog(
      tester,
      (_) async => const [OnlineHit(perenualId: 42, commonName: 'swiss cheese plant', scientificName: 'Monstera deliciosa')],
    );
    await tester.enterText(find.byType(TextField), 'monstera');
    await tester.pump();
    await tester.tap(find.text('Chercher « monstera » en ligne'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('swiss cheese plant'));
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Catalogue'), findsOneWidget);
    expect(find.text('Quota atteint sur perenual.com.'), findsOneWidget);
  });
}
