import 'package:flutter/material.dart';

import '../placeholder.dart';

class PlantsScreen extends StatelessWidget {
  const PlantsScreen({super.key});

  @override
  Widget build(BuildContext context) => const PlaceholderScreen(
        title: 'Mes plantes',
        emoji: '🪴',
        todo: 'Liste des plantes et fiches d’identité.',
      );
}
