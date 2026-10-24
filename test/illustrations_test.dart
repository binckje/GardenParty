import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_party/features/calendar/care_service.dart';
import 'package:garden_party/features/illustrations/illustration_settings.dart';
import 'package:garden_party/features/illustrations/kawaii_illustration.dart';
import 'package:garden_party/features/illustrations/mascot_painter.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 10 10"><circle cx="5" cy="5" r="4" fill="pink"/></svg>';

Future<ProviderContainer> _container(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  final prefs = await SharedPreferences.getInstance();
  return ProviderContainer(overrides: [prefsProvider.overrideWithValue(prefs)]);
}

Future<void> _pump(WidgetTester tester, ProviderContainer c) => tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: Scaffold(body: KawaiiIllustration(IllustrationScene.emptyPlants))),
    ));

void main() {
  test('style et SVG enregistrés dans les préférences', () async {
    final c = await _container({});
    expect(c.read(illustrationSettingsProvider).style, IllustrationStyle.drawn);
    await c.read(illustrationSettingsProvider.notifier).setStyle(IllustrationStyle.custom);
    await c.read(illustrationSettingsProvider.notifier).setSvg(IllustrationScene.allDone, _svg);

    final prefs = c.read(prefsProvider);
    final again = ProviderContainer(overrides: [prefsProvider.overrideWithValue(prefs)]);
    final s = again.read(illustrationSettingsProvider);
    expect(s.style, IllustrationStyle.custom);
    expect(s.customSvgs[IllustrationScene.allDone], _svg);

    await again.read(illustrationSettingsProvider.notifier).setSvg(IllustrationScene.allDone, null);
    expect(prefs.getString(IllustrationSettingsNotifier.svgKey(IllustrationScene.allDone)), isNull);
  });

  test('sans préférences : réglages par défaut', () {
    expect(ProviderContainer().read(illustrationSettingsProvider).style, IllustrationStyle.drawn);
  });

  test('looksLikeSvg', () {
    expect(looksLikeSvg(_svg), isTrue);
    expect(looksLikeSvg('{"a":1}'), isFalse);
  });

  testWidgets('rendu selon le style', (tester) async {
    final c = await _container({IllustrationSettingsNotifier.styleKey: 'emoji'});
    await _pump(tester, c);
    await tester.pumpAndSettle();
    expect(find.text('🪴'), findsOneWidget);

    await c.read(illustrationSettingsProvider.notifier).setStyle(IllustrationStyle.drawn);
    await tester.pumpAndSettle();
    expect(find.byWidgetPredicate((w) => w is CustomPaint && w.painter is MascotPainter), findsOneWidget);

    // Style SVG sans image pour la scène : repli sur le dessin.
    await c.read(illustrationSettingsProvider.notifier).setStyle(IllustrationStyle.custom);
    await tester.pumpAndSettle();
    expect(find.byType(SvgPicture), findsNothing);
    expect(find.byWidgetPredicate((w) => w is CustomPaint && w.painter is MascotPainter), findsOneWidget);

    await c.read(illustrationSettingsProvider.notifier).setSvg(IllustrationScene.emptyPlants, _svg);
    await tester.pumpAndSettle();
    expect(find.byType(SvgPicture), findsOneWidget);
  });
}
