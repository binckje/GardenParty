import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../calendar/care_service.dart' show prefsProvider;

/// Rendu des illustrations, choisi dans les réglages.
enum IllustrationStyle {
  drawn('Dessins maison', 'Petit pot mascotte'),
  girl('Petite jardinière', 'Jardinière en salopette'),
  emoji('Emojis', 'Emojis dans une bulle pastel'),
  custom('Mes images SVG', 'Tes fichiers SVG ; à défaut, les dessins maison');

  const IllustrationStyle(this.label, this.description);

  final String label, description;
}

enum MascotMood { happy, sleepy, curious, proud }

/// Endroits de l'app qui affichent une illustration.
enum IllustrationScene {
  emptyPlants('Aucune plante', '🪴', MascotMood.happy, 'girl_plants'),
  emptyGarden('Plan vide', '🌱', MascotMood.curious, 'girl_garden'),
  noCare('Pas de soin (aucune plante)', '💧', MascotMood.sleepy, 'girl_care'),
  allDone('Tous les soins faits', '🌸', MascotMood.proud, 'girl_care'),
  searching('Recherche en cours', '📖', MascotMood.curious, 'girl_searching'),
  notFound('Recherche sans résultat', '🔍', MascotMood.curious, 'girl_not_found');

  const IllustrationScene(this.label, this.emoji, this.mood, this._girl);

  final String label, emoji;
  final MascotMood mood;
  final String _girl;

  /// Dessin de la petite jardinière (`assets/illustrations/`).
  String get girlAsset => 'assets/illustrations/$_girl.svg';
}

class IllustrationSettings {
  const IllustrationSettings({this.style = IllustrationStyle.drawn, this.customSvgs = const {}});

  final IllustrationStyle style;

  /// Contenu SVG importé, par scène.
  final Map<IllustrationScene, String> customSvgs;
}

class IllustrationSettingsNotifier extends Notifier<IllustrationSettings> {
  static const styleKey = 'illustration.style';
  static String svgKey(IllustrationScene s) => 'illustration.svg.${s.name}';

  SharedPreferences? _prefs;

  @override
  IllustrationSettings build() {
    try {
      _prefs = ref.watch(prefsProvider);
    } catch (_) {
      // Préférences absentes (tests de widgets) : réglages par défaut.
      return const IllustrationSettings();
    }
    final prefs = _prefs!;
    final style = IllustrationStyle.values.where((s) => s.name == prefs.getString(styleKey)).firstOrNull;
    return IllustrationSettings(
      style: style ?? IllustrationStyle.drawn,
      customSvgs: {
        for (final s in IllustrationScene.values)
          if (prefs.getString(svgKey(s)) case final svg?) s: svg,
      },
    );
  }

  Future<void> setStyle(IllustrationStyle style) async {
    state = IllustrationSettings(style: style, customSvgs: state.customSvgs);
    await _prefs?.setString(styleKey, style.name);
  }

  /// Enregistre [svg] pour [scene], ou l'efface si null.
  Future<void> setSvg(IllustrationScene scene, String? svg) async {
    final svgs = {...state.customSvgs};
    if (svg == null) {
      svgs.remove(scene);
      await _prefs?.remove(svgKey(scene));
    } else {
      svgs[scene] = svg;
      await _prefs?.setString(svgKey(scene), svg);
    }
    state = IllustrationSettings(style: state.style, customSvgs: svgs);
  }
}

final illustrationSettingsProvider =
    NotifierProvider<IllustrationSettingsNotifier, IllustrationSettings>(IllustrationSettingsNotifier.new);

/// Vérification minimale d'un fichier importé.
bool looksLikeSvg(String text) => text.contains('<svg');
