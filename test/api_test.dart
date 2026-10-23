import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_party/data/api/api_cache.dart';
import 'package:garden_party/data/api/api_config.dart';
import 'package:garden_party/data/api/gbif_client.dart';
import 'package:garden_party/data/api/perenual_client.dart';
import 'package:garden_party/data/api/plant_lookup_service.dart';
import 'package:garden_party/data/api/plantnet_client.dart';
import 'package:garden_party/data/api/species_mapper.dart';
import 'package:garden_party/data/api/tela_client.dart';
import 'package:garden_party/data/db/database.dart';
import 'package:garden_party/data/providers.dart';
import 'package:garden_party/models/garden.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Réponses simulées, indexées par chemin d'URL.
Map<String, dynamic> _routes(Uri url) => switch (url.path) {
      '/api/v2/species-list' => {
          'data': url.queryParameters['q'] == 'Monstera deliciosa' || url.queryParameters['q'] == 'monstera'
              ? [
                  {
                    'id': 42,
                    'common_name': 'swiss cheese plant',
                    'scientific_name': ['Monstera deliciosa'],
                    'default_image': {'thumbnail': 'https://img/t.jpg', 'regular_url': 'https://img/r.jpg'},
                  }
                ]
              : [],
        },
      '/api/v2/species/details/42' => {
          'id': 42,
          'common_name': 'swiss cheese plant',
          'scientific_name': ['Monstera deliciosa'],
          'default_image': {'regular_url': 'https://img/r.jpg'},
          'watering': 'Average',
          'watering_general_benchmark': {'value': '"7-10"', 'unit': 'days'},
          'sunlight': ['part shade', 'filtered shade'],
          'hardiness': {'min': '10', 'max': '12'},
          'soil': ['Well-drained', 'Upgrade Plans To Premium/Supreme'],
          'propagation': ['Stem Cutting', 'Air Layering Propagation'],
          'pest_susceptibility': ['Spider mites'],
          'indoor': true,
        },
      '/service:eflore:0.1/bdtfx/noms' => url.queryParameters['masque'] == 'Lavandula angustifolia'
          ? {
              'entete': {'total': '1'},
              'resultat': {
                '38072': {'nom_sci': 'Lavandula angustifolia', 'retenu': 'true'},
              },
            }
          : {'entete': {'total': 0}, 'resultat': []},
      '/service:eflore:0.1/baseflor/informations/bdtfx.nn:38072' => {
          'num_nomen': '38072',
          've_lumiere.code': '8',
          've_temperature.code': '6',
          've_humidite_edaph.code': '4',
          've_reaction_sol.libelle': 'basophiles (7,0<pH<7,5)',
          've_nutriments_sol.libelle': 'méso-oligotrophiles',
          've_nutriments_sol.code': '3',
        },
      '/v1/species/match' when url.queryParameters['name'] == 'Lavandula angustifolia' => {'matchType': 'NONE'},
      '/v1/species/match' => {
          'usageKey': 2868241,
          'matchType': 'EXACT',
          'scientificName': 'Monstera deliciosa Liebm.',
          'canonicalName': 'Monstera deliciosa',
          'family': 'Araceae',
        },
      '/v1/species/search' => {
          'results': [
            {'key': 2868241, 'scientificName': 'Monstera deliciosa Liebm.', 'canonicalName': 'Monstera deliciosa'}
          ],
        },
      '/v1/species/2868241/vernacularNames' => {
          'results': [
            {'vernacularName': 'Swiss cheese plant', 'language': 'eng'},
            {'vernacularName': 'faux philodendron', 'language': 'fra'},
            {'vernacularName': 'Monstera', 'language': 'fra'},
            {'vernacularName': 'monstera', 'language': 'fra'},
          ],
        },
      '/v2/identify/all' => {
          'results': [
            {
              'score': 0.91,
              'species': {
                'scientificNameWithoutAuthor': 'Monstera deliciosa',
                'commonNames': ['Monstera'],
                'family': {'scientificNameWithoutAuthor': 'Araceae'},
              },
              'gbif': {'id': '2868241'},
            }
          ],
        },
      _ => throw StateError('URL inattendue : $url'),
    };

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late ProviderContainer container;
  late List<Uri> calls;
  late bool offline;

  setUp(() {
    calls = [];
    offline = false;
    final client = MockClient((req) async {
      calls.add(req.url);
      if (offline) throw http.ClientException('hors ligne');
      return http.Response(jsonEncode(_routes(req.url)), 200, headers: {'content-type': 'application/json'});
    });
    container = ProviderContainer(overrides: [
      databaseProvider.overrideWith((ref) {
        final db = AppDatabase(NativeDatabase.memory());
        ref.onDispose(db.close);
        return db;
      }),
      httpClientProvider.overrideWithValue(client),
      apiKeysProvider.overrideWithValue(const ApiKeys(perenual: 'secret', plantnet: 'secret2')),
    ]);
  });
  tearDown(() => container.dispose());

  test('clé de cache sans clé API', () {
    expect(ApiCache.cacheKey(Uri.parse('https://perenual.com/api/v2/species-list?key=abc&q=rose')),
        'https://perenual.com/api/v2/species-list?q=rose');
  });

  test('recherche par nom français via GBIF puis Perenual', () async {
    final hits = await container.read(plantLookupProvider).searchByName('faux philodendron');
    expect(hits.single.perenualId, 42);
    expect(calls.map((u) => u.path), contains('/v1/species/search'));
  });

  test('fiche Perenual convertie, nom français, enregistrée en base', () async {
    final s = await container.read(plantLookupProvider).fetchSpecies(42);
    expect(s.id, 'perenual-42');
    expect(s.commonName, 'Monstera');
    expect(s.scientificName, 'Monstera deliciosa');
    expect(s.light, [LightLevel.brightIndirect, LightLevel.partialSun]);
    expect(s.watering.everyDays, 9);
    expect(s.minTempC, closeTo(-1.1, 0.1));
    expect(s.soil, 'drainant');
    expect(s.cutting!.method, 'Bouture de tige');
    expect(s.diagnostics.single.symptom, contains('araignées rouges'));
    expect(await container.read(plantRepositoryProvider).getSpecies('perenual-42'), isNotNull);
  });

  test('cache : pas de second appel réseau, et resservi hors ligne même périmé', () async {
    final cache = container.read(apiCacheProvider);
    final url = Uri.parse('https://perenual.com/api/v2/species/details/42?key=secret');
    await cache.getJson(url);
    await cache.getJson(url);
    expect(calls, hasLength(1));
    offline = true;
    final j = await cache.getJson(url, ttl: Duration.zero);
    expect(j['id'], 42);
    expect(() => cache.getJson(Uri.parse('https://api.gbif.org/v1/species/match?name=x')),
        throwsA(isA<ApiException>()));
  });

  test('identification photo puis fiche', () async {
    final lookup = container.read(plantLookupProvider);
    final matches = await lookup.identifyPhoto([Uint8List.fromList([1, 2, 3])]);
    expect(matches.single.scientificName, 'Monstera deliciosa');
    expect(matches.single.gbifKey, 2868241);
    expect((await lookup.speciesForMatch(matches.single)).id, 'perenual-42');
  });

  test('clé absente : erreur explicite', () async {
    final perenual = PerenualClient(container.read(apiCacheProvider), '');
    expect(() => perenual.search('rose'), throwsA(isA<ApiException>()));
    expect(calls, isEmpty);
  });

  test('arrosage et rusticité', () {
    expect(watering('Frequent', null).everyDays, 3);
    expect(watering('Minimum', {'value': '"14-21"', 'unit': 'days'}).everyDays, 18);
    expect(usdaZoneMinTempC(1), -51.1);
    expect(lightLevels(['full sun']), [LightLevel.fullSun]);
    expect(lightLevels([]), [LightLevel.brightIndirect]);
  });

  test('offre gratuite : fiches n° > 3000 refusées sans appel, triées après les autres', () async {
    final perenual = PerenualClient(container.read(apiCacheProvider), 'secret');
    await expectLater(perenual.details(5257), throwsA(isA<ApiException>()));
    expect(calls, isEmpty);
    expect(const PerenualHit(id: 5257, commonName: '', scientificName: '').freeAccess, isFalse);
  });

  test('429 « Please Upgrade Plan » : message fiche payante, pas quota', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final cache = ApiCache(db, MockClient((_) async => http.Response('Please Upgrade Plan - https://perenual.com', 429)));
    await expectLater(
      cache.getJson(Uri.parse('https://perenual.com/api/v2/species/details/12?key=k')),
      throwsA(isA<ApiException>().having((e) => e.message, 'message', startsWith('Fiche réservée'))),
    );
  });

  test('fiche payante ou absente de Perenual : fiche simplifiée GBIF', () async {
    final lookup = container.read(plantLookupProvider);
    final paid = await lookup.fetchHit(const OnlineHit(perenualId: 5257, commonName: 'x', scientificName: 'Monstera deliciosa'));
    expect(paid.id, 'gbif-2868241');
    expect(paid.commonName, 'Monstera');
    expect(paid.watering.everyDays, 7);
    expect(calls.map((u) => u.path), isNot(contains('/api/v2/species/details/5257')));
    expect(await container.read(plantRepositoryProvider).getSpecies('gbif-2868241'), isNotNull);
  });

  test('aucun résultat Perenual : taxons GBIF proposés en fiche simplifiée', () async {
    final hits = await container.read(plantLookupProvider).searchByName('ficus inconnu');
    // GBIF trouve Monstera deliciosa, que Perenual connaît : résultat Perenual.
    expect(hits.single.fullSheet, isTrue);
    final noKey = PlantLookupService(
      perenual: PerenualClient(container.read(apiCacheProvider), ''),
      gbif: GbifClient(container.read(apiCacheProvider)),
      tela: TelaClient(container.read(apiCacheProvider)),
      plantnet: PlantNetClient(MockClient((_) async => http.Response('', 500)), ''),
      plants: container.read(plantRepositoryProvider),
    );
    final gbifHits = await noKey.searchByName('faux philodendron');
    expect(gbifHits.single.fullSheet, isFalse);
    expect(gbifHits.single.gbifKey, 2868241);
  });

  test('Tela Botanica : fiche écologique pour une espèce de la flore de France', () async {
    final s = await container.read(plantLookupProvider).simplifiedSpecies('Lavandula angustifolia', commonName: 'Lavande');
    expect(s.id, 'tela-38072');
    expect(s.commonName, 'Lavande');
    expect(s.light, [LightLevel.fullSun]);
    expect(s.minTempC, -12);
    expect(s.watering.everyDays, 10);
    expect(s.fertilizing.quantity, startsWith('Aucun engrais'));
    expect(s.soil, 'Sol basophiles (7,0<pH<7,5), méso-oligotrophiles');
  });
}
