import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:garden_party/features/garden/plan_geometry.dart';
import 'package:garden_party/models/garden.dart';
import 'package:garden_party/models/plant.dart';

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

  test('plante : position relative à sa pièce, suit son déplacement, reste dedans', () {
    final room = Space(id: 'r', name: 'R', kind: SpaceKind.indoorRoom, x: 2, y: 1, width: 4, height: 3);
    final plant = OwnedPlant(id: 'p', speciesId: 's', nickname: 'P');
    expect(PlanGeometry.plantPosition(plant, [room]), isNull);

    expect(PlanGeometry.placePlant(plant, [room], const Offset(3, 2.5)), isTrue);
    expect((plant.spaceId, plant.x, plant.y), ('r', 1.0, 1.5));

    room.x = 5;
    expect(PlanGeometry.plantPosition(plant, [room]), const Offset(6, 2.5));
    room.width = 0.5;
    expect(PlanGeometry.plantPosition(plant, [room]), const Offset(5.5, 2.5));

    expect(PlanGeometry.placePlant(plant, [room], const Offset(20, 20)), isFalse);
    expect(plant.spaceId, 'r');
  });

  test('plantAt : plante la plus proche dans la tolérance', () {
    final room = Space(id: 'r', name: 'R', kind: SpaceKind.indoorRoom, x: 0, y: 0, width: 4, height: 3);
    final a = OwnedPlant(id: 'a', speciesId: 's', nickname: 'A', spaceId: 'r', x: 1, y: 1);
    final b = OwnedPlant(id: 'b', speciesId: 's', nickname: 'B', spaceId: 'r', x: 1.3, y: 1);
    expect(PlanGeometry.plantAt([a, b], [room], const Offset(1.2, 1), 0.4)?.id, 'b');
    expect(PlanGeometry.plantAt([a, b], [room], const Offset(3, 3), 0.4), isNull);
  });
}
