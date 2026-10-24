import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'api_config.dart';

/// Espèce proposée par Pl@ntNet pour une photo, avec son score (0–1).
class PlantNetMatch {
  const PlantNetMatch({
    required this.score,
    required this.scientificName,
    this.commonNames = const [],
    this.family,
    this.gbifKey,
  });

  final double score;
  final String scientificName;
  final List<String> commonNames;
  final String? family;
  final int? gbifKey;
}

/// Pl@ntNet : identification par photo (jamais mise en cache). Sur le web, le domaine de l'app
/// doit être autorisé dans le compte my.plantnet.org (CORS).
class PlantNetClient {
  PlantNetClient(this._client, this._key);

  final http.Client _client;
  final String _key;

  bool get configured => _key.isNotEmpty;

  /// [images] : 1 à 5 photos JPEG/PNG de la même plante.
  Future<List<PlantNetMatch>> identify(List<Uint8List> images) async {
    if (!configured) throw ApiException('Clé Pl@ntNet absente (PLANTNET_KEY dans .env).');
    final url = Uri.parse('https://my-api.plantnet.org/v2/identify/all')
        .replace(queryParameters: {'api-key': _key, 'lang': 'fr', 'nb-results': '5'});
    final req = http.MultipartRequest('POST', url);
    for (final (i, bytes) in images.indexed) {
      req.files.add(http.MultipartFile.fromBytes('images', bytes, filename: 'photo$i.jpg'));
      req.fields['organs'] = 'auto';
    }
    http.Response res;
    try {
      res = await http.Response.fromStream(await _client.send(req));
    } catch (_) {
      throw ApiException('Pas de connexion à Pl@ntNet.');
    }
    // 404 = aucune espèce reconnue sur la photo.
    if (res.statusCode == 404) return const [];
    if (res.statusCode != 200) {
      throw ApiException(
        switch (res.statusCode) {
          429 => 'Quota Pl@ntNet atteint, réessaie demain.',
          // Sur le web, Pl@ntNet refuse les origines absentes des « Authorized domains » du compte.
          403 => 'Accès refusé par Pl@ntNet (403) : ajoute l\'adresse de l\'app (ex. 192.168.1.20) '
              'dans « Authorized domains » sur my.plantnet.org, ou vérifie la clé.',
          _ => 'Erreur ${res.statusCode} de Pl@ntNet.',
        },
        statusCode: res.statusCode,
      );
    }
    final j = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    return [
      for (final r in (j['results'] as List).cast<Map<String, dynamic>>())
        PlantNetMatch(
          score: (r['score'] as num).toDouble(),
          scientificName: r['species']['scientificNameWithoutAuthor'] as String,
          commonNames: (r['species']['commonNames'] as List? ?? const []).cast<String>(),
          family: r['species']['family']?['scientificNameWithoutAuthor'] as String?,
          gbifKey: int.tryParse('${r['gbif']?['id'] ?? ''}'),
        ),
    ];
  }
}
