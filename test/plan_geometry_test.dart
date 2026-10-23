import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:garden_party/features/garden/plan_geometry.dart';
import 'package:garden_party/models/garden.dart';

Space _room({double x = 0, double y = 0, double w = 4, double h = 3, SpaceKind kind = SpaceKind.indoorRoom}) =>
    Space(id: '$kind$x', name: 'R', kind: kind, x: x, y: y, width: w, height: h);

void main() {
  test('snap au quart de mètre', () {
    expect(PlanGeometry.snap(1.13), 1.25);
    expect(PlanGeometry.snap(0.1), 0);
  });

  test('les pièces passent devant les zones extérieures', () {
    final zone = _room(w: 10, h: 10, kind: SpaceKind.outdoorZone);
    final room = _room(x: 2, y: 2);
    expect(PlanGeometry.spaceAt([room, zone], const Offset(3, 3)), room);
    expect(PlanGeometry.spaceAt([room, zone], const Offset(9, 9)), zone);
    expect(PlanGeometry.spaceAt([room, zone], const Offset(11, 1)), isNull);
  });

  test('déplacement aimanté et borné à l\'origine', () {
    final r = _room(x: 1, y: 1);
    PlanGeometry.move(r, origin: const Offset(1, 1), delta: const Offset(0.6, -3));
    expect((r.x, r.y), (1.5, 0.0));
  });

  test('redimensionnement : taille minimale et ouvertures recadrées', () {
    final r = _room();
    r.openings = [Opening(id: 'o', kind: OpeningKind.window, wall: 0, offset: 2.5, length: 1.2)];
    PlanGeometry.resize(r, origin: const Size(4, 3), delta: const Offset(-2.9, -10));
    expect((r.width, r.height), (1.0, PlanGeometry.minSize));
    expect(r.openings.single.length, 1.0);
    expect(r.openings.single.offset, 0);
  });

  test('segment d\'une porte sur le mur droit', () {
    final r = _room(x: 1, y: 1);
    final o = Opening(id: 'o', kind: OpeningKind.door, wall: 1, offset: 0.5, length: 1);
    expect(PlanGeometry.segmentOf(r, o), (const Offset(5, 1.5), const Offset(5, 2.5)));
  });

  test('nouvelle ouverture centrée', () {
    final o = PlanGeometry.newOpening(_room(), id: 'o', kind: OpeningKind.door, wall: 0);
    expect(o.length, 0.9);
    expect(o.offset, 1.5);
  });
}
