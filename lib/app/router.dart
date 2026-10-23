import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/calendar/care_service.dart';
import '../features/garden/garden_screen.dart';
import '../features/plants/plants_screen.dart';
import '../features/settings/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/garden',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => _HomeShell(shell: shell),
      branches: [
        _branch('/garden', const GardenScreen()),
        _branch('/plants', const PlantsScreen()),
        _branch('/calendar', const CalendarScreen()),
        _branch('/settings', const SettingsScreen()),
      ],
    ),
  ],
);

StatefulShellBranch _branch(String path, Widget screen) => StatefulShellBranch(
      routes: [GoRoute(path: path, builder: (_, __) => screen)],
    );

class _HomeShell extends ConsumerWidget {
  const _HomeShell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Soins en retard ou dus : pastille sur l'onglet Calendrier.
    final now = ref.watch(clockProvider).valueOrNull ?? DateTime.now();
    final due = (ref.watch(pendingTasksProvider).valueOrNull ?? const []).where((t) => !t.dueAt.isAfter(now)).length;
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: shell.goBranch,
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Jardin'),
          const NavigationDestination(icon: Icon(Icons.local_florist_outlined), label: 'Plantes'),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: due > 0,
              label: Text('$due'),
              child: const Icon(Icons.calendar_month_outlined),
            ),
            label: 'Calendrier',
          ),
          const NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Réglages'),
        ],
      ),
    );
  }
}
