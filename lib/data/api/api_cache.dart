import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;

import '../db/database.dart';
import 'api_config.dart';

/// GET JSON avec cache SQLite : une réponse valide est resservie sans réseau jusqu'à expiration,
/// et reste utilisée (même périmée) si le réseau ou le quota fait défaut.
class ApiCache {
  ApiCache(this._db, this._client, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final http.Client _client;
  final DateTime Function() _now;

  /// Paramètres retirés de la clé de cache (une clé API ne doit pas finir en base).
  static const _secretParams = {'key', 'api-key'};

  static String cacheKey(Uri url) {
    final params = Map.of(url.queryParameters)..removeWhere((k, _) => _secretParams.contains(k));
    return url.replace(queryParameters: params.isEmpty ? null : params).toString();
  }

  Future<dynamic> getJson(Uri url, {Duration ttl = const Duration(days: 30)}) async {
    final key = cacheKey(url);
    final cached = await (_db.select(_db.apiCacheEntries)..where((c) => c.key.equals(key))).getSingleOrNull();
    if (cached != null && _now().difference(cached.fetchedAt) < ttl) return jsonDecode(cached.body);

    http.Response res;
    try {
      res = await _client.get(url);
    } catch (e) {
      if (cached != null) return jsonDecode(cached.body);
      throw ApiException('Pas de connexion au service (${url.host}).');
    }
    if (res.statusCode != 200) {
      if (cached != null) return jsonDecode(cached.body);
      throw ApiException(_errorMessage(res.statusCode, url.host, res.body), statusCode: res.statusCode);
    }
    final body = utf8.decode(res.bodyBytes);
    final decoded = jsonDecode(body);
    await _db.into(_db.apiCacheEntries).insertOnConflictUpdate(
          ApiCacheEntriesCompanion.insert(key: key, body: body, fetchedAt: _now()),
        );
    return decoded;
  }

  /// Vide les entrées plus vieilles que [maxAge].
  Future<int> purge(Duration maxAge) =>
      (_db.delete(_db.apiCacheEntries)..where((c) => c.fetchedAt.isSmallerThanValue(_now().subtract(maxAge)))).go();
}

/// Message pour l'UI, suivi de la réponse du service (tronquée) pour le diagnostic.
String _errorMessage(int status, String host, String body) {
  final base = switch (status) {
    401 || 403 => 'Clé API refusée par $host.',
    404 => 'Plante introuvable sur $host.',
    // Perenual répond aussi 429 pour une fiche hors offre gratuite.
    429 when body.toLowerCase().contains('upgrade') => 'Fiche réservée à l\'offre payante de $host.',
    429 => 'Quota atteint sur $host.',
    _ => 'Erreur $status de $host.',
  };
  final detail = body.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (detail.isEmpty) return base;
  return '$base ($status : ${detail.length > 160 ? '${detail.substring(0, 160)}…' : detail})';
}
