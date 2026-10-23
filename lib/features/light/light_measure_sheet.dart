import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../models/garden.dart';
import 'light_meter.dart';

typedef LightMeasure = Future<double?> Function(BuildContext context, DayMoment moment);

/// Ouvre la feuille de mesure ; remplaçable dans les tests.
final lightMeasureProvider = Provider<LightMeasure>((ref) => showLightMeasureSheet);

/// Mesure la lumière (capteur, caméra ou saisie) ; renvoie des lux, ou null si annulé.
Future<double?> showLightMeasureSheet(BuildContext context, DayMoment moment) => showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => LightMeasureSheet(moment: moment),
    );

class LightMeasureSheet extends StatefulWidget {
  const LightMeasureSheet({super.key, required this.moment});

  final DayMoment moment;

  @override
  State<LightMeasureSheet> createState() => _LightMeasureSheetState();
}

class _LightMeasureSheetState extends State<LightMeasureSheet> {
  late LightSource _source = LightMeter.available.first;

  @override
  Widget build(BuildContext context) {
    final sources = LightMeter.available;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 16 + MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('☀️ Lumière · ${dayMomentLabels[widget.moment]}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            if (sources.length > 1)
              SegmentedButton<LightSource>(
                segments: [
                  for (final s in sources)
                    ButtonSegment(
                      value: s,
                      label: Text(switch (s) {
                        LightSource.sensor => 'Capteur',
                        LightSource.camera => 'Caméra',
                        LightSource.manual => 'Saisie',
                      }),
                    ),
                ],
                selected: {_source},
                onSelectionChanged: (s) => setState(() => _source = s.single),
              ),
            const SizedBox(height: 12),
            switch (_source) {
              LightSource.sensor => const _SensorMeasure(),
              LightSource.camera => const _CameraMeasure(),
              LightSource.manual => const _ManualMeasure(),
            },
          ],
        ),
      ),
    );
  }
}

Widget _reading(BuildContext context, double lux) {
  final level = lightLevelFor(lux);
  return Column(children: [
    Text('${lux.round()} lx', style: Theme.of(context).textTheme.headlineMedium),
    Chip(
      backgroundColor: lightLevelColors[level],
      label: Text(lightLevelLabels[level]!),
    ),
  ]);
}

/// Capteur de luminosité Android : moyenne glissante des dernières valeurs.
class _SensorMeasure extends StatefulWidget {
  const _SensorMeasure();

  @override
  State<_SensorMeasure> createState() => _SensorMeasureState();
}

class _SensorMeasureState extends State<_SensorMeasure> {
  StreamSubscription<int>? _sub;
  final _values = <int>[];
  Object? _error;

  double? get _lux => _values.isEmpty ? null : _values.reduce((a, b) => a + b) / _values.length;

  @override
  void initState() {
    super.initState();
    _sub = LightMeter.sensorStream().listen(
      (v) => setState(() {
        _values.add(v);
        if (_values.length > 5) _values.removeAt(0);
      }),
      onError: (Object e) => setState(() => _error = e),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lux = _lux;
    if (_error != null) return Text('Capteur indisponible : $_error');
    return Column(mainAxisSize: MainAxisSize.min, children: [
      const Text("Pose le téléphone à plat à l'endroit de la plante, écran vers le ciel."),
      const SizedBox(height: 12),
      if (lux == null) const Center(child: CircularProgressIndicator()) else _reading(context, lux),
      const SizedBox(height: 12),
      FilledButton(onPressed: lux == null ? null : () => Navigator.pop(context, lux), child: const Text('Enregistrer')),
    ]);
  }
}

/// Caméra : luminance moyenne de la photo × facteur de calibrage.
class _CameraMeasure extends ConsumerStatefulWidget {
  const _CameraMeasure();

