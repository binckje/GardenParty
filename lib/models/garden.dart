/// Plan du jardin vu de dessus. Coordonnées en mètres, origine en haut à gauche.
enum SpaceKind { indoorRoom, outdoorZone }

enum OpeningKind { door, window }

enum DayMoment { morning, noon, lateAfternoon }

/// Niveau de lumière catégorisé, commun aux mesures et aux besoins des plantes.
enum LightLevel { shade, lowLight, brightIndirect, partialSun, fullSun }

class Space {
  Space({
    required this.id,
    required this.name,
    required this.kind,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.openings = const [],
    this.lightReadings = const [],
  });

  final String id;
  String name;
  final SpaceKind kind;
  double x, y, width, height;
  List<Opening> openings;
  List<LightReading> lightReadings;

  /// Copie modifiable (ouvertures dupliquées) pour l'édition du plan.
  Space copy() => Space(
        id: id,
        name: name,
        kind: kind,
        x: x,
        y: y,
        width: width,
        height: height,
        openings: [for (final o in openings) o.copy()],
        lightReadings: lightReadings,
      );
}

/// Porte ou fenêtre posée sur un mur d'une pièce.
class Opening {
  Opening({required this.id, required this.kind, required this.wall, required this.offset, required this.length});

  final String id;
  final OpeningKind kind;

  /// 0 = haut, 1 = droite, 2 = bas, 3 = gauche.
  final int wall;
  double offset, length;

  Opening copy({int? wall}) => Opening(id: id, kind: kind, wall: wall ?? this.wall, offset: offset, length: length);
}

/// Mesure de luminosité prise avec la caméra à un point donné de la pièce.
class LightReading {
  LightReading({
    required this.id,
    required this.x,
    required this.y,
    required this.moment,
    required this.estimatedLux,
    required this.takenAt,
  });

  final String id;
  final double x, y;
  final DayMoment moment;
  final double estimatedLux;
  final DateTime takenAt;

  LightLevel get level => lightLevelFor(estimatedLux);
}

LightLevel lightLevelFor(double lux) => switch (lux) {
      < 250 => LightLevel.shade,
      < 1000 => LightLevel.lowLight,
      < 5000 => LightLevel.brightIndirect,
      < 20000 => LightLevel.partialSun,
      _ => LightLevel.fullSun,
    };
