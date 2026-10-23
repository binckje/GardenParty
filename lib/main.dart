import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'data/providers.dart';

void main() {
  runApp(const ProviderScope(child: GardenPartyApp()));
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
