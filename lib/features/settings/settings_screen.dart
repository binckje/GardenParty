import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/backup.dart';
import '../../data/providers.dart';
import '../../services/google/google_auth.dart';
import '../calendar/care_service.dart';

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
                ? kIsWeb
                    ? 'Non disponibles dans ce navigateur. iPhone : ajouter l\'app à l\'écran d\'accueil '
                        '(Partager > Sur l\'écran d\'accueil), puis l\'ouvrir depuis l\'icône. '
                        'Les retards restent signalés dans l\'app.'
                    : 'Non disponibles sur cet appareil : les retards restent signalés dans l\'app.'
                : defaultTargetPlatform == TargetPlatform.android && !kIsWeb
                    ? 'Rappel à l\'heure de chaque soin, même app fermée.'
                    : 'Rappel des soins dus à l\'ouverture de l\'app (pas de rappel app fermée).'),
            value: notifications.supported && notifications.enabled,
            onChanged: !notifications.supported
                ? null
                : (on) async {
                    final messenger = ScaffoldMessenger.of(context);
                    final care = ref.read(careServiceProvider);
                    try {
                      final granted = await notifications.setEnabled(on);
                      if (on && !granted) {
                        messenger.showSnackBar(const SnackBar(
                          content: Text(kIsWeb
                              ? 'Notifications refusées ou impossibles (le navigateur exige un HTTPS reconnu).'
                              : 'Autorisation refusée par le système.'),
                        ));
                      }
                      if (on && granted) await care.refreshAlerts();
                    } catch (e) {
                      messenger.showSnackBar(SnackBar(content: Text('Notifications impossibles : $e')));
                    } finally {
                      if (mounted) setState(() {});
                    }
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
          const _Header('Sauvegarde'),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Exporter mes données'),
            subtitle: const Text('Fichier JSON : plan, mesures, fiches, plantes et soins.'),
            onTap: _export,
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restaurer une sauvegarde'),
            subtitle: const Text('Remplace toutes les données actuelles.'),
            onTap: _import,
          ),
        ],
      ),
    );
  }

  Future<void> _export() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final json = await ref.read(backupServiceProvider).exportJson();
      final now = DateTime.now();
      final path = await FileSaver.instance.saveFile(
        name: 'gardenparty-${now.year}-${_two(now.month)}-${_two(now.day)}',
        bytes: utf8.encode(json),
        fileExtension: 'json',
        mimeType: MimeType.json,
      );
      messenger.showSnackBar(SnackBar(content: Text('Sauvegarde enregistrée : $path')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Export impossible : $e')));
    }
  }

  Future<void> _import() async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurer une sauvegarde ?'),
        content: const Text('Toutes les données actuelles seront remplacées par celles du fichier.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Restaurer')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final file = await FilePicker.pickFile(
        dialogTitle: 'Choisir une sauvegarde',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (file == null) return;
      final bytes = await file.xFile.readAsBytes();
      await ref.read(backupServiceProvider).importJson(utf8.decode(bytes));
      await ref.read(careServiceProvider).refreshAlerts();
      messenger.showSnackBar(const SnackBar(content: Text('Sauvegarde restaurée 🌱')));
    } on BackupException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Restauration impossible : $e')));
    }
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

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
