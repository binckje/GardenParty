import 'dart:ui';

import '../../models/garden.dart';

/// Point de mesure d'une pièce : mesures regroupées par moment de la journée.
class LightSpot {
  LightSpot(this.position);

  final Offset position;
  final Map<DayMoment, LightReading> byMoment = {};

  /// Niveau retenu pour le point : médian des moments mesurés (le plus faible des deux du milieu).
  LightLevel get medianLevel => LightAnalysis.median([for (final r in byMoment.values) r.level]);
}

/// Emplacement conseillé pour une plante.
typedef SpotSuggestion = ({Space space, LightSpot spot});

/// Calculs sur les mesures de lumière, indépendants de l'affichage.
class LightAnalysis {
  /// Deux mesures à moins de cette distance (m) désignent le même point.
  static const spotRadius = 0.4;

  static LightLevel median(List<LightLevel> levels) {
    assert(levels.isNotEmpty);
    final sorted = [...levels]..sort((a, b) => a.index.compareTo(b.index));
    return sorted[(sorted.length - 1) ~/ 2];
  }

  /// Regroupe les mesures de la pièce par point ; la plus récente l'emporte pour un moment donné.
  static List<LightSpot> spots(Space s) {
    final spots = <LightSpot>[];
    final readings = [...s.lightReadings]..sort((a, b) => a.takenAt.compareTo(b.takenAt));
    for (final r in readings) {
      final p = Offset(r.x, r.y);
      final spot = spotAt(spots, p) ?? (spots..add(LightSpot(p))).last;
      spot.byMoment[r.moment] = r;
    }
    return spots;
  }

  static LightSpot? spotAt(List<LightSpot> spots, Offset p) {
    LightSpot? best;
    for (final s in spots) {
      final d = (s.position - p).distance;
      if (d <= spotRadius && (best == null || d < (best.position - p).distance)) best = s;
    }
    return best;
  }

  /// Le point convient si son niveau médian fait partie des besoins de la plante.
  static bool suits(List<LightLevel> needs, LightSpot spot) => needs.contains(spot.medianLevel);

  /// Points adaptés, les mieux renseignés (plus de moments mesurés) d'abord.
  static List<SpotSuggestion> bestSpots(List<Space> spaces, List<LightLevel> needs) {
    final result = [
      for (final space in spaces)
        for (final spot in spots(space))
          if (suits(needs, spot)) (space: space, spot: spot),
    ];
    result.sort((a, b) => b.spot.byMoment.length.compareTo(a.spot.byMoment.length));
    return result;
  }

  /// Moment de la journée correspondant à l'heure.
  static DayMoment momentAt(DateTime t) => t.hour < 11
      ? DayMoment.morning
      : t.hour < 15
          ? DayMoment.noon
          : DayMoment.lateAfternoon;
}
