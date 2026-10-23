import 'api_cache.dart';

/// Tela Botanica (eFlore) : sans clé. Baseflor donne, pour ~8000 taxons de la flore de France,
/// les indicateurs écologiques (lumière, température, humidité du sol, pH, nutriments).
class TelaClient {
  TelaClient(this._cache);

  final ApiCache _cache;
  static const _base = 'https://api.tela-botanica.org/service:eflore:0.1';

  /// Numéro nomenclatural BDTFX du nom retenu ; null si le nom est inconnu de la flore de France.
  Future<int?> nameNumber(String scientificName) async {
    final j = await _cache.getJson(Uri.parse('$_base/bdtfx/noms').replace(queryParameters: {
      'masque': scientificName,
      'retour.format': 'min',
    })) as Map<String, dynamic>;
    final results = j['resultat'];
    if (results is! Map || results.isEmpty) return null;
    final entries = results.entries.toList();
    final kept = entries.where((e) => '${(e.value as Map)['retenu']}' == 'true');
    return int.tryParse((kept.firstOrNull ?? entries.first).key as String);
  }

  /// Indicateurs écologiques (`ve_*.code` / `ve_*.libelle`) ; null si le taxon n'est pas dans Baseflor.
  Future<Map<String, dynamic>?> ecology(int nameNumber) async {
    final j = await _cache.getJson(
      Uri.parse('$_base/baseflor/informations/bdtfx.nn:$nameNumber').replace(queryParameters: {'categorie': 'ecologie'}),
    );
    return j is Map<String, dynamic> && j['ve_lumiere.code'] != null ? j : null;
  }
}
