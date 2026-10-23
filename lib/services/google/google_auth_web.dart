import 'package:googleapis_auth/auth_browser.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'google_auth.dart';
import 'google_calendar_sync.dart';

bool get configured => googleWebClientId.isNotEmpty;

GoogleAuth create(SharedPreferences prefs) => _WebGoogleAuth();

/// Jeton d'une heure via Google Identity Services, gardé en mémoire seulement.
class _WebGoogleAuth implements GoogleAuth {
  AccessCredentials? _creds;

  @override
  Future<http.Client?> client({required bool interactive}) async {
    final valid = _creds != null && !_creds!.accessToken.hasExpired;
    if (!valid) {
      if (!interactive) return null;
      _creds = await requestAccessCredentials(clientId: googleWebClientId, scopes: googleCalendarScopes, prompt: '');
    }
    return authenticatedClient(http.Client(), _creds!);
  }

  @override
  Future<void> signOut() async {
    final c = _creds;
    _creds = null;
    if (c != null) await revokeConsent(c.accessToken.data);
  }
}
