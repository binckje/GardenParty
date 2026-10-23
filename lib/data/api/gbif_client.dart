import 'api_cache.dart';

/// Taxon du référentiel GBIF (Backbone Taxonomy).
class GbifTaxon {
  const GbifTaxon({required this.key, required this.scientificName, required this.canonicalName, this.family});

  final int key;
  final String scientificName;
  final String canonicalName;
  final String? family;
}

/// GBIF : sans clé. Normalise les noms scientifiques et fournit les noms vernaculaires français.
class GbifClient {
  GbifClient(this._cache);

  final ApiCache _cache;
  static const _base = 'https://api.gbif.org/v1';
  static const _backbone = 'd7dddbf4-2cf0-4f39-9b2a-bb099caae36c';

  /// Rapproche un nom scientifique (même approximatif) d'un taxon ; null si aucun.
  Future<GbifTaxon?> match(String scientificName) async {
    final j = await _cache.getJson(Uri.parse('$_base/species/match').replace(
      queryParameters: {'name': scientificName, 'kingdom': 'Plantae'},
    )) as Map<String, dynamic>;
    if (j['matchType'] == 'NONE' || j['usageKey'] == null) return null;
    return GbifTaxon(
      key: (j['acceptedUsageKey'] ?? j['usageKey']) as int,
      scientificName: j['scientificName'] as String,
      canonicalName: (j['canonicalName'] ?? j['scientificName']) as String,
      family: j['family'] as String?,
    );
  }

  /// Recherche plein texte (noms français compris) parmi les espèces végétales.
  Future<List<GbifTaxon>> search(String query, {int limit = 10}) async {
    final j = await _cache.getJson(Uri.parse('$_base/species/search').replace(queryParameters: {
      'q': query,
      'datasetKey': _backbone,
      'rank': 'SPECIES',
      'highertaxonKey': '6', // Plantae
      'status': 'ACCEPTED',
      'limit': '$limit',
    })) as Map<String, dynamic>;
    return [
      for (final r in (j['results'] as List).cast<Map<String, dynamic>>())
        if (r['canonicalName'] != null)
          GbifTaxon(
            key: (r['nubKey'] ?? r['key']) as int,
            scientificName: r['scientificName'] as String,
            canonicalName: r['canonicalName'] as String,
            family: r['family'] as String?,
          ),
    ];
  }

  /// Noms vernaculaires français, le plus fréquent en premier.
  Future<List<String>> frenchNames(int taxonKey) async {
    final j = await _cache.getJson(Uri.parse('$_base/species/$taxonKey/vernacularNames?limit=200'))
        as Map<String, dynamic>;
    final counts = <String, int>{};
    for (final r in (j['results'] as List).cast<Map<String, dynamic>>()) {
      if (r['language'] != 'fra') continue;
      final name = (r['vernacularName'] as String).trim();
      if (name.isEmpty) continue;
      final key = name[0].toUpperCase() + name.substring(1);
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return counts.keys.toList()..sort((a, b) => counts[b]!.compareTo(counts[a]!));
  }
}
