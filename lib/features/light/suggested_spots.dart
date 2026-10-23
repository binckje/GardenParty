import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../models/garden.dart';
import '../../models/plant.dart';
import '../garden/plan_geometry.dart';
import 'light_analysis.dart';
import 'light_meter.dart';

/// Section « Emplacements conseillés » de la fiche plante : points mesurés adaptés à ses besoins en lumière.
class SuggestedSpots extends ConsumerWidget {
  const SuggestedSpots({super.key, required this.plant, required this.species});

  /// Nombre maximal de suggestions affichées.
  static const maxShown = 5;

  final OwnedPlant plant;
  final PlantSpecies species;

  static String _m(double v) => v.toStringAsFixed(v == v.roundToDouble() ? 0 : 2).replaceAll('.', ',');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spaces = ref.watch(spacesProvider).valueOrNull ?? const <Space>[];
    final measured = spaces.any((s) => s.lightReadings.isNotEmpty);
    final best = LightAnalysis.bestSpots(spaces, species.light);
    final here = PlanGeometry.plantPosition(plant, spaces);
    final space = spaces.where((s) => s.id == plant.spaceId).firstOrNull;
    final hereSpot = here == null || space == null ? null : LightAnalysis.spotAt(LightAnalysis.spots(space), here);
    final theme = Theme.of(context);

    Future<void> placeAt(SpotSuggestion s) => ref.read(plantRepositoryProvider).saveOwnedPlant(plant.copy()
      ..spaceId = s.space.id
      ..x = s.spot.position.dx - s.space.x
      ..y = s.spot.position.dy - s.space.y);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('🧭 Emplacements conseillés', style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        if (hereSpot != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              'Lumière à son emplacement : ${lightLevelLabels[hereSpot.medianLevel]}'
              '${LightAnalysis.suits(species.light, hereSpot) ? ' ✓' : ' (ne lui convient pas)'}',
            ),
          ),
        if (!measured)
          const Text('Aucune mesure de lumière : touche ☀️ sur le plan du jardin pour mesurer tes pièces.')
        else if (best.isEmpty)
          const Text('Aucun point mesuré ne lui convient. Mesure d\'autres endroits (☀️ sur le plan).')
        else
          Card(
            child: Column(children: [
              for (final s in best.take(maxShown))
                ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 10,
                    backgroundColor: lightLevelColors[s.spot.medianLevel],
                  ),
                  title: Text('${s.space.name} · ${lightLevelLabels[s.spot.medianLevel]}'),
                  subtitle: Text(
                    'À ${_m(s.spot.position.dx - s.space.x)} m du bord gauche, '
                    '${_m(s.spot.position.dy - s.space.y)} m du haut · '
                    '${s.spot.byMoment.length}/${DayMoment.values.length} moments mesurés',
                  ),
                  trailing: hereSpot != null && s.space.id == space?.id && hereSpot.position == s.spot.position
                      ? const Text('Ici ✓')
                      : TextButton(onPressed: () => placeAt(s), child: const Text('Placer ici')),
                ),
            ]),
          ),
      ]),
    );
  }
}
