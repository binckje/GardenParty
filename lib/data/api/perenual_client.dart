import 'api_cache.dart';
import 'api_config.dart';

/// Résultat de recherche Perenual (avant chargement de la fiche complète).
class PerenualHit {
  const PerenualHit({required this.id, required this.commonName, required this.scientificName, this.thumbnailUrl});

  final int id;
  final String commonName;
  final String scientificName;
  final String? thumbnailUrl;

  /// Fiche consultable avec la clé gratuite (les autres renvoient 429 « Please Upgrade Plan »).
  bool get freeAccess => id <= PerenualClient.freeMaxId;
}

/// Perenual (v2) : fiches d'entretien. Clé gratuite, quota journalier ; les champs réservés
/// aux offres payantes contiennent un texte « Upgrade Plans… » et sont ignorés.
class PerenualClient {
  PerenualClient(this._cache, this._key);

  final ApiCache _cache;
  final String _key;
  static const _base = 'https://perenual.com/api/v2';

  /// L'offre gratuite donne accès aux fiches des espèces n° 1 à 3000.
  static const freeMaxId = 3000;

  bool get configured => _key.isNotEmpty;

  Future<List<PerenualHit>> search(String query) async {
    _requireKey();
    final j = await _cache.getJson(
      Uri.parse('$_base/species-list').replace(queryParameters: {'key': _key, 'q': query}),
      ttl: const Duration(days: 7),
    ) as Map<String, dynamic>;
    final hits = [
      for (final d in (j['data'] as List? ?? const []).cast<Map<String, dynamic>>())
        PerenualHit(
          id: d['id'] as int,
          commonName: (d['common_name'] as String?) ?? '',
          scientificName: firstScientificName(d['scientific_name']),
          thumbnailUrl: imageUrl(d['default_image'], small: true),
        ),
    ];
    // Fiches accessibles d'abord ; l'ordre de Perenual est conservé sinon.
    return [...hits.where((h) => h.freeAccess), ...hits.where((h) => !h.freeAccess)];
  }

  /// Fiche brute (JSON), convertie par `perenualToSpecies`.
  Future<Map<String, dynamic>> details(int id) async {
    _requireKey();
    if (id > freeMaxId) throw ApiException('Fiche réservée à l\'offre payante de Perenual.');
    return await _cache.getJson(
      Uri.parse('$_base/species/details/$id').replace(queryParameters: {'key': _key}),
      ttl: const Duration(days: 90),
    ) as Map<String, dynamic>;
  }

  void _requireKey() {
    if (!configured) throw ApiException('Clé Perenual absente (PERENUAL_KEY dans .env).');
  }

  static String firstScientificName(dynamic v) => switch (v) {
        List l when l.isNotEmpty => l.first as String,
        String s => s,
        _ => '',
      };

  static String? imageUrl(dynamic image, {bool small = false}) {
    if (image is! Map) return null;
    final url = (small ? image['thumbnail'] ?? image['small_url'] : image['regular_url'] ?? image['medium_url']) as String?;
    return url == null || isUpgradeText(url) ? null : url;
  }

  static bool isUpgradeText(Object? v) => v is String && v.toLowerCase().contains('upgrade');
}
