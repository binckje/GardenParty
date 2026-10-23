import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:light/light.dart';

import '../../models/garden.dart';

enum LightSource { sensor, camera, manual }

/// Repère qualitatif pour la saisie manuelle, avec une valeur typique en lux.
typedef LightPreset = ({String emoji, String label, double lux});

const lightPresets = <LightPreset>[
  (emoji: '🌑', label: 'Pénombre, lecture difficile', lux: 100),
  (emoji: '💡', label: 'Clair, loin des fenêtres', lux: 500),
  (emoji: '🌤️', label: 'Très lumineux, sans soleil direct', lux: 2500),
  (emoji: '🌞', label: 'Soleil direct quelques heures', lux: 10000),
  (emoji: '☀️', label: 'Plein soleil', lux: 30000),
];

const lightLevelLabels = {
  LightLevel.shade: 'Ombre',
  LightLevel.lowLight: 'Faible',
  LightLevel.brightIndirect: 'Vive indirecte',
  LightLevel.partialSun: 'Mi-soleil',
  LightLevel.fullSun: 'Plein soleil',
};

const lightLevelColors = {
  LightLevel.shade: Color(0xFF8E7CC3),
  LightLevel.lowLight: Color(0xFF7FB3D5),
  LightLevel.brightIndirect: Color(0xFF8FD19E),
  LightLevel.partialSun: Color(0xFFFFD166),
  LightLevel.fullSun: Color(0xFFFF9F5A),
};

const dayMomentLabels = {
  DayMoment.morning: 'Matin',
  DayMoment.noon: 'Midi',
  DayMoment.lateAfternoon: "Fin d'après-midi",
};

/// Sources de mesure : capteur (Android), caméra calibrée, saisie manuelle.
class LightMeter {
  /// Clé du facteur de calibrage caméra (lux par unité de luminance) (SharedPreferences).
  static const calibrationKey = 'camera_lux_factor';

  /// Facteur par défaut, très approximatif : une image moyenne (luminance 0,2) ≈ 400 lx.
  static const defaultCalibration = 2000.0;

  static bool get _android => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static bool get hasSensor => _android;

  /// Le plugin camera ne gère pas Linux ; l'iPhone passe par le web.
  static bool get hasCamera => kIsWeb || _android;

  static List<LightSource> get available => [
        if (hasSensor) LightSource.sensor,
        if (hasCamera) LightSource.camera,
        LightSource.manual,
      ];

  static Stream<int> sensorStream() => Light().lightSensorStream;

  /// Luminance relative moyenne (0 à 1, linéaire) d'une image RGBA 8 bits encodée en sRGB.
  static double meanLuminance(Uint8List rgba) {
    final pixels = rgba.length ~/ 4;
    if (pixels == 0) return 0;
    var sum = 0.0;
    for (var i = 0; i < pixels * 4; i += 4) {
      sum += 0.2126 * _linear(rgba[i]) + 0.7152 * _linear(rgba[i + 1]) + 0.0722 * _linear(rgba[i + 2]);
    }
    return sum / pixels;
  }

  static final _linearTable = List<double>.generate(256, (v) {
    final c = v / 255;
    return c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4).toDouble();
  });

  static double _linear(int v) => _linearTable[v];

  /// Luminance d'une photo (JPEG/PNG), réduite à 64 px de large pour aller vite.
  static Future<double> photoLuminance(Uint8List encoded) async {
    final codec = await ui.instantiateImageCodec(encoded, targetWidth: 64);
    final frame = await codec.getNextFrame();
    final data = await frame.image.toByteData(format: ui.ImageByteFormat.rawRgba);
    frame.image.dispose();
    return meanLuminance(data!.buffer.asUint8List());
  }
}
