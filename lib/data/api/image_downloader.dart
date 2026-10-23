import 'dart:convert';

import 'package:http/http.dart' as http;

/// Télécharge une photo pour la garder hors ligne, en data URI dans la fiche (comme les photos
/// de l'éditeur). `null` si l'image est inaccessible (réseau, CORS sur le web, trop lourde) :
/// la fiche garde alors l'adresse web, et l'emoji s'affiche hors ligne.
class ImageDownloader {
  ImageDownloader(this._client);

  final http.Client _client;

  /// Au-delà, la base et les sauvegardes grossiraient trop.
  static const maxBytes = 800 * 1024;

  Future<String?> toDataUri(String url) async {
    try {
      final r = await _client.get(Uri.parse(url)).timeout(const Duration(seconds: 20));
      final type = (r.headers['content-type'] ?? '').split(';').first.trim();
      if (r.statusCode != 200 || !type.startsWith('image/') || r.bodyBytes.isEmpty || r.bodyBytes.length > maxBytes) {
        return null;
      }
      return 'data:$type;base64,${base64Encode(r.bodyBytes)}';
    } catch (_) {
      return null;
    }
  }
}
