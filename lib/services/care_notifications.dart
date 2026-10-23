import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../features/calendar/care_planner.dart';
import '../models/care.dart';

const _enabledKey = 'notifications.enabled';
const _lastDueKey = 'notifications.lastDue';
const _summaryId = 0;

/// Texte du rappel des soins dus (en retard compris), ou null s'il n'y en a pas.
({String key, String title, String body})? dueSummary(
    List<CareTask> pending, String Function(String plantId) plantName, DateTime now) {
  final due = pending.where((t) => !t.dueAt.isAfter(now)).toList();
  if (due.isEmpty) return null;
  final lines = due.take(5).map((t) => '${careEmoji(t.type)} ${plantName(t.plantId)}').toList();
  if (due.length > 5) lines.add('… et ${due.length - 5} autre(s)');
  final ids = due.map((t) => t.id).toList()..sort();
  return (
    key: ids.join(','),
    title: due.length == 1 ? '1 soin à faire 🌱' : '${due.length} soins à faire 🌱',
    body: lines.join('\n'),
  );
}

/// Notifications système. Android : rappels programmés à l'heure de chaque soin.
/// Linux et web : pas de programmation possible, rappel affiché quand l'app est ouverte.
class CareNotifications {
  CareNotifications(this._prefs);

  final SharedPreferences _prefs;
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  bool get _isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Web : API Notification absente sur iPhone hors app ajoutée à l'écran d'accueil (iOS 16.4+).
  bool get supported => kIsWeb
      ? WebFlutterLocalNotificationsPlugin.isSupported
      : defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.linux;

  /// Web : l'autorisation ne peut être demandée que sur un geste, donc désactivé tant que l'utilisateur n'a pas activé.
  bool get enabled => _prefs.getBool(_enabledKey) ?? !kIsWeb;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails('care', 'Soins des plantes', channelDescription: 'Arrosages et engrais à faire'),
    linux: LinuxNotificationDetails(),
  );

  Future<void> init() async {
    if (_ready || !supported) return;
    try {
      _ready = await _plugin.initialize(
            settings: const InitializationSettings(
              android: AndroidInitializationSettings('@mipmap/ic_launcher'),
              linux: LinuxInitializationSettings(defaultActionName: 'Ouvrir'),
              web: WebInitializationSettings(),
            ),
          ) ??
          false;
      if (_isAndroid) {
        tzdata.initializeTimeZones();
        tz.setLocalLocation(tz.getLocation((await FlutterTimezone.getLocalTimezone()).identifier));
        if (enabled) {
          await _plugin
              .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
              ?.requestNotificationsPermission();
        }
      }
    } catch (e) {
      debugPrint('Notifications indisponibles : $e');
    }
  }

  /// Demande l'autorisation (Android 13+, navigateur). Linux n'en demande pas.
  /// Web : reste désactivé si le service worker ne démarre pas (ex. certificat HTTPS non reconnu) ou si refusé.
  Future<bool> setEnabled(bool on) async {
    await _prefs.setBool(_enabledKey, on);
    if (!on) {
      await _plugin.cancelAll();
      return true;
    }
    await init();
    if (kIsWeb) {
      var granted = false;
      try {
        granted = _ready &&
            (await _plugin
                    .resolvePlatformSpecificImplementation<WebFlutterLocalNotificationsPlugin>()
                    ?.requestNotificationsPermission() ??
                false);
      } catch (e) {
        debugPrint('Autorisation impossible : $e');
      }
      if (!granted) await _prefs.setBool(_enabledKey, false);
      return granted;
    }
    if (_isAndroid) {
      return await _plugin
              .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
              ?.requestNotificationsPermission() ??
          false;
    }
    return true;
  }

  /// Affiche le rappel des soins dus s'il a changé, et (Android) reprogramme les suivants.
  Future<void> refresh(List<CareTask> pending, String Function(String plantId) plantName, DateTime now) async {
    if (!_ready || !enabled) return;
    try {
      final s = dueSummary(pending, plantName, now);
      if (s != null && s.key != _prefs.getString(_lastDueKey)) {
        await _plugin.show(id: _summaryId, title: s.title, body: s.body, notificationDetails: _details);
      }
      await _prefs.setString(_lastDueKey, s?.key ?? '');
      if (_isAndroid) await _schedule(pending, plantName, now);
    } catch (e) {
      debugPrint('Notification non affichée : $e');
    }
  }

  Future<void> _schedule(List<CareTask> pending, String Function(String plantId) plantName, DateTime now) async {
    await _plugin.cancelAllPendingNotifications();
    var id = _summaryId + 1;
    for (final t in pending.where((t) => t.dueAt.isAfter(now)).take(60)) {
      await _plugin.zonedSchedule(
        id: id++,
        scheduledDate: tz.TZDateTime.from(t.dueAt, tz.local),
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: '${careEmoji(t.type)} ${careLabel(t.type)}',
        body: plantName(t.plantId),
      );
    }
  }
}
