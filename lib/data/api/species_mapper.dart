import '../../models/garden.dart';
import '../../models/plant.dart';
import 'perenual_client.dart';

/// Convertit une fiche Perenual (anglais, valeurs qualitatives) en fiche espèce de l'app.
/// Les manques sont comblés par des valeurs prudentes pour plante d'intérieur.
PlantSpecies perenualToSpecies(Map<String, dynamic> j, {String? frenchName, String? scientificName}) {
  final hardinessMin = _usdaZone(j['hardiness']?['min']);
  final indoor = j['indoor'] == true;
  return PlantSpecies(
    id: '$perenualSpeciesPrefix${j['id']}',
    scientificName: scientificName ?? PerenualClient.firstScientificName(j['scientific_name']),
    commonName: frenchName ?? _capitalize((j['common_name'] as String?) ?? ''),
    imageUrl: PerenualClient.imageUrl(j['default_image']),
    light: lightLevels(_strings(j['sunlight'])),
    minTempC: hardinessMin != null ? usdaZoneMinTempC(hardinessMin) : (indoor ? 12 : -5),
    maxTempC: 32,
    soil: _soil(_strings(j['soil'])),
    watering: watering(j['watering'] as String?, j['watering_general_benchmark']),
    fertilizing: const CareSchedule(everyDays: 30, quantity: 'Engrais liquide dilué de moitié'),
    diagnostics: [
      for (final pest in _strings(j['pest_susceptibility']))
        Diagnostic(
          symptom: 'Présence de ${_pests[pest.toLowerCase()] ?? pest}',
          cause: 'Ravageur fréquent sur cette espèce',
          treatment: 'Isoler la plante, nettoyer les feuilles, traiter au savon noir',
        ),
    ],
    cutting: _cutting(_strings(j['propagation'])),
  );
}

/// Préfixe d'identifiant des fiches simplifiées (GBIF + valeurs par défaut), à ajuster par l'utilisateur.
const gbifSpeciesPrefix = 'gbif-';
const perenualSpeciesPrefix = 'perenual-';

/// Fiche simplifiée quand Perenual n'a pas de fiche gratuite : nom et taxonomie GBIF,
/// entretien moyen de plante d'intérieur.
PlantSpecies gbifDefaultSpecies({required int gbifKey, required String scientificName, required String commonName}) =>
    PlantSpecies(
      id: '$gbifSpeciesPrefix$gbifKey',
      scientificName: scientificName,
      commonName: commonName,
      light: const [LightLevel.brightIndirect, LightLevel.partialSun],
      minTempC: 12,
      maxTempC: 30,
      soil: 'Terreau universel drainant',
      watering: const CareSchedule(everyDays: 7, quantity: 'Arroser quand le dessus du terreau est sec'),
      fertilizing: const CareSchedule(everyDays: 30, quantity: 'Engrais liquide dilué de moitié'),
    );

/// Préfixe d'identifiant des fiches déduites des indicateurs écologiques Tela Botanica.
const telaSpeciesPrefix = 'tela-';

/// Fiches créées dans l'éditeur.
const customSpeciesPrefix = 'perso-';

/// Origine d'une fiche, déduite de son identifiant.
({String label, Uri? url}) speciesSource(String id) {
  String rest(String prefix) => id.substring(prefix.length);
  if (id.startsWith(perenualSpeciesPrefix)) {
    return (
      label: 'Perenual (entretien), noms français GBIF',
      url: Uri.parse('https://perenual.com/plant-species-database-search-finder/species/${rest(perenualSpeciesPrefix)}'),
    );
  }
  if (id.startsWith(telaSpeciesPrefix)) {
    return (
      label: 'Tela Botanica, baseflor (écologie), noms français GBIF',
      url: Uri.parse('https://www.tela-botanica.org/bdtfx-nn-${rest(telaSpeciesPrefix)}'),
    );
  }
  if (id.startsWith(gbifSpeciesPrefix)) {
    return (label: 'GBIF (noms), entretien par défaut', url: Uri.parse('https://www.gbif.org/species/${rest(gbifSpeciesPrefix)}'));
  }
  if (id.startsWith(customSpeciesPrefix)) return (label: 'Fiche personnelle', url: null);
  return (label: 'Catalogue GardenParty', url: null);
}

