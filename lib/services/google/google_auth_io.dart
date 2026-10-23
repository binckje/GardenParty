import 'dart:convert';

import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'google_auth.dart';
import 'google_calendar_sync.dart';

const _credsKey = 'google.credentials';

bool get configured => googleDesktopClientId.isNotEmpty && googleDesktopClientSecret.isNotEmpty;

GoogleAuth create(SharedPreferences prefs) => _IoGoogleAuth(prefs);

/// Consentement dans le navigateur, retour sur un petit serveur local (127.0.0.1) ouvert par l'app.
class _IoGoogleAuth implements GoogleAuth {
  _IoGoogleAuth(this._prefs);

  final SharedPreferences _prefs;
  AutoRefreshingAuthClient? _client;
  final _id = ClientId(googleDesktopClientId, googleDesktopClientSecret);

  @override
  Future<http.Client?> client({required bool interactive}) async {
    if (_client != null) return _client;
    final saved = _prefs.getString(_credsKey);
    AccessCredentials? creds;
    if (saved != null) {
      creds = AccessCredentials.fromJson(jsonDecode(saved) as Map<String, dynamic>);
    } else if (interactive) {
      final base = http.Client();
      try {
        creds = await obtainAccessCredentialsViaUserConsent(
          _id,
          googleCalendarScopes,
          base,
          (url) => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
          customPostAuthPage: '<html><body><h2>GardenParty est connecté à Google Agenda 🌱</h2>'
              '<p>Tu peux fermer cette page.</p></body></html>',
        );
      } finally {
        base.close();
      }
      await _save(creds);
    }
    if (creds == null || creds.refreshToken == null) return null;
    final c = autoRefreshingClient(_id, creds, http.Client());
    c.credentialUpdates.listen(_save);
    return _client = c;
  }

  Future<void> _save(AccessCredentials c) => _prefs.setString(_credsKey, jsonEncode(c.toJson()));

  @override
  Future<void> signOut() async {
    _client?.close();
    _client = null;
    await _prefs.remove(_credsKey);
  }
}
