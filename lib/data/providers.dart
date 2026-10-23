import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../models/care.dart';
import '../models/garden.dart';
import '../models/plant.dart';
import 'api/api_cache.dart';
import 'api/api_config.dart';
import 'api/gbif_client.dart';
import 'api/image_downloader.dart';
import 'api/perenual_client.dart';
import 'api/plant_lookup_service.dart';
import 'api/plantnet_client.dart';
import 'api/tela_client.dart';
import 'backup.dart';
import 'db/database.dart';
import 'repositories/care_repository.dart';
import 'repositories/garden_repository.dart';
import 'repositories/plant_repository.dart';

/// Base unique de l'app. Les tests la remplacent par `AppDatabase(NativeDatabase.memory())`.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.local();
  ref.onDispose(db.close);
  return db;
});

final gardenRepositoryProvider = Provider((ref) => GardenRepository(ref.watch(databaseProvider)));
final plantRepositoryProvider = Provider((ref) => PlantRepository(ref.watch(databaseProvider)));
final careRepositoryProvider = Provider((ref) => CareRepository(ref.watch(databaseProvider)));
final backupServiceProvider = Provider((ref) => BackupService(ref.watch(databaseProvider)));

final spacesProvider = StreamProvider<List<Space>>((ref) => ref.watch(gardenRepositoryProvider).watchSpaces());
final speciesProvider = StreamProvider<List<PlantSpecies>>((ref) => ref.watch(plantRepositoryProvider).watchSpecies());
final ownedPlantsProvider =
    StreamProvider<List<OwnedPlant>>((ref) => ref.watch(plantRepositoryProvider).watchOwnedPlants());
final pendingTasksProvider = StreamProvider<List<CareTask>>((ref) => ref.watch(careRepositoryProvider).watchPending());

/// Charge la base locale `assets/plants_fr.json` dans la table des espèces.
final speciesCatalogProvider = FutureProvider<void>((ref) async {
  final json = jsonDecode(await rootBundle.loadString('assets/plants_fr.json')) as List;
  await ref
      .read(plantRepositoryProvider)
      .addMissingSpecies([for (final j in json) PlantSpecies.fromJson(j as Map<String, dynamic>)]);
  // Sans attendre : le réseau peut manquer, on réessaiera au prochain lancement.
  unawaited(ref.read(plantLookupProvider).storeWebImagesOffline());
});

/// Plante en attente de placement : l'écran du plan attend un appui pour la poser.
final placingPlantProvider = StateProvider<String?>((ref) => null);

// API en ligne. Les tests remplacent httpClientProvider (MockClient) et apiKeysProvider.
final apiKeysProvider = Provider((ref) => const ApiKeys.fromEnvironment());
final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});
final apiCacheProvider = Provider((ref) => ApiCache(ref.watch(databaseProvider), ref.watch(httpClientProvider)));
final plantLookupProvider = Provider((ref) {
  final cache = ref.watch(apiCacheProvider);
  final keys = ref.watch(apiKeysProvider);
  return PlantLookupService(
    perenual: PerenualClient(cache, keys.perenual),
    gbif: GbifClient(cache),
    tela: TelaClient(cache),
    plantnet: PlantNetClient(ref.watch(httpClientProvider), keys.plantnet),
    plants: ref.watch(plantRepositoryProvider),
    images: ImageDownloader(ref.watch(httpClientProvider)),
  );
});