/// Fiche de plante d'extérieur déduite du milieu naturel (Baseflor) : lumière d'Ellenberg (1–9),
/// température (1–9), humidité du sol (1–12), réaction et nutriments du sol.
PlantSpecies telaToSpecies(
  Map<String, dynamic> eco, {
  required int nameNumber,
  required String scientificName,
  required String commonName,
}) {
  int? code(String key) => int.tryParse('${eco['$key.code'] ?? ''}');
  String? label(String key) {
    final v = eco['$key.libelle'];
    return v is String && v.trim().isNotEmpty ? v.trim() : null;
  }

  final light = code('ve_lumiere') ?? 5;
  final temperature = code('ve_temperature') ?? 5;
  final soilWater = code('ve_humidite_edaph') ?? 5;
  final nutrients = code('ve_nutriments_sol') ?? 5;
  final soil = [label('ve_reaction_sol'), label('ve_nutriments_sol')].whereType<String>().join(', ');
  return PlantSpecies(
    id: '$telaSpeciesPrefix$nameNumber',
    scientificName: scientificName,
    commonName: commonName,
    light: switch (light) {
      <= 2 => const [LightLevel.shade],
      <= 4 => const [LightLevel.lowLight, LightLevel.brightIndirect],
      <= 6 => const [LightLevel.brightIndirect, LightLevel.partialSun],
      7 => const [LightLevel.partialSun, LightLevel.fullSun],
      _ => const [LightLevel.fullSun],
    },
    minTempC: switch (temperature) { <= 3 => -25, <= 5 => -18, 6 => -12, 7 => -8, _ => -5 },
    maxTempC: 35,
    soil: soil.isEmpty ? 'Terre de jardin' : 'Sol $soil',
    watering: switch (soilWater) {
      <= 3 => const CareSchedule(everyDays: 21, quantity: 'Seulement en cas de sécheresse', activeMonths: [5, 6, 7, 8, 9]),
      4 => const CareSchedule(everyDays: 10, quantity: 'Quand la terre est sèche en profondeur', activeMonths: [5, 6, 7, 8, 9]),
      <= 6 => const CareSchedule(everyDays: 5, quantity: 'Quand le dessus de la terre est sec', activeMonths: [4, 5, 6, 7, 8, 9]),
      <= 8 => const CareSchedule(everyDays: 3, quantity: 'Garder la terre fraîche', activeMonths: [4, 5, 6, 7, 8, 9]),
      _ => const CareSchedule(everyDays: 2, quantity: 'Garder la terre humide en permanence', activeMonths: [4, 5, 6, 7, 8, 9]),
    },
    fertilizing: switch (nutrients) {
      <= 3 => const CareSchedule(everyDays: 365, quantity: 'Aucun engrais : simplement valider', activeMonths: [3, 4, 5]),
      <= 6 => const CareSchedule(everyDays: 365, quantity: 'Compost au pied', activeMonths: [3, 4, 5]),
      _ => const CareSchedule(everyDays: 30, quantity: 'Engrais organique', activeMonths: [4, 5, 6, 7, 8]),
    },
  );
}

List<LightLevel> lightLevels(List<String> sunlight) {
  final levels = <LightLevel>{};
  for (final s in sunlight.map((s) => s.toLowerCase())) {
    if (s.contains('deep shade')) levels.add(LightLevel.shade);
    if (s.contains('full shade')) levels.add(LightLevel.lowLight);
    if (s.contains('filtered')) levels.add(LightLevel.brightIndirect);
    if (s.contains('part')) levels.addAll([LightLevel.brightIndirect, LightLevel.partialSun]);
    if (s.contains('full sun')) levels.add(LightLevel.fullSun);
  }
  if (levels.isEmpty) levels.add(LightLevel.brightIndirect);
  return levels.toList()..sort((a, b) => a.index.compareTo(b.index));
}

/// Fréquence : repère « X-Y days » s'il existe, sinon catégorie Perenual.
CareSchedule watering(String? category, dynamic benchmark) {
  final c = (category ?? '').toLowerCase();
  final quantity = switch (c) {
    'frequent' => 'Garder le terreau frais, sans eau stagnante',
    'minimum' || 'none' => 'Arroser quand le terreau est sec en profondeur',
    _ => 'Arroser quand le dessus du terreau est sec',
  };
  var days = switch (c) { 'frequent' => 3, 'minimum' => 14, 'none' => 30, _ => 7 };
  if (benchmark is Map && '${benchmark['unit']}'.contains('day')) {
    final nums = RegExp(r'\d+').allMatches('${benchmark['value']}').map((m) => int.parse(m[0]!)).toList();
    if (nums.isNotEmpty) days = (nums.reduce((a, b) => a + b) / nums.length).round().clamp(1, 60);
  }
  return CareSchedule(everyDays: days, quantity: quantity);
}

/// Température minimale moyenne de la zone de rusticité USDA (zone 1 = −51 °C, +5,55 °C par zone).
double usdaZoneMinTempC(int zone) => double.parse((-51.1 + 5.55 * (zone - 1)).toStringAsFixed(1));

int? _usdaZone(dynamic v) => v == null ? null : int.tryParse(RegExp(r'\d+').firstMatch('$v')?[0] ?? '');

List<String> _strings(dynamic v) =>
    v is List ? [for (final e in v) if (e is String && !PerenualClient.isUpgradeText(e)) e] : const [];

String _soil(List<String> soil) {
  if (soil.isEmpty) return 'Terreau universel drainant';
  return soil.map((s) => _soils[s.toLowerCase()] ?? s).join(', ');
}

PropagationInfo? _cutting(List<String> propagation) {
  if (propagation.isEmpty) return null;
  final cuttings = propagation.where((p) => p.toLowerCase().contains('cutting')).toList();
  if (cuttings.isEmpty) return const PropagationInfo(possible: false);
  return PropagationInfo(possible: true, method: cuttings.map((c) => _cuttings[c.toLowerCase()] ?? c).join(', '));
}

String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

const _soils = {
  'well-drained': 'drainant',
  'loamy': 'limoneux',
  'sandy': 'sableux',
  'clay': 'argileux',
  'peat': 'tourbeux',
  'chalky': 'calcaire',
  'acidic': 'acide',
  'alkaline': 'alcalin',
  'neutral': 'neutre',
  'moist': 'frais',
};

const _cuttings = {
  'cutting': 'Bouture',
  'stem cutting': 'Bouture de tige',
  'leaf cutting': 'Bouture de feuille',
  'root cutting': 'Bouture de racine',
  'tip cutting': 'Bouture de tête',
  'semi-hardwood cutting': 'Bouture semi-aoûtée',
  'softwood cutting': 'Bouture herbacée',
  'hardwood cutting': 'Bouture ligneuse',
};

const _pests = {
  'aphids': 'pucerons',
  'spider mites': 'araignées rouges',
  'mealybugs': 'cochenilles farineuses',
  'scale': 'cochenilles',
  'scale insects': 'cochenilles',
  'whiteflies': 'aleurodes',
  'whitefly': 'aleurodes',
  'thrips': 'thrips',
  'fungus gnats': 'mouches du terreau',
  'slugs': 'limaces',
  'snails': 'escargots',
};