  @override
  ConsumerState<_CameraMeasure> createState() => _CameraMeasureState();
}

class _CameraMeasureState extends ConsumerState<_CameraMeasure> {
  CameraController? _controller;
  double? _factor;
  bool _calibrated = false, _busy = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final saved = await ref.read(settingsRepositoryProvider).getDouble(LightMeter.calibrationKey);
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw 'aucune caméra';
      final camera =
          cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.back, orElse: () => cameras.first);
      final controller = CameraController(camera, ResolutionPreset.low, enableAudio: false);
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _factor = saved ?? LightMeter.defaultCalibration;
        _calibrated = saved != null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<double?> _luminance() async {
    setState(() => _busy = true);
    try {
      final photo = await _controller!.takePicture();
      return await LightMeter.photoLuminance(await photo.readAsBytes());
    } catch (e) {
      if (mounted) setState(() => _error = e);
      return null;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _measure() async {
    final y = await _luminance();
    if (y != null && mounted) Navigator.pop(context, y * _factor!);
  }

  Future<void> _calibrate() async {
    final y = await _luminance();
    if (y == null || y <= 0 || !mounted) return;
    final lux = await _askReferenceLux(context);
    if (lux == null) return;
    final factor = lux / y;
    await ref.read(settingsRepositoryProvider).setDouble(LightMeter.calibrationKey, factor);
    setState(() {
      _factor = factor;
      _calibrated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (_error != null) return Text('Caméra indisponible : $_error');
    if (controller == null) return const Center(child: CircularProgressIndicator());
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SizedBox(height: 200, child: Center(child: CameraPreview(controller))),
      const SizedBox(height: 8),
      Text(
        _calibrated
            ? "Vise l'endroit de la plante depuis sa place, vers la source de lumière. Estimation approximative."
            : 'Caméra non calibrée : valeurs très approximatives. Calibre-la une fois avec une valeur connue.',
        style: const TextStyle(fontSize: 12),
      ),
      const SizedBox(height: 8),
      Row(children: [
        TextButton(onPressed: _busy ? null : _calibrate, child: const Text('Calibrer')),
        const Spacer(),
        FilledButton(onPressed: _busy ? null : _measure, child: const Text('Mesurer')),
      ]),
    ]);
  }
}

/// Lux de référence pour le calibrage : valeur du capteur, d'un luxmètre ou repère qualitatif.
Future<double?> _askReferenceLux(BuildContext context) async {
  final controller = TextEditingController();
  if (LightMeter.hasSensor) {
    try {
      final v = await LightMeter.sensorStream().first.timeout(const Duration(seconds: 2));
      controller.text = '$v';
    } catch (_) {}
  }
  if (!context.mounted) return null;
  return showDialog<double>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Valeur de référence'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Lux réels à cet endroit (capteur, luxmètre), ou choisis un repère.'),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Lux'),
        ),
        Wrap(spacing: 4, children: [
          for (final p in lightPresets)
            ActionChip(label: Text(p.emoji), tooltip: p.label, onPressed: () => controller.text = '${p.lux.round()}'),
        ]),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('Annuler')),
        FilledButton(
            onPressed: () => Navigator.pop(c, double.tryParse(controller.text.replaceAll(',', '.'))),
            child: const Text('OK')),
      ],
    ),
  );
}

/// Saisie : repère qualitatif ou valeur d'un luxmètre.
class _ManualMeasure extends StatefulWidget {
  const _ManualMeasure();

  @override
  State<_ManualMeasure> createState() => _ManualMeasureState();
}

class _ManualMeasureState extends State<_ManualMeasure> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final lux = double.tryParse(_controller.text.replaceAll(',', '.'));
    if (lux != null && lux >= 0) Navigator.pop(context, lux);
  }

  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
        for (final p in lightPresets)
          ListTile(
            leading: Text(p.emoji, style: const TextStyle(fontSize: 24)),
            title: Text(p.label),
            subtitle: Text('≈ ${p.lux.round()} lx'),
            onTap: () => Navigator.pop(context, p.lux),
          ),
        Row(children: [
          Expanded(
            child: TextField(
              key: const Key('lux'),
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Ou valeur mesurée (lux)'),
              onSubmitted: (_) => _submit(),
            ),
          ),
          IconButton(tooltip: 'Valider', icon: const Icon(Icons.check), onPressed: _submit),
        ]),
      ]);
}
