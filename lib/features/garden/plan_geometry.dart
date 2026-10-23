import 'dart:math';
import 'dart:ui';

import '../../models/garden.dart';

/// Calculs du plan (en mètres), indépendants de l'affichage.
class PlanGeometry {
  static const snapStep = 0.25;
  static const minSize = 0.5;

  static double snap(double v) => (v / snapStep).round() * snapStep;

  static Rect rectOf(Space s) => Rect.fromLTWH(s.x, s.y, s.width, s.height);

  /// Ordre de dessin : zones extérieures sous les pièces.
  static List<Space> drawOrder(List<Space> spaces) => [
        ...spaces.where((s) => s.kind == SpaceKind.outdoorZone),
        ...spaces.where((s) => s.kind == SpaceKind.indoorRoom),
      ];

  /// Pièce/zone la plus haute contenant le point.
  static Space? spaceAt(List<Space> spaces, Offset p) {
    for (final s in drawOrder(spaces).reversed) {
      if (rectOf(s).contains(p)) return s;
    }
    return null;
  }

  /// Poignée de redimensionnement : coin bas-droit.
  static Offset handleOf(Space s) => Offset(s.x + s.width, s.y + s.height);

  static bool onHandle(Space s, Offset p, double tolerance) => (handleOf(s) - p).distance <= tolerance;

  static void move(Space s, {required Offset origin, required Offset delta}) {
    s
      ..x = max(0, snap(origin.dx + delta.dx))
      ..y = max(0, snap(origin.dy + delta.dy));
  }

  static void resize(Space s, {required Size origin, required Offset delta}) {
    s
      ..width = max(minSize, snap(origin.width + delta.dx))
      ..height = max(minSize, snap(origin.height + delta.dy));
    for (final o in s.openings) {
      clampOpening(s, o);
    }
  }

  /// 0 = haut, 1 = droite, 2 = bas, 3 = gauche.
  static double wallLength(Space s, int wall) => wall.isEven ? s.width : s.height;

  static void clampOpening(Space s, Opening o) {
    final wall = wallLength(s, o.wall);
    o.length = o.length.clamp(min(snapStep, wall), wall);
    o.offset = o.offset.clamp(0, wall - o.length);
  }

  /// Segment de mur occupé par l'ouverture.
  static (Offset, Offset) segmentOf(Space s, Opening o) {
    final a = o.offset, b = o.offset + o.length;
    return switch (o.wall) {
      0 => (Offset(s.x + a, s.y), Offset(s.x + b, s.y)),
      1 => (Offset(s.x + s.width, s.y + a), Offset(s.x + s.width, s.y + b)),
      2 => (Offset(s.x + a, s.y + s.height), Offset(s.x + b, s.y + s.height)),
      _ => (Offset(s.x, s.y + a), Offset(s.x, s.y + b)),
    };
  }

  /// Nouvelle ouverture centrée sur le mur.
  static Opening newOpening(Space s, {required String id, required OpeningKind kind, required int wall}) {
    final wallLen = wallLength(s, wall);
    final length = min(kind == OpeningKind.door ? 0.9 : 1.2, wallLen);
    final o = Opening(id: id, kind: kind, wall: wall, offset: snap((wallLen - length) / 2), length: length);
    clampOpening(s, o);
    return o;
  }
}
