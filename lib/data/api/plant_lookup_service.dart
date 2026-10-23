import 'dart:typed_data';

import '../../models/plant.dart';
import '../repositories/plant_repository.dart';
import 'gbif_client.dart';
import 'perenual_client.dart';
import 'plantnet_client.dart';
import 'species_mapper.dart';

/// Recherche de plantes en ligne : Perenual (entretien) + GBIF (noms FR), Pl@ntNet (photo).
/// Les fiches obtenues sont enregistrées en base locale.
class PlantLookupService {
  PlantLookupService({required this.perenual, required this.gbif, required this.plantnet, required this.plants});

  final PerenualClient perenual;
  final GbifClient gbif;
  final PlantNetClient plantnet;
  final PlantRepository plants;

  /// Perenual cherche en anglais/latin : un nom français sans résultat passe d'abord par GBIF
  /// pour obtenir le nom scientifique.
  Future<List<PerenualHit>> searchByName(String query) async {
    final q = query.trim();
    if (q.isEmpty) return const [];
    final hits = await perenual.search(q);
    if (hits.isNotEmpty) return hits;
    final taxa = await gbif.search(q, limit: 3);
    for (final t in taxa) {
      final found = await perenual.search(t.canonicalName);
      if (found.isNotEmpty) return found;
    }
    return const [];
  }

  /// Charge la fiche complète, ajoute le nom français et l'enregistre en base.
  Future<PlantSpecies> fetchSpecies(int perenualId) async {
    final details = await perenual.details(perenualId);
    final rawName = PerenualClient.firstScientificName(details['scientific_name']);
    final taxon = rawName.isEmpty ? null : await gbif.match(rawName);
    final frNames = taxon == null ? const <String>[] : await gbif.frenchNames(taxon.key);
    final species = perenualToSpecies(
      details,
      frenchName: frNames.firstOrNull,
      scientificName: taxon?.canonicalName,
    );
    await plants.saveSpecies(species);
    return species;
  }

  Future<List<PlantNetMatch>> identifyPhoto(List<Uint8List> images) => plantnet.identify(images);

  /// Après identification photo : fiche de l'espèce reconnue, ou null si Perenual ne la connaît pas
/// ou ne la donne qu'en offre payante.
  Future<PlantSpecies?> speciesForMatch(PlantNetMatch match) async {
    final hits = (await perenual.search(match.scientificName)).where((h) => h.freeAccess);
    if (hits.isEmpty) return null;
    final exact = hits.where((h) => h.scientificName.toLowerCase() == match.scientificName.toLowerCase());
    return fetchSpecies((exact.firstOrNull ?? hits.first).id);
  }
}
