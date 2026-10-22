import 'package:flutter_test/flutter_test.dart';
import 'package:garden_party/models/care.dart';
import 'package:garden_party/models/garden.dart';

void main() {
  test('LightReading catégorise le lux', () {
    LightReading r(double lux) => LightReading(id: 'r', x: 0, y: 0, moment: DayMoment.noon, estimatedLux: lux, takenAt: DateTime(2026));
    expect(r(100).level, LightLevel.shade);
    expect(r(3000).level, LightLevel.brightIndirect);
    expect(r(50000).level, LightLevel.fullSun);
  });

  test('CareTask en retard tant que non validé', () {
    final t = CareTask(id: 't', plantId: 'p', type: CareType.watering, dueAt: DateTime(2026, 1, 1));
    expect(t.isOverdue(DateTime(2026, 1, 2)), isTrue);
    t.doneAt = DateTime(2026, 1, 2);
    expect(t.isOverdue(DateTime(2026, 1, 3)), isFalse);
  });
}
