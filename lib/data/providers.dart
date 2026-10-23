import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/care.dart';
import '../models/garden.dart';
import '../models/plant.dart';
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
});

/// Plante en attente de placement : l'écran du plan attend un appui pour la poser.
final placingPlantProvider = StateProvider<String?>((ref) => null);
