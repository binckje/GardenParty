import 'package:flutter/material.dart';

import '../placeholder.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) => const PlaceholderScreen(
        title: 'Calendrier',
        emoji: '💧',
        todo: 'Arrosages et engrais à valider.',
      );
}
