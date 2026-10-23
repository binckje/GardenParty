import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:garden_party/features/light/light_analysis.dart';
import 'package:garden_party/features/light/light_meter.dart';
import 'package:garden_party/models/garden.dart';

LightReading _r(String id, double x, double y, DayMoment m, double lux, {int minute = 0}) =>
    LightReading(id: id, x: x, y: y, moment: m, estimatedLux: lux, takenAt: DateTime(2026, 6, 1, 10, minute));

Space _room(List<LightReading> readings) => Space(
      id: 's',
      name: 'Salon',
      kind: SpaceKind.indoorRoom,
      x: 0,
      y: 0,
      width: 4,
      height: 3,
      lightReadings: readings,
    );

void main() {
  test('niveau médian : le plus faible des deux du milieu', () {
    expect(LightAnalysis.median([LightLevel.fullSun, LightLevel.shade, LightLevel.brightIndirect]),
        LightLevel.brightIndirect);
    expect(LightAnalysis.median([LightLevel.partialSun, LightLevel.lowLight]), LightLevel.lowLight);
  });

  test('mesures proches regroupées en un point, la plus récente gagne', () {
    final spots = LightAnalysis.spots(_room([
      _r('a', 1, 1, DayMoment.morning, 300),
      _r('b', 1.2, 1, DayMoment.noon, 3000),
      _r('c', 1, 1.1, DayMoment.morning, 600, minute: 5),
      _r('d', 3, 2, DayMoment.noon, 100),
    ]));
    expect(spots, hasLength(2));
    expect(spots.first.byMoment[DayMoment.morning]!.id, 'c');
    expect(spots.first.byMoment, hasLength(2));
    expect(LightAnalysis.spotAt(spots, const Offset(2.9, 2.1)), same(spots.last));
    expect(LightAnalysis.spotAt(spots, const Offset(2, 2)), isNull);
  });

  test('emplacements conseillés selon les besoins de la plante', () {
    final room = _room([
      _r('a', 1, 1, DayMoment.morning, 2000),
      _r('b', 1, 1, DayMoment.noon, 4000),
      _r('c', 3, 2, DayMoment.noon, 3000),
      _r('d', 2, 0.5, DayMoment.noon, 100),
    ]);
    final best = LightAnalysis.bestSpots([room], [LightLevel.brightIndirect, LightLevel.partialSun]);
    expect([for (final b in best) b.spot.position], [const Offset(1, 1), const Offset(3, 2)]);
    expect(LightAnalysis.bestSpots([room], [LightLevel.fullSun]), isEmpty);
  });

  test('moment de la journée selon l\'heure', () {
    expect(LightAnalysis.momentAt(DateTime(2026, 1, 1, 9)), DayMoment.morning);
    expect(LightAnalysis.momentAt(DateTime(2026, 1, 1, 13)), DayMoment.noon);
    expect(LightAnalysis.momentAt(DateTime(2026, 1, 1, 17)), DayMoment.lateAfternoon);
  });

  test('luminance linéaire d\'une image sRGB', () {
    expect(LightMeter.meanLuminance(Uint8List.fromList([255, 255, 255, 255, 0, 0, 0, 255])), closeTo(0.5, 1e-9));
    // Gris sRGB 128 ≈ 21,6 % de luminance linéaire.
    expect(LightMeter.meanLuminance(Uint8List.fromList([128, 128, 128, 255])), closeTo(0.216, 0.001));
  });
}
