import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/api/api_config.dart';
import '../../data/api/plant_lookup_service.dart';
import '../../data/api/plantnet_client.dart';
import '../../data/providers.dart';
import '../../models/plant.dart';
import 'catalog_screen.dart';

void _showError(BuildContext context, Object e) {
  final message = e is ApiException ? e.message : 'Erreur inattendue : $e';
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

/// Attente bloquante. Le dialogue vit sur le navigateur racine, pas sur celui de l'onglet :
/// le fermer via `Navigator.of(context)` fermerait l'écran du catalogue à la place.
VoidCallback _showSpinner(BuildContext context) {
  final root = Navigator.of(context, rootNavigator: true);
  showDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );
  return root.pop;
}

/// Charge une fiche en ligne (attente bloquante) puis ouvre la fiche espèce.
Future<void> openOnlineSpecies(
  BuildContext context,
  Future<PlantSpecies?> Function() load, {
  required String notFound,
}) async {
  final nav = Navigator.of(context);
  final closeSpinner = _showSpinner(context);
  PlantSpecies? species;
  Object? error;
  try {
    species = await load();
  } catch (e) {
    error = e;
  }
  closeSpinner();
  if (!context.mounted) return;
  if (error != null) return _showError(context, error);
  if (species == null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(notFound)));
    return;
  }
  nav.push(MaterialPageRoute(builder: (_) => SpeciesScreen(species: species!)));
}

/// Résultats Perenual pour [query], lancés à la demande (le quota gratuit est limité).
class OnlineResults extends ConsumerStatefulWidget {
  const OnlineResults({super.key, required this.query});

  final String query;

  @override
  ConsumerState<OnlineResults> createState() => _OnlineResultsState();
}

class _OnlineResultsState extends ConsumerState<OnlineResults> {
  String? _searched;
  Future<List<OnlineHit>>? _results;

  void _search() => setState(() {
        _searched = widget.query.trim();
        // ignore() : l'erreur est affichée par le FutureBuilder, pas remontée comme non traitée.
        _results = ref.read(plantLookupProvider).searchByName(_searched!)..ignore();
      });

  @override
  Widget build(BuildContext context) {
    final q = widget.query.trim();
    if (q.isEmpty) return const SizedBox.shrink();
    if (_results == null || _searched != q) {
      return ListTile(
        leading: const Icon(Icons.travel_explore),
        title: Text('Chercher « $q » en ligne'),
        subtitle: const Text('Perenual, sinon GBIF'),
        onTap: _search,
      );
    }
    return FutureBuilder(
      future: _results,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
        }
        if (snap.hasError) {
          final e = snap.error;
          return ListTile(
            leading: const Icon(Icons.cloud_off),
            title: Text(e is ApiException ? e.message : 'Erreur : $e'),
            trailing: IconButton(icon: const Icon(Icons.refresh), onPressed: _search),
          );
        }
        final hits = snap.data!;
        if (hits.isEmpty) return const ListTile(leading: Icon(Icons.search_off), title: Text('Rien trouvé en ligne'));
        return Column(children: [
          const ListTile(dense: true, title: Text('En ligne', style: TextStyle(fontWeight: FontWeight.bold))),
          for (final h in hits)
            ListTile(
              leading: CircleAvatar(
                backgroundImage: h.thumbnailUrl == null ? null : NetworkImage(h.thumbnailUrl!),
                child: h.thumbnailUrl == null ? const Text('🌐') : null,
              ),
              title: Text(h.commonName.isEmpty ? h.scientificName : h.commonName),
              subtitle: Text(
                h.fullSheet ? h.scientificName : '${h.scientificName} · fiche simplifiée',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
              onTap: () => openOnlineSpecies(
                context,
                () => ref.read(plantLookupProvider).fetchHit(h),
                notFound: 'Fiche introuvable',
              ),
            ),
        ]);
      },
    );
  }
}

/// Photo (appareil ou galerie) → Pl@ntNet → choix parmi les espèces proposées → fiche.
Future<void> identifyFromPhoto(BuildContext context, WidgetRef ref) async {
  final picker = ImagePicker();
  final canUseCamera = picker.supportsImageSource(ImageSource.camera);
  final source = canUseCamera
      ? await showModalBottomSheet<ImageSource>(
          context: context,
          builder: (c) => SafeArea(
            child: Wrap(children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Prendre une photo'),
                onTap: () => Navigator.pop(c, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choisir une image'),
                onTap: () => Navigator.pop(c, ImageSource.gallery),
              ),
            ]),
          ),
        )
      : ImageSource.gallery;
  if (source == null) return;
  // 1280 px suffisent à Pl@ntNet et allègent l'envoi.
  final file = await picker.pickImage(source: source, maxWidth: 1280, maxHeight: 1280, imageQuality: 85);
  if (file == null || !context.mounted) return;

  final lookup = ref.read(plantLookupProvider);
  final closeSpinner = _showSpinner(context);
  List<PlantNetMatch> matches;
  try {
    matches = await lookup.identifyPhoto([await file.readAsBytes()]);
  } catch (e) {
    closeSpinner();
    if (context.mounted) _showError(context, e);
    return;
  }
  closeSpinner();
  if (!context.mounted) return;
  if (matches.isEmpty) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Plante non reconnue : essaie une photo plus nette d\'une feuille')));
    return;
  }
  final chosen = await showModalBottomSheet<PlantNetMatch>(
    context: context,
    builder: (c) => SafeArea(
      child: ListView(shrinkWrap: true, children: [
        const ListTile(title: Text('C\'est peut-être…', style: TextStyle(fontWeight: FontWeight.bold))),
        for (final m in matches)
          ListTile(
            leading: Text('${(m.score * 100).round()} %'),
            title: Text(m.commonNames.firstOrNull ?? m.scientificName),
            subtitle: Text(m.scientificName, style: const TextStyle(fontStyle: FontStyle.italic)),
            onTap: () => Navigator.pop(c, m),
          ),
      ]),
    ),
  );
  if (chosen == null || !context.mounted) return;
  await openOnlineSpecies(
    context,
    () => lookup.speciesForMatch(chosen),
    notFound: 'Fiche introuvable pour ${chosen.scientificName}',
  );
}
