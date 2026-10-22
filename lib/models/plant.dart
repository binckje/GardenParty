import 'garden.dart';

/// Fiche d'identité d'une espèce (données issues des API ou de la base locale).
class PlantSpecies {
  PlantSpecies({
    required this.id,
    required this.scientificName,
    required this.commonName,
    this.imageUrl,
    required this.light,
    required this.minTempC,
    required this.maxTempC,
    required this.soil,
    required this.watering,
    required this.fertilizing,
    this.diagnostics = const [],
    this.cutting,
    this.repotting,
  });

  final String id;
  final String scientificName;
  final String commonName;
  final String? imageUrl;
  final List<LightLevel> light;
  final double minTempC, maxTempC;
  final String soil;
  final CareSchedule watering;
  final CareSchedule fertilizing;
  final List<Diagnostic> diagnostics;
  final PropagationInfo? cutting;
  final RepottingInfo? repotting;
}

class CareSchedule {
  const CareSchedule({required this.everyDays, required this.quantity, this.activeMonths = const [3, 4, 5, 6, 7, 8, 9]});

  final int everyDays;
  final String quantity;

  /// Mois (1-12) où le soin s'applique ; hors saison la fréquence est réduite.
  final List<int> activeMonths;
}

class Diagnostic {
  const Diagnostic({required this.symptom, required this.cause, required this.treatment});

  final String symptom, cause, treatment;
}

class PropagationInfo {
  const PropagationInfo({required this.possible, this.method});

  final bool possible;
  final String? method;
}

class RepottingInfo {
  const RepottingInfo({required this.needed, this.everyYears, this.period});

  final bool needed;
  final int? everyYears;
  final String? period;
}

/// Plante possédée par l'utilisateur, placée dans une pièce/zone.
class OwnedPlant {
  OwnedPlant({required this.id, required this.speciesId, required this.nickname, this.spaceId, this.x, this.y});

  final String id;
  final String speciesId;
  String nickname;
  String? spaceId;
  double? x, y;
}
