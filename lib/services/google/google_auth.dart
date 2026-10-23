import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'google_auth_io.dart' if (dart.library.js_interop) 'google_auth_web.dart' as platform;

/// Identifiants OAuth fournis au lancement (`--dart-define-from-file=google_oauth.env`, voir scripts/dev.sh).
/// Linux/Android : client « Application de bureau » (retour sur 127.0.0.1). Web : client « Application Web ».
const googleDesktopClientId = String.fromEnvironment('GOOGLE_DESKTOP_CLIENT_ID');
const googleDesktopClientSecret = String.fromEnvironment('GOOGLE_DESKTOP_CLIENT_SECRET');
const googleWebClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');

bool get googleConfigured => platform.configured;

/// Connexion Google ; les jetons (Linux/Android) restent dans les préférences locales.
abstract class GoogleAuth {
  /// Client HTTP authentifié, ou null si non connecté et [interactive] faux.
  Future<http.Client?> client({required bool interactive});

  Future<void> signOut();

  static GoogleAuth create(SharedPreferences prefs) => platform.create(prefs);
}
