import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../services/google/google_auth.dart';
import '../calendar/care_service.dart';
import 'demo_data.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsProvider);
    final google = ref.watch(googleSyncProvider);
    final last = google.lastSync;

    return Scaffold(
      appBar: AppBar(title: const Text('Réglages'), backgroundColor: Colors.transparent),
      body: ListView(
        children: [
          const _Header('Alertes'),
          SwitchListTile(
            title: const Text('Notifications des soins'),
            subtitle: Text(!notifications.supported
                ? 'Non disponibles sur cet appareil : les retards restent signalés dans l\'app.'
                : defaultTargetPlatform == TargetPlatform.android && !kIsWeb
                    ? 'Rappel à l\'heure de chaque soin, même app fermée.'
                    : 'Rappel des soins dus à l\'ouverture de l\'app (pas de rappel app fermée).'),
            value: notifications.supported && notifications.enabled,
            onChanged: !notifications.supported
                ? null
                : (on) async {
                    final messenger = ScaffoldMessenger.of(context);
                    final care = ref.read(careServiceProvider);
                    final granted = await notifications.setEnabled(on);
                    if (on && !granted) {
                      messenger.showSnackBar(const SnackBar(content: Text('Autorisation refusée par le système.')));
                    }
                    if (on) await care.refreshAlerts();
                    if (mounted) setState(() {});
                  },
          ),
          const _Header('Google Agenda'),
          if (!googleConfigured)
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Non configuré'),
              subtitle: Text('Identifiants OAuth absents : voir google_oauth.env.example. '
                  'L\'export .ics (Calendrier) reste disponible.'),
            )
          else ...[
            ListTile(
              leading: const Icon(Icons.event),
              title: Text(google.connected ? 'Connecté : agenda « GardenParty 🌱 »' : 'Non connecté'),
              subtitle: Text(google.error != null
                  ? 'Erreur : ${google.error}'
                  : last == null
                      ? 'Les soins à faire seront ajoutés dans un agenda dédié.'
                      : 'Dernière synchro : ${_fmt(last)}'),
              trailing: google.busy ? const CircularProgressIndicator() : null,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: [
                  FilledButton(
                    onPressed: google.busy ? null : () => ref.read(googleSyncProvider.notifier).sync(interactive: true),
                    child: Text(google.connected ? 'Synchroniser' : 'Connecter Google Agenda'),
                  ),
                  if (google.connected)
                    OutlinedButton(
                      onPressed: google.busy ? null : () => ref.read(googleSyncProvider.notifier).disconnect(),
                      child: const Text('Déconnecter'),
                    ),
                ],
              ),
            ),
          ],
          const _Header('Données'),
          ListTile(
            leading: const Icon(Icons.local_florist_outlined),
            title: const Text('Ajouter des plantes de démo'),
            subtitle: const Text('Monstera et basilic, pour essayer le calendrier.'),
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              final care = ref.read(careServiceProvider);
              await addDemoPlants(ref.read(plantRepositoryProvider));
              final n = await care.ensureTasks();
              await care.refreshAlerts();
              messenger.showSnackBar(SnackBar(content: Text('$n soin(s) ajouté(s) au calendrier.')));
            },
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} ${d.hour}h${d.minute.toString().padLeft(2, '0')}';
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
        child: Text(text, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
      );
}
