import 'dart:convert';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../models/care.dart';
import '../../services/google/google_auth.dart';
import 'care_planner.dart';
import 'care_service.dart';
import '../illustrations/illustration_settings.dart';
import '../illustrations/kawaii_illustration.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(pendingTasksProvider).valueOrNull ?? const [];
    final plants = ref.watch(ownedPlantsProvider).valueOrNull ?? const [];
    final species = {for (final s in ref.watch(speciesProvider).valueOrNull ?? const []) s.id: s};
    final now = ref.watch(clockProvider).valueOrNull ?? DateTime.now();
    final google = ref.watch(googleSyncProvider);

    final plantById = {for (final p in plants) p.id: p};
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final overdue = tasks.where((t) => t.dueAt.isBefore(today)).toList();
    final dueToday = tasks.where((t) => !t.dueAt.isBefore(today) && t.dueAt.isBefore(tomorrow)).toList();
    final later = tasks.where((t) => !t.dueAt.isBefore(tomorrow)).toList();

    String quantity(CareTask t) {
      final sp = species[plantById[t.plantId]?.speciesId];
      return sp == null ? '' : scheduleFor(sp, t.type).quantity;
    }

    Widget section(String title, List<CareTask> list, {Color? color}) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color)),
            ),
            for (final t in list)
              _TaskTile(
                task: t,
                plantName: plantById[t.plantId]?.nickname ?? 'Plante',
                quantity: quantity(t),
                today: today,
                overdue: color != null,
              ),
          ],
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendrier'),
        backgroundColor: Colors.transparent,
        actions: [
          if (googleConfigured && google.connected)
            IconButton(
              tooltip: 'Synchroniser Google Agenda',
              onPressed: google.busy ? null : () => ref.read(googleSyncProvider.notifier).sync(),
              icon: google.busy
                  ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(google.error == null ? Icons.sync : Icons.sync_problem),
            ),
          IconButton(
            tooltip: 'Exporter (.ics)',
            onPressed: tasks.isEmpty ? null : () => _exportIcs(context, ref),
            icon: const Icon(Icons.ios_share),
          ),
        ],
      ),
      body: tasks.isEmpty
          ? _Empty(hasPlants: plants.isNotEmpty)
          : ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                if (overdue.isEmpty && dueToday.isEmpty)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(children: [
                      KawaiiIllustration(IllustrationScene.allDone, size: 72),
                      SizedBox(width: 12),
                      Expanded(child: Text('Tout est fait pour aujourd\'hui, bravo !')),
                    ]),
                  ),
                if (overdue.isNotEmpty) section('⚠️ En retard', overdue, color: Theme.of(context).colorScheme.error),
                if (dueToday.isNotEmpty) section('Aujourd\'hui', dueToday),
                if (later.isNotEmpty) section('À venir', later),
              ],
            ),
    );
  }

  Future<void> _exportIcs(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final ics = await ref.read(careServiceProvider).buildIcsExport();
      final path = await FileSaver.instance.saveFile(
        name: 'gardenparty-soins',
        bytes: Uint8List.fromList(utf8.encode(ics)),
        fileExtension: 'ics',
        mimeType: MimeType.custom,
        customMimeType: 'text/calendar',
      );
      messenger.showSnackBar(SnackBar(content: Text('Agenda exporté (90 jours) : $path')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Export impossible : $e')));
    }
  }
}

class _TaskTile extends ConsumerWidget {
  const _TaskTile({
    required this.task,
    required this.plantName,
    required this.quantity,
    required this.today,
    required this.overdue,
  });

  final CareTask task;
  final String plantName, quantity;
  final DateTime today;
  final bool overdue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = DateTime(task.dueAt.year, task.dueAt.month, task.dueAt.day);
    final diff = day.difference(today).inDays;
    final when = switch (diff) {
      < 0 => 'en retard de ${-diff} j',
      0 => 'aujourd\'hui',
      1 => 'demain',
      _ => 'le ${day.day.toString().padLeft(2, '0')}/${day.month.toString().padLeft(2, '0')}',
    };
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Text(careEmoji(task.type), style: const TextStyle(fontSize: 28)),
        title: Text(plantName),
        subtitle: Text(
          [careLabel(task.type), if (quantity.isNotEmpty) quantity, when].join(' · '),
          style: overdue ? TextStyle(color: Theme.of(context).colorScheme.error) : null,
        ),
        trailing: FilledButton.tonal(
          onPressed: () => ref.read(careServiceProvider).complete(task),
          child: const Text('Fait ✓'),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.hasPlants});

  final bool hasPlants;

  @override
  Widget build(BuildContext context) {
    return hasPlants
        ? const EmptyState(IllustrationScene.allDone, 'Rien à faire pour le moment.\nTes plantes sont contentes !')
        : const EmptyState(IllustrationScene.noCare, 'Ajoute des plantes (onglet Plantes) pour voir leurs soins ici.');
  }
}
