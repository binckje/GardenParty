import 'package:flutter/material.dart';

import '../placeholder.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => const PlaceholderScreen(
        title: 'Réglages',
        emoji: '⚙️',
        todo: 'Notifications, sauvegarde, à propos.',
      );
}
