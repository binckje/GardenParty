import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/providers.dart';
import '../../models/garden.dart';
import '../../models/plant.dart';
import '../dialogs.dart';
import '../plants/plant_screen.dart';
import '../plants/species_view.dart';
import 'plan_geometry.dart';
import 'plan_painter.dart';

const _uuid = Uuid();
const _walls = ['Haut', 'Droite', 'Bas', 'Gauche'];

enum _Drag { none, pan, move, resize, plant }

/// Éditeur du plan vu de dessus : pièces, zones, portes, fenêtres et plantes.
class GardenScreen extends ConsumerStatefulWidget {
  const GardenScreen({super.key});

  @override
  ConsumerState<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends ConsumerState<GardenScreen> {
  PlanView _view = const PlanView(scale: 40, pan: Offset(24, 24));
  String? _selectedId;

  /// Copie en cours d'édition, affichée à la place de la version enregistrée.
  Space? _draft;

  /// Plante en cours de glisser et sa position absolue provisoire.
  OwnedPlant? _draggedPlant;
  Offset _plantPos = Offset.zero;

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

  List<OwnedPlant> _plants() => ref.read(ownedPlantsProvider).valueOrNull ?? const [];

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
    // En mode placement, glisser fait seulement défiler le plan.
    if (d.pointerCount > 1 || ref.read(placingPlantProvider) != null) return;
    final p = _view.toWorld(_startFocal);
    final selected = _selected;
    if (selected != null && PlanGeometry.onHandle(selected, p, PlanPainter.handleRadius * 2 / _view.scale)) {
      _beginEdit(selected, _Drag.resize);
      return;
    }
    final plant = PlanGeometry.plantAt(_plants(), _spaces(), p, PlanPainter.plantRadius / _view.scale);
    if (plant != null) {
      setState(() {
        _draggedPlant = plant.copy();
        _plantPos = _startPos = PlanGeometry.plantPosition(plant, _spaces())!;
        _drag = _Drag.plant;
      });
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
        case _Drag.plant:
          _plantPos = _startPos + delta;
        case _Drag.pan:
          _view = _zoomed(_startView, _startFocal, d.localFocalPoint, d.scale);
        case _Drag.none:
          break;
      }
    });
  }

  void _onScaleEnd(ScaleEndDetails d) {
    if ((_drag == _Drag.move || _drag == _Drag.resize) && _draft != null) _save(_draft!);
    if (_drag == _Drag.plant) {
      final plant = _draggedPlant!;
      // Lâchée hors de toute pièce/zone : elle revient à sa place.
      if (PlanGeometry.placePlant(plant, _spaces(), _plantPos)) {
        ref.read(plantRepositoryProvider).saveOwnedPlant(plant);
      } else {
        setState(() => _draggedPlant = null);
      }
    }
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
    final placingId = ref.read(placingPlantProvider);
    if (placingId != null) {
      _placeAt(placingId, p);
      return;
    }
    final plant = PlanGeometry.plantAt(_plants(), _spaces(), p, PlanPainter.plantRadius / _view.scale);
    if (plant != null) {
      _showPlant(plant);
      return;
    }
    final hit = PlanGeometry.spaceAt(_spaces(), p);
    setState(() => _selectedId = hit?.id);
  }

  // --- Actions ---

  Future<void> _placeAt(String plantId, Offset p) async {
    final plant = _plants().where((x) => x.id == plantId).firstOrNull?.copy();
    if (plant == null) {
      ref.read(placingPlantProvider.notifier).state = null;
      return;
    }
    if (!PlanGeometry.placePlant(plant, _spaces(), p)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Touche une pièce ou une zone')));
      return;
    }
    ref.read(placingPlantProvider.notifier).state = null;
    await ref.read(plantRepositoryProvider).saveOwnedPlant(plant);
  }

  Future<void> _showPlant(OwnedPlant p) {
    final species = ref.read(speciesProvider).valueOrNull?.where((s) => s.id == p.speciesId).firstOrNull;
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (c) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(leading: SpeciesVisual(species), title: Text(p.nickname), subtitle: Text(species?.commonName ?? '')),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Voir la fiche'),
            onTap: () {
              Navigator.pop(c);
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlantScreen(plantId: p.id)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.close),
            title: const Text('Retirer du plan'),
            onTap: () {
              Navigator.pop(c);
              ref.read(plantRepositoryProvider).saveOwnedPlant(p.copy()
                ..spaceId = null
                ..x = null
                ..y = null);
            },
          ),
        ]),
      ),
    );
  }

  Future<void> _addSpace(SpaceKind kind, Size viewport) async {
    final indoor = kind == SpaceKind.indoorRoom;
    final name = await askName(context, title: indoor ? 'Nouvelle pièce' : 'Nouvelle zone', initial: indoor ? 'Salon' : 'Terrasse');
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
    final name = await askName(context, title: 'Renommer', initial: s.name);
    if (name != null) _edit((s) => s.name = name);
  }

  Future<void> _delete(Space s) async {
    final ok = await confirm(
      context,
      title: 'Supprimer « ${s.name} » ?',
      message: 'Ses portes, fenêtres et mesures de lumière seront supprimées. Ses plantes deviendront non placées.',
      action: 'Supprimer',
    );
    if (!ok) return;
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
                Text(o.kind == OpeningKind.door ? '🚪 Porte' : '🪟 Fenêtre', style: Theme.of(context).textTheme.titleLarge),
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
    ref.listen(ownedPlantsProvider, (_, next) {
      if (next.hasValue && _drag == _Drag.none) setState(() => _draggedPlant = null);
    });
    final async = ref.watch(spacesProvider);
    final spaces = _spaces();
    final plants = ref.watch(ownedPlantsProvider).valueOrNull ?? const <OwnedPlant>[];
    final species = {for (final s in ref.watch(speciesProvider).valueOrNull ?? const <PlantSpecies>[]) s.id: s};
    final placingId = ref.watch(placingPlantProvider);
    final placing = plants.where((p) => p.id == placingId).firstOrNull;
    final selected = placing == null ? _selected : null;
    final planPlants = [
      for (final p in plants)
        if (p.id == _draggedPlant?.id)
          PlanPlant(id: p.id, emoji: speciesEmoji(species[p.speciesId]), position: _plantPos)
        else if (PlanGeometry.plantPosition(p, spaces) case final pos?)
          PlanPlant(id: p.id, emoji: speciesEmoji(species[p.speciesId]), position: pos),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon jardin'),
        backgroundColor: Colors.transparent,
        actions: [
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
                      spaces: spaces,
                      view: _view,
                      selectedId: selected?.id,
                      plants: planPlants,
                      draggedPlantId: _draggedPlant?.id,
                    ),
                  ),
                ),
              ),
            ),
            if (async.isLoading) const Center(child: CircularProgressIndicator()),
            if (async.hasError) Center(child: Text('Erreur de chargement : ${async.error}')),
            if (async.hasValue && spaces.isEmpty)
              const IgnorePointer(
                child: Center(child: Text('🌱\nAjoute ta première pièce ou zone', textAlign: TextAlign.center)),
              ),
            Positioned(
              right: 16,
              bottom: 16,
              child: selected == null && placing == null
                  ? FloatingActionButton.extended(
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter'),
                      onPressed: () => _chooseKind(viewport),
                    )
                  : const SizedBox.shrink(),
            ),
            if (selected != null)
              Positioned(left: 12, right: 12, bottom: 12, child: _selectionPanel(selected)),
            if (placing != null)
              Positioned(
                left: 12,
                right: 12,
                top: 12,
                child: Card(
                  key: const Key('placing'),
                  child: ListTile(
                    leading: SpeciesVisual(species[placing.speciesId], size: 32),
                    title: Text('Touche le plan pour poser « ${placing.nickname} »'),
                    trailing: TextButton(
                      onPressed: () => ref.read(placingPlantProvider.notifier).state = null,
                      child: const Text('Annuler'),
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

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
                ActionChip(avatar: const Text('🚪'), label: const Text('Porte'), onPressed: () => _addOpening(OpeningKind.door)),
                ActionChip(avatar: const Text('🪟'), label: const Text('Fenêtre'), onPressed: () => _addOpening(OpeningKind.window)),
                for (final o in s.openings)
                  InputChip(
                    label: Text('${o.kind == OpeningKind.door ? 'Porte' : 'Fenêtre'} · ${_walls[o.wall]}'),
                    onPressed: () => _editOpening(o.id),
                  ),
              ]),
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Glisse pour déplacer, tire le rond pour redimensionner. Les plantes se glissent aussi.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      );
}
