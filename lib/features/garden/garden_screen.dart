import 'package:flutter/material.dart';

import '../placeholder.dart';

class GardenScreen extends StatelessWidget {
  const GardenScreen({super.key});

  @override
  Widget build(BuildContext context) => const PlaceholderScreen(
        title: 'Mon jardin',
        emoji: '🏡',
        todo: 'Plan vu de dessus : pièces, zones, portes et fenêtres.',
      );
}
