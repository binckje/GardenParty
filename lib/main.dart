import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'data/providers.dart';
import 'features/calendar/care_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(ProviderScope(
    overrides: [prefsProvider.overrideWithValue(prefs)],
    child: const CareAlerts(child: GardenPartyApp()),
  ));
}

class GardenPartyApp extends ConsumerWidget {
  const GardenPartyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Remplit le catalogue d'espèces en arrière-plan au premier lancement.
    ref.watch(speciesCatalogProvider);
    return MaterialApp.router(
      title: 'GardenParty',
      debugShowCheckedModeBanner: false,
      theme: buildKawaiiTheme(),
      routerConfig: appRouter,
    );
  }
}

/// Au démarrage, au retour dans l'app et tous les quarts d'heure : tâches manquantes, rappels, synchro Google.
class CareAlerts extends ConsumerStatefulWidget {
  const CareAlerts({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<CareAlerts> createState() => _CareAlertsState();
}

class _CareAlertsState extends ConsumerState<CareAlerts> {
  Timer? _timer;
  AppLifecycleListener? _lifecycle;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    await ref.read(notificationsProvider).init();
    await _tick();
    ref.read(googleSyncProvider.notifier).sync();
    _timer = Timer.periodic(const Duration(minutes: 15), (_) => _tick());
    _lifecycle = AppLifecycleListener(onResume: _tick);
  }

  Future<void> _tick() async {
    final care = ref.read(careServiceProvider);
    await care.ensureTasks();
    await care.refreshAlerts();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _lifecycle?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Plante ajoutée, renommée ou supprimée : ses soins et les rappels suivent.
    ref.listen(ownedPlantsProvider, (_, __) => _tick());
    return widget.child;
  }
}
