import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/router.dart';
import 'app/theme.dart';

void main() {
  runApp(const ProviderScope(child: GardenPartyApp()));
}

class GardenPartyApp extends StatelessWidget {
  const GardenPartyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GardenParty',
      debugShowCheckedModeBanner: false,
      theme: buildKawaiiTheme(),
      routerConfig: appRouter,
    );
  }
}
