import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers.dart';
import '../../models/plant.dart';
import '../dialogs.dart';
import '../light/suggested_spots.dart';
import 'species_view.dart';

/// Ouvre le plan en mode placement pour cette plante.
void startPlacing(BuildContext context, WidgetRef ref, String plantId) {
  ref.read(placingPlantProvider.notifier).state = plantId;
  final router = GoRouter.of(context);
  Navigator.of(context).popUntil((r) => r.isFirst);
  router.go('/garden');
}

/// Fiche d'une plante possédée : surnom, emplacement, fiche de l'espèce.
class PlantScreen extends ConsumerWidget {
  const PlantScreen({super.key, required this.plantId});

  final String plantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plant = ref.watch(ownedPlantsProvider).valueOrNull?.where((p) => p.id == plantId).firstOrNull;
    if (plant == null) return const Scaffold(body: SizedBox.shrink());
    final species = ref.watch(speciesProvider).valueOrNull?.where((s) => s.id == plant.speciesId).firstOrNull;
    final space = ref.watch(spacesProvider).valueOrNull?.where((s) => s.id == plant.spaceId).firstOrNull;
    final repo = ref.read(plantRepositoryProvider);

    Future<void> update(void Function(OwnedPlant p) change) {
      final p = plant.copy();
      change(p);
      return repo.saveOwnedPlant(p);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(plant.nickname),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: 'Renommer',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final name = await askName(context, title: 'Renommer', initial: plant.nickname);
              if (name != null) await update((p) => p.nickname = name);
            },
          ),
          IconButton(
            tooltip: 'Supprimer',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final ok = await confirm(
                context,
                title: 'Supprimer « ${plant.nickname} » ?',
                message: 'Ses tâches d’entretien seront aussi supprimées.',
                action: 'Supprimer',
              );
              if (!ok || !context.mounted) return;
              Navigator.of(context).pop();
              await repo.deleteOwnedPlant(plant.id);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Center(child: SpeciesVisual(species, size: 96)),
          const SizedBox(height: 8),
          Center(child: Text(species?.commonName ?? plant.speciesId, style: Theme.of(context).textTheme.titleMedium)),
          if (species != null)
            Center(child: Text(species.scientificName, style: const TextStyle(fontStyle: FontStyle.italic))),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Text('📍', style: TextStyle(fontSize: 24)),
              title: Text(plant.isPlaced && space != null ? space.name : 'Non placée'),
              subtitle: Text(plant.isPlaced ? 'Touche « Déplacer » ou fais-la glisser sur le plan' : 'Pose-la sur le plan du jardin'),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                if (plant.isPlaced)
                  IconButton(
                    tooltip: 'Retirer du plan',
                    icon: const Icon(Icons.close),
                    onPressed: () => update((p) => p
                      ..spaceId = null
                      ..x = null
                      ..y = null),
                  ),
                FilledButton(
                  onPressed: () => startPlacing(context, ref, plant.id),
                  child: Text(plant.isPlaced ? 'Déplacer' : 'Placer'),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          if (species != null) SuggestedSpots(plant: plant, species: species),
          if (species != null) SpeciesDetails(species),
        ],
      ),
    );
  }
}
