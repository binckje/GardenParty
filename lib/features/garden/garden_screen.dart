import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/providers.dart';
import '../../models/garden.dart';
import '../light/light_analysis.dart';
import '../light/light_measure_sheet.dart';
import '../light/light_meter.dart';
import 'plan_geometry.dart';
import 'plan_painter.dart';

const _uuid = Uuid();
const _walls = ['Haut', 'Droite', 'Bas', 'Gauche'];

enum _Drag { none, pan, move, resize }

/// Éditeur du plan vu de dessus : pièces, zones, portes et fenêtres.
/// En mode lumière : mesures par point et carte de chaleur.
class GardenScreen extends ConsumerStatefulWidget {
  const GardenScreen({super.key});

  @override
  ConsumerState<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends ConsumerState<GardenScreen> {
  PlanView _view = const PlanView(scale: 40, pan: Offset(24, 24));
  String? _selectedId;

  /// Mode lumière ; [_moment] null = bilan (niveau médian de chaque point).
  bool _light = false;
  DayMoment? _moment = LightAnalysis.momentAt(DateTime.now());

  /// Copie en cours d'édition, affichée à la place de la version enregistrée.
  Space? _draft;

  // État du geste en cours.
  _Drag _drag = _Drag.none;
  Offset _startFocal = Offset.zero;
  PlanView _startView = const PlanView(scale: 40, pan: Offset.zero);
  Offset _startPos = Offset.zero;
  Size _startSize = Size.zero;

  /// Position du doigt au contact : le geste démarre ici, pas après le seuil de glissement.
  Offset? _downPos;

  List<Space> _spaces() {
    final saved = ref.read(spacesProvider).valueOrNull ?? const [];
    return [for (final s in saved) s.id == _draft?.id ? _draft! : s];
  }

  Space? get _selected => _spaces().where((s) => s.id == _selectedId).firstOrNull;

  Future<void> _save(Space s) => ref.read(gardenRepositoryProvider).saveSpace(s);

  void _edit(void Function(Space s) change) {
    final s = (_draft?.id == _selectedId ? _draft : _selected?.copy());
    if (s == null) return;
    setState(() {
      change(s);
      _draft = s;
    });
    _save(s);
  }

  // --- Gestes ---

  void _onScaleStart(ScaleStartDetails d) {
    _startFocal = d.pointerCount == 1 ? _downPos ?? d.localFocalPoint : d.localFocalPoint;
    _startView = _view;
    _drag = _Drag.pan;
    if (d.pointerCount > 1 || _light) return;
    final p = _view.toWorld(_startFocal);
    final selected = _selected;
    if (selected != null && PlanGeometry.onHandle(selected, p, PlanPainter.handleRadius * 2 / _view.scale)) {
      _beginEdit(selected, _Drag.resize);
      return;
    }
    final hit = PlanGeometry.spaceAt(_spaces(), p);
    if (hit != null) {
      _selectedId = hit.id;
      _beginEdit(hit, _Drag.move);
    }
  }

  void _beginEdit(Space s, _Drag mode) {
    setState(() {
      _draft = s.copy();
      _drag = mode;
      _startPos = Offset(s.x, s.y);
      _startSize = Size(s.width, s.height);
    });
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    if (d.pointerCount > 1 && _drag != _Drag.pan) {
      // Deuxième doigt posé pendant un déplacement : on passe en zoom.
      _drag = _Drag.pan;
      _startFocal = d.localFocalPoint;
      _startView = _view;
    }
    final delta = (d.localFocalPoint - _startFocal) / _view.scale;
    setState(() {
      switch (_drag) {
        case _Drag.move:
          PlanGeometry.move(_draft!, origin: _startPos, delta: delta);
        case _Drag.resize:
          PlanGeometry.resize(_draft!, origin: _startSize, delta: delta);
        case _Drag.pan:
          _view = _zoomed(_startView, _startFocal, d.localFocalPoint, d.scale);
        case _Drag.none:
          break;
      }
    });
  }

  void _onScaleEnd(ScaleEndDetails d) {
    if ((_drag == _Drag.move || _drag == _Drag.resize) && _draft != null) _save(_draft!);
    _drag = _Drag.none;
  }

  /// Zoom autour du point focal, borné entre 10 et 200 px/m.
  static PlanView _zoomed(PlanView start, Offset startFocal, Offset focal, double factor) {
    final scale = (start.scale * factor).clamp(10.0, 200.0);
    final anchor = start.toWorld(startFocal);
    return PlanView(scale: scale, pan: focal - anchor * scale);
  }

  void _onPointerSignal(PointerSignalEvent e) {
    if (e is! PointerScrollEvent) return;
    setState(() => _view = _zoomed(_view, e.localPosition, e.localPosition, e.scrollDelta.dy > 0 ? 0.9 : 1.1));
  }

  void _onTapUp(TapUpDetails d) {
    final p = _view.toWorld(d.localPosition);
    final hit = PlanGeometry.spaceAt(_spaces(), p);
    if (_light) {
      if (hit != null) _tapLight(hit, p);
      return;
    }
    setState(() => _selectedId = hit?.id);
  }

  // --- Actions ---

  /// Toucher un point : mesure (ou nouvelle mesure) pour le moment choisi, ou suppression du point.
  Future<void> _tapLight(Space s, Offset p) async {
    final moment = _moment;
    if (moment == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Choisis un moment pour mesurer.')));
      return;
    }
    final spot = LightAnalysis.spotAt(LightAnalysis.spots(s), p);
    if (spot != null) {
      final action = await showModalBottomSheet<String>(
        context: context,
        showDragHandle: true,
        builder: (c) => SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            for (final m in DayMoment.values)
              ListTile(
                dense: true,
                title: Text(dayMomentLabels[m]!),
                trailing: Text(switch (spot.byMoment[m]) {
                  final r? => '${r.estimatedLux.round()} lx · ${lightLevelLabels[r.level]}',
                  null => '—',
                }),
              ),
            ListTile(
              leading: const Icon(Icons.wb_sunny_outlined),
              title: Text('Mesurer (${dayMomentLabels[moment]})'),
              onTap: () => Navigator.pop(c, 'measure'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Supprimer ce point'),
              onTap: () => Navigator.pop(c, 'delete'),
            ),
          ]),
        ),
      );
      if (action == 'delete') {
        final ids = {for (final r in spot.byMoment.values) r.id};
        await _save(s.copy()..lightReadings = s.lightReadings.where((r) => !ids.contains(r.id)).toList());
        return;
      }
      if (action != 'measure') return;
    }
    if (!mounted) return;
    final lux = await ref.read(lightMeasureProvider)(context, moment);
    if (lux == null) return;
    final at = spot?.position ?? Offset(PlanGeometry.snap(p.dx), PlanGeometry.snap(p.dy));
    final replaced = spot?.byMoment[moment]?.id;
    await _save(s.copy()
      ..lightReadings = [
        ...s.lightReadings.where((r) => r.id != replaced),
        LightReading(id: _uuid.v4(), x: at.dx, y: at.dy, moment: moment, estimatedLux: lux, takenAt: DateTime.now()),
      ]);
  }

  Future<void> _addSpace(SpaceKind kind, Size viewport) async {
    final indoor = kind == SpaceKind.indoorRoom;
    final name = await _askName(context,
        title: indoor ? 'Nouvelle pièce' : 'Nouvelle zone', initial: indoor ? 'Salon' : 'Terrasse');
    if (name == null) return;
    final center = _view.toWorld(viewport.center(Offset.zero));
    final s = Space(
      id: _uuid.v4(),
      name: name,
      kind: kind,
      x: max(0, PlanGeometry.snap(center.dx - 2)),
      y: max(0, PlanGeometry.snap(center.dy - 1.5)),
      width: 4,
      height: 3,
    );
    await _save(s);
    setState(() => _selectedId = s.id);
  }

  Future<void> _rename(Space s) async {
    final name = await _askName(context, title: 'Renommer', initial: s.name);
    if (name != null) _edit((s) => s.name = name);
  }

  Future<void> _delete(Space s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Supprimer « ${s.name} » ?'),
        content: const Text('Ses portes, fenêtres et mesures de lumière seront supprimées.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(gardenRepositoryProvider).deleteSpace(s.id);
    setState(() {
      _selectedId = null;
      _draft = null;
    });
  }

  void _addOpening(OpeningKind kind) {
    late Opening created;
    _edit((s) {
      created = PlanGeometry.newOpening(s, id: _uuid.v4(), kind: kind, wall: 0);
      s.openings = [...s.openings, created];
    });
    _editOpening(created.id);
  }

  Future<void> _editOpening(String openingId) => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (_) => StatefulBuilder(builder: (context, setSheet) {
          final s = _draft?.id == _selectedId ? _draft : _selected;
          final o = s?.openings.where((o) => o.id == openingId).firstOrNull;
          if (s == null || o == null) return const SizedBox.shrink();
          final wallLen = PlanGeometry.wallLength(s, o.wall);
          void change(void Function(Space s) f) {
            _edit(f);
            setSheet(() {});
          }

          Opening target(Space s) => s.openings.firstWhere((x) => x.id == openingId);
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(o.kind == OpeningKind.door ? '🚪 Porte' : '🪟 Fenêtre',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                SegmentedButton<int>(
                  segments: [for (var i = 0; i < 4; i++) ButtonSegment(value: i, label: Text(_walls[i]))],
                  selected: {o.wall},
                  onSelectionChanged: (w) => change((s) {
                    final i = s.openings.indexWhere((x) => x.id == openingId);
                    final moved = s.openings[i].copy(wall: w.single);
                    PlanGeometry.clampOpening(s, moved);
                    s.openings = [...s.openings]..[i] = moved;
                  }),
                ),
                const SizedBox(height: 8),
                Text('Position : ${o.offset.toStringAsFixed(2)} m'),
                Slider(
                  value: o.offset,
                  max: max(0, wallLen - o.length),
                  onChanged: wallLen > o.length
                      ? (v) => change((s) => target(s).offset = PlanGeometry.snap(v).clamp(0, wallLen - o.length))
                      : null,
                ),
                Text('Largeur : ${o.length.toStringAsFixed(2)} m'),
                Slider(
                  value: o.length,
                  min: min(PlanGeometry.snapStep, wallLen),
                  max: wallLen,
                  onChanged: (v) => change((s) {
                    target(s).length = PlanGeometry.snap(v);
                    PlanGeometry.clampOpening(s, target(s));
                  }),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Retirer'),
                    onPressed: () {
                      _edit((s) => s.openings = s.openings.where((x) => x.id != openingId).toList());
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          );
        }),
      );

  // --- Affichage ---

  @override
  Widget build(BuildContext context) {
    ref.listen(spacesProvider, (_, next) {
      // La base a enregistré la modification : la copie locale n'est plus utile.
      if (next.hasValue && _drag == _Drag.none) setState(() => _draft = null);
    });
    final async = ref.watch(spacesProvider);
    final spaces = _spaces();
    final selected = _selected;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon jardin'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            key: const Key('lightMode'),
            tooltip: _light ? 'Quitter le mode lumière' : 'Mode lumière',
            isSelected: _light,
            icon: const Icon(Icons.wb_sunny_outlined),
            selectedIcon: const Icon(Icons.wb_sunny),
            onPressed: () => setState(() {
              _light = !_light;
              _selectedId = null;
            }),
          ),
          IconButton(
            tooltip: 'Recentrer',
            icon: const Icon(Icons.center_focus_strong_outlined),
            onPressed: () => setState(() => _view = const PlanView(scale: 40, pan: Offset(24, 24))),
          ),
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final viewport = constraints.biggest;
        return Stack(
          children: [
            Positioned.fill(
              child: Listener(
                onPointerSignal: _onPointerSignal,
                onPointerDown: (e) => _downPos = e.localPosition,
                child: GestureDetector(
                  key: const Key('plan'),
                  onTapUp: _onTapUp,
                  onScaleStart: _onScaleStart,
                  onScaleUpdate: _onScaleUpdate,
                  onScaleEnd: _onScaleEnd,
                  child: CustomPaint(
                      painter: PlanPainter(
                          spaces: spaces, view: _view, selectedId: _selectedId, light: _light, moment: _moment)),
                ),
              ),
            ),
            if (async.isLoading) const Center(child: CircularProgressIndicator()),
            if (async.hasError) Center(child: Text('Erreur de chargement : ${async.error}')),
            if (async.hasValue && spaces.isEmpty)
              const IgnorePointer(
                child: Center(child: Text('🌱\nAjoute ta première pièce ou zone', textAlign: TextAlign.center)),
              ),
            if (_light) Positioned(left: 12, right: 12, bottom: 12, child: _lightPanel()),
            if (!_light)
              Positioned(
                right: 16,
                bottom: 16,
                child: selected == null
                    ? FloatingActionButton.extended(
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter'),
                        onPressed: () => _chooseKind(viewport),
                      )
                    : const SizedBox.shrink(),
              ),
            if (selected != null && !_light)
              Positioned(left: 12, right: 12, bottom: 12, child: _selectionPanel(selected)),
          ],
        );
      }),
    );
  }

  Widget _lightPanel() => Card(
        key: const Key('lightPanel'),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<DayMoment?>(
                showSelectedIcon: false,
                segments: [
                  for (final m in DayMoment.values) ButtonSegment(value: m, label: Text(dayMomentLabels[m]!)),
                  const ButtonSegment(value: null, label: Text('Bilan')),
                ],
                selected: {_moment},
                onSelectionChanged: (m) => setState(() => _moment = m.single),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(spacing: 10, runSpacing: 2, alignment: WrapAlignment.center, children: [
              for (final l in LightLevel.values)
                Row(mainAxisSize: MainAxisSize.min, children: [
                  CircleAvatar(radius: 5, backgroundColor: lightLevelColors[l]),
                  const SizedBox(width: 4),
                  Text(lightLevelLabels[l]!, style: const TextStyle(fontSize: 11)),
                ]),
            ]),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _moment == null ? 'Niveau médian des 3 moments.' : 'Touche un endroit d\'une pièce pour mesurer.',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ]),
        ),
      );

  Future<void> _chooseKind(Size viewport) async {
    final kind = await showModalBottomSheet<SpaceKind>(
      context: context,
      showDragHandle: true,
      builder: (c) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Text('🛋️', style: TextStyle(fontSize: 24)),
            title: const Text('Pièce intérieure'),
            onTap: () => Navigator.pop(c, SpaceKind.indoorRoom),
          ),
          ListTile(
            leading: const Text('🌳', style: TextStyle(fontSize: 24)),
            title: const Text('Zone extérieure'),
            onTap: () => Navigator.pop(c, SpaceKind.outdoorZone),
          ),
        ]),
      ),
    );
    if (kind != null) await _addSpace(kind, viewport);
  }

  Widget _selectionPanel(Space s) => Card(
        key: const Key('selection'),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Text(s.name, style: Theme.of(context).textTheme.titleMedium)),
                IconButton(tooltip: 'Renommer', icon: const Icon(Icons.edit_outlined), onPressed: () => _rename(s)),
                IconButton(tooltip: 'Supprimer', icon: const Icon(Icons.delete_outline), onPressed: () => _delete(s)),
                IconButton(
                  tooltip: 'Fermer',
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _selectedId = null),
                ),
              ]),
              Wrap(spacing: 8, runSpacing: 4, children: [
                ActionChip(
                    avatar: const Text('🚪'),
                    label: const Text('Porte'),
                    onPressed: () => _addOpening(OpeningKind.door)),
                ActionChip(
                    avatar: const Text('🪟'),
                    label: const Text('Fenêtre'),
                    onPressed: () => _addOpening(OpeningKind.window)),
                for (final o in s.openings)
                  InputChip(
                    label: Text('${o.kind == OpeningKind.door ? 'Porte' : 'Fenêtre'} · ${_walls[o.wall]}'),
                    onPressed: () => _editOpening(o.id),
                  ),
              ]),
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text('Glisse pour déplacer, tire le rond pour redimensionner.', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
      );
}

Future<String?> _askName(BuildContext context, {required String title, required String initial}) {
  final controller = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Nom'),
        onSubmitted: (v) => Navigator.pop(c, v.trim().isEmpty ? null : v.trim()),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('Annuler')),
        FilledButton(
          onPressed: () => Navigator.pop(c, controller.text.trim().isEmpty ? null : controller.text.trim()),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
