import '../../data/repositories/plant_repository.dart';
import '../../models/garden.dart';
import '../../models/plant.dart';

/// Plantes d'essai pour le calendrier, en attendant l'ajout de plantes (étape 3).
Future<void> addDemoPlants(PlantRepository repo) async {
  await repo.saveSpecies(PlantSpecies(
    id: 'demo-monstera',
    scientificName: 'Monstera deliciosa',
    commonName: 'Monstera',
    light: [LightLevel.brightIndirect],
    minTempC: 15,
    maxTempC: 30,
    soil: 'Terreau drainant',
    watering: const CareSchedule(everyDays: 7, quantity: '500 ml'),
    fertilizing: const CareSchedule(everyDays: 30, quantity: '1 bouchon d\'engrais vert', activeMonths: [4, 5, 6, 7, 8, 9]),
  ));
  await repo.saveSpecies(PlantSpecies(
    id: 'demo-basilic',
    scientificName: 'Ocimum basilicum',
    commonName: 'Basilic',
    light: [LightLevel.fullSun],
    minTempC: 12,
    maxTempC: 35,
    soil: 'Terreau riche',
    watering: const CareSchedule(everyDays: 2, quantity: '200 ml'),
    fertilizing: const CareSchedule(everyDays: 15, quantity: '1/2 bouchon', activeMonths: [5, 6, 7, 8]),
  ));
  await repo.saveOwnedPlant(OwnedPlant(id: 'demo-p1', speciesId: 'demo-monstera', nickname: 'Monstera du salon'));
  await repo.saveOwnedPlant(OwnedPlant(id: 'demo-p2', speciesId: 'demo-basilic', nickname: 'Basilic'));
}
