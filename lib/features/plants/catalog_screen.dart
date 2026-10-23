import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/providers.dart';
import '../../models/plant.dart';
import '../dialogs.dart';
import 'online_search.dart';
import 'plant_screen.dart';
import 'species_editor.dart';
import 'species_view.dart';

/// Recherche insensible à la casse et aux accents : « geranium » trouve « Géranium ».
String normalize(String s) {
  const from = 'àâäáãéèêëíìîïóòôöõúùûüçñœæ', to = 'aaaaaeeeeiiiiooooouuuucnoa';
  final buffer = StringBuffer();
  for (final c in s.toLowerCase().split('')) {
    final i = from.indexOf(c);
    buffer.write(i < 0 ? c : to[i]);
  }
  return buffer.toString();
}

/// Catalogue des espèces (base locale), avec recherche locale puis en ligne, et identification par photo.
class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = normalize(_query.trim());
    final species = ref.watch(speciesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogue'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: 'Créer une fiche',
            icon: const Icon(Icons.note_add_outlined),
            onPressed: () async {
              final nav = Navigator.of(context);
              final created =
                  await nav.push<PlantSpecies>(MaterialPageRoute(builder: (_) => const SpeciesEditorScreen()));
              if (created != null) nav.push(MaterialPageRoute(builder: (_) => SpeciesScreen(species: created)));
            },
          ),
          IconButton(
            tooltip: 'Identifier par photo',
            icon: const Icon(Icons.photo_camera),
            onPressed: () => identifyFromPhoto(context, ref),
          ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: TextField(
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Nom commun ou latin'),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Expanded(
          child: species.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erreur de chargement : $e')),
            data: (list) {
              final found = [
                for (final s in list)
                  if (normalize('${s.commonName} ${s.scientificName}').contains(q)) s,
              ];
              return ListView(children: [
                if (found.isEmpty) const ListTile(title: Text('Aucune espèce dans le catalogue local')),
                for (final s in found)
                  ListTile(
                    leading: SpeciesVisual(s),
                    title: Text(s.commonName),
                    subtitle: Text(s.scientificName, style: const TextStyle(fontStyle: FontStyle.italic)),
                    onTap: () =>
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => SpeciesScreen(species: s))),
                  ),
                OnlineResults(query: _query),
              ]);
            },
          ),
        ),
      ]),
    );
  }
}

/// Fiche d'une espèce du catalogue, avec ajout au jardin.
class SpeciesScreen extends ConsumerWidget {
  const SpeciesScreen({super.key, required this.species});

  final PlantSpecies species;

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final name = await askName(context, title: 'Surnom de ta plante', initial: species.commonName);
    if (name == null) return;
    final plant = OwnedPlant(id: const Uuid().v4(), speciesId: species.id, nickname: name);
    await ref.read(plantRepositoryProvider).saveOwnedPlant(plant);
    if (!context.mounted) return;
    // La fiche de la nouvelle plante remplace le catalogue : on peut la placer tout de suite.
    final nav = Navigator.of(context)..popUntil((r) => r.isFirst);
    nav.push(MaterialPageRoute(builder: (_) => PlantScreen(plantId: plant.id)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(
          title: Text(species.commonName),
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              tooltip: 'Modifier la fiche',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                final nav = Navigator.of(context);
                final edited = await nav.push<PlantSpecies>(
                  MaterialPageRoute(builder: (_) => SpeciesEditorScreen(initial: species)),
                );
                if (edited == null) return;
                nav.pushReplacement(MaterialPageRoute(builder: (_) => SpeciesScreen(species: edited)));
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: const Text('Ajouter au jardin'),
          onPressed: () => _add(context, ref),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
          children: [
            Center(child: SpeciesVisual(species, size: 96)),
            const SizedBox(height: 8),
            Center(child: Text(species.scientificName, style: const TextStyle(fontStyle: FontStyle.italic))),
            const SizedBox(height: 16),
            SpeciesDetails(species),
          ],
        ),
      );
}
