import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import 'catalog_screen.dart';
import 'plant_screen.dart';
import 'species_view.dart';
import '../illustrations/illustration_settings.dart';
import '../illustrations/kawaii_illustration.dart';

/// Plantes possédées ; le bouton « Ajouter » ouvre le catalogue.
class PlantsScreen extends ConsumerWidget {
  const PlantsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plants = ref.watch(ownedPlantsProvider);
    final species = {for (final s in ref.watch(speciesProvider).valueOrNull ?? const []) s.id: s};
    final spaces = {for (final s in ref.watch(spacesProvider).valueOrNull ?? const []) s.id: s};

    return Scaffold(
      appBar: AppBar(title: const Text('Mes plantes'), backgroundColor: Colors.transparent),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CatalogScreen())),
      ),
      body: plants.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur de chargement : $e')),
        data: (list) => list.isEmpty
            ? const EmptyState(IllustrationScene.emptyPlants, 'Aucune plante pour l’instant.\nAjoute-en depuis le catalogue !')
            : ListView(
                padding: const EdgeInsets.only(bottom: 88),
                children: [
                  for (final p in list)
                    ListTile(
                      leading: SpeciesVisual(species[p.speciesId]),
                      title: Text(p.nickname),
                      subtitle: Text([
                        species[p.speciesId]?.commonName ?? p.speciesId,
                        p.isPlaced ? spaces[p.spaceId]?.name ?? '' : 'Non placée',
                      ].join(' · ')),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlantScreen(plantId: p.id))),
                    ),
                ],
              ),
      ),
    );
  }
}
