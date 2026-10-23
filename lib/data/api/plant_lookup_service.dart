import 'dart:typed_data';

import '../../models/plant.dart';
import '../repositories/plant_repository.dart';
import 'gbif_client.dart';
import 'perenual_client.dart';
import 'api_config.dart';
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

  /// Recherche par nom. Perenual cherche en anglais/latin : un nom français sans résultat passe
  /// par GBIF pour obtenir le nom scientifique. Sans résultat Perenual (ou clé absente, quota…),
  /// les espèces GBIF sont proposées en fiche simplifiée.
  Future<List<OnlineHit>> searchByName(String query) async {
    final q = query.trim();
    if (q.isEmpty) return const [];
    ApiException? perenualError;
    Future<List<PerenualHit>> searchPerenual(String name) async {
      if (!perenual.configured || perenualError != null) return const [];
      try {
        return await perenual.search(name);
      } on ApiException catch (e) {
        perenualError = e;
        return const [];
      }
    }

    final hits = await searchPerenual(q);
    if (hits.isNotEmpty) return [for (final h in hits) OnlineHit.perenual(h)];
    final taxa = await gbif.search(q, limit: 5);
    for (final t in taxa.take(3)) {
      final found = await searchPerenual(t.canonicalName);
      if (found.isNotEmpty) return [for (final h in found) OnlineHit.perenual(h)];
    }
    if (taxa.isEmpty && perenualError != null) throw perenualError!;
    return [for (final t in taxa) OnlineHit.gbif(t)];
  }

  /// Fiche complète Perenual si l'offre gratuite y donne accès, sinon fiche simplifiée GBIF.
  /// La fiche est enregistrée en base.
  Future<PlantSpecies> fetchHit(OnlineHit hit) => hit.fullSheet
      ? fetchSpecies(hit.perenualId!)
      : speciesFromGbif(hit.scientificName, commonName: hit.commonName, gbifKey: hit.gbifKey);

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

  /// Fiche simplifiée : nom français GBIF (sinon [commonName]), entretien par défaut.
  Future<PlantSpecies> speciesFromGbif(String scientificName, {String? commonName, int? gbifKey}) async {
    final taxon = await gbif.match(scientificName);
    final key = taxon?.key ?? gbifKey;
    if (key == null) throw ApiException('Espèce inconnue de GBIF : $scientificName.');
    final frNames = await gbif.frenchNames(key);
    final canonical = taxon?.canonicalName ?? scientificName;
    final name = frNames.firstOrNull ?? (commonName == null || commonName.isEmpty ? canonical : commonName);
    final species = gbifDefaultSpecies(gbifKey: key, scientificName: canonical, commonName: name);
    await plants.saveSpecies(species);
    return species;
  }

  Future<List<PlantNetMatch>> identifyPhoto(List<Uint8List> images) => plantnet.identify(images);

  /// Après identification photo : fiche Perenual gratuite si elle existe, sinon fiche simplifiée GBIF.
  Future<PlantSpecies> speciesForMatch(PlantNetMatch match) async {
    var hits = const <PerenualHit>[];
    if (perenual.configured) {
      try {
        hits = [for (final h in await perenual.search(match.scientificName)) if (h.freeAccess) h];
      } on ApiException {
        // Perenual indisponible : la fiche simplifiée suffit.
      }
    }
    if (hits.isNotEmpty) {
      final exact = hits.where((h) => h.scientificName.toLowerCase() == match.scientificName.toLowerCase());
      return fetchSpecies((exact.firstOrNull ?? hits.first).id);
    }
    return speciesFromGbif(match.scientificName, commonName: match.commonNames.firstOrNull, gbifKey: match.gbifKey);
  }
}

/// Résultat de recherche en ligne : espèce Perenual ou, à défaut, taxon GBIF.
class OnlineHit {
  const OnlineHit({
    required this.commonName,
    required this.scientificName,
    this.perenualId,
    this.gbifKey,
    this.thumbnailUrl,
  });

  OnlineHit.perenual(PerenualHit h)
      : this(commonName: h.commonName, scientificName: h.scientificName, perenualId: h.id, thumbnailUrl: h.thumbnailUrl);

  OnlineHit.gbif(GbifTaxon t)
      : this(commonName: t.frenchName ?? '', scientificName: t.canonicalName, gbifKey: t.key);

  final String commonName;
  final String scientificName;
  final int? perenualId;
  final int? gbifKey;
  final String? thumbnailUrl;

  /// Fiche d'entretien Perenual accessible avec la clé gratuite ; sinon fiche simplifiée.
  bool get fullSheet => perenualId != null && perenualId! <= PerenualClient.freeMaxId;
}
