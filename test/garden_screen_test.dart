import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_party/data/garden_repository.dart';
import 'package:garden_party/data/providers.dart';
import 'package:garden_party/features/garden/garden_screen.dart';
import 'package:garden_party/models/garden.dart';

class _FakeRepo implements GardenRepository {
  final saved = <Space>[];

  @override
  Future<void> saveSpace(Space s) async => saved.add(s.copy());

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

void main() {
  testWidgets('sélection puis déplacement d\'une pièce', (tester) async {
    final repo = _FakeRepo();
    final salon = Space(id: 's', name: 'Salon', kind: SpaceKind.indoorRoom, x: 1, y: 1, width: 4, height: 3);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        spacesProvider.overrideWith((ref) => Stream.value([salon])),
        gardenRepositoryProvider.overrideWithValue(repo),
      ],
      child: const MaterialApp(home: GardenScreen()),
    ));
    await tester.pump();
    expect(find.byKey(const Key('selection')), findsNothing);

    // Vue par défaut : 40 px/m, origine décalée de 24 px sous l'AppBar.
    final plan = tester.getTopLeft(find.byKey(const Key('plan')));
    final inside = plan + const Offset(24 + 3 * 40, 24 + 2 * 40);
    await tester.tapAt(inside);
    await tester.pump();
    expect(find.byKey(const Key('selection')), findsOneWidget);

    await tester.dragFrom(inside, const Offset(80, 0));
    await tester.pump();
    expect(repo.saved.last.x, closeTo(3, 0.25));
    expect(repo.saved.last.y, 1);
  });
}
