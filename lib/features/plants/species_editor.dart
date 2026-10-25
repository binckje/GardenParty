import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../data/api/species_mapper.dart';

import '../../data/providers.dart';
import '../../models/garden.dart';
import '../../models/plant.dart';
import 'species_view.dart';

const _monthLetters = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];

/// Création (sans [initial]) ou modification d'une fiche espèce. Renvoie la fiche enregistrée.
/// Une fiche du catalogue modifiée garde son identifiant : la base locale ne l'écrase plus.
class SpeciesEditorScreen extends ConsumerStatefulWidget {
  const SpeciesEditorScreen({super.key, this.initial});

  final PlantSpecies? initial;

  @override
  ConsumerState<SpeciesEditorScreen> createState() => _SpeciesEditorScreenState();
}

class _SpeciesEditorScreenState extends ConsumerState<SpeciesEditorScreen> {
  final _form = GlobalKey<FormState>();
  late final _common = TextEditingController(text: widget.initial?.commonName);
  late final _scientific = TextEditingController(text: widget.initial?.scientificName);
  late final _minTemp = TextEditingController(text: _num(widget.initial?.minTempC ?? 12));
  late final _maxTemp = TextEditingController(text: _num(widget.initial?.maxTempC ?? 30));
  late final _soil = TextEditingController(text: widget.initial?.soil ?? 'Terreau universel drainant');
  late final _watering = _ScheduleFields(
      widget.initial?.watering ?? const CareSchedule(everyDays: 7, quantity: 'Quand le dessus du terreau est sec'));
  late final _fertilizing = _ScheduleFields(widget.initial?.fertilizing ??
      const CareSchedule(everyDays: 30, quantity: 'Engrais liquide, demi-dose', activeMonths: [4, 5, 6, 7, 8, 9]));
  late final _cuttingMethod = TextEditingController(text: widget.initial?.cutting?.method);
  late final _repotYears = TextEditingController(text: '${widget.initial?.repotting?.everyYears ?? 2}');
  late final _repotPeriod = TextEditingController(text: widget.initial?.repotting?.period ?? 'printemps');
  late final _rowSpacing = TextEditingController(text: widget.initial?.rowSpacingCm?.toString());
  late final _plantSpacing = TextEditingController(text: widget.initial?.plantSpacingCm?.toString());
  late final _notes = TextEditingController(text: widget.initial?.notes);
  late final Set<int> _sowing = {...?widget.initial?.sowingMonths};
  late String? _image = widget.initial?.imageUrl;
  late final Set<LightLevel> _light = {...?widget.initial?.light};
  late bool _cutting = widget.initial?.cutting?.possible ?? false;
  late bool _repotting = widget.initial?.repotting?.needed ?? true;
  late final List<_DiagnosticFields> _diagnostics = [
    for (final d in widget.initial?.diagnostics ?? const <Diagnostic>[]) _DiagnosticFields(d),
  ];

  static String _num(double v) => v.toStringAsFixed(v == v.roundToDouble() ? 0 : 1);

  /// Photo réduite (600 px) stockée en data URI dans la fiche : rien à gérer côté fichiers, web compris.
  Future<void> _pickPhoto(ImageSource source) async {
    final file = await ImagePicker().pickImage(source: source, maxWidth: 600, maxHeight: 600, imageQuality: 80);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final mime = file.mimeType ?? (file.name.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg');
    setState(() => _image = 'data:$mime;base64,${base64Encode(bytes)}');
  }

  Future<void> _editEmoji() async {
    final controller = TextEditingController(text: _image != null && _image!.length <= 8 ? _image : '');
    final emoji = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Emoji'),
        content: TextField(controller: controller, autofocus: true, maxLength: 8),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(c, controller.text.trim()), child: const Text('OK')),
        ],
      ),
    );
    if (emoji != null) setState(() => _image = emoji.isEmpty ? null : emoji);
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (_light.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Choisis au moins un niveau de lumière')));
      return;
    }
    final species = PlantSpecies(
      id: widget.initial?.id ?? '$customSpeciesPrefix${const Uuid().v4()}',
      scientificName: _scientific.text.trim(),
      commonName: _common.text.trim(),
      imageUrl: _image,
      light: _light.toList()..sort((a, b) => a.index.compareTo(b.index)),
      minTempC: _parse(_minTemp.text)!,
      maxTempC: _parse(_maxTemp.text)!,
      soil: _soil.text.trim(),
      watering: _watering.value(),
      fertilizing: _fertilizing.value(),
      diagnostics: [
        for (final d in _diagnostics)
          if (d.symptom.text.trim().isNotEmpty) d.value
      ],
      cutting: PropagationInfo(possible: _cutting, method: _cutting ? _blankToNull(_cuttingMethod.text) : null),
      repotting: RepottingInfo(
        needed: _repotting,
        everyYears: _repotting ? int.tryParse(_repotYears.text) : null,
        period: _repotting ? _blankToNull(_repotPeriod.text) : null,
      ),
      sowingMonths: _sowing.toList()..sort(),
      rowSpacingCm: int.tryParse(_rowSpacing.text.trim()),
      plantSpacingCm: int.tryParse(_plantSpacing.text.trim()),
      notes: _blankToNull(_notes.text),
    );
    await ref.read(plantRepositoryProvider).saveSpecies(species);
    if (mounted) Navigator.pop(context, species);
  }

  @override
  Widget build(BuildContext context) {
    final preview = PlantSpecies(
      id: '',
      scientificName: '',
      commonName: '',
      imageUrl: _image,
      light: const [],
      minTempC: 0,
      maxTempC: 0,
      soil: '',
      watering: const CareSchedule(everyDays: 1, quantity: ''),
      fertilizing: const CareSchedule(everyDays: 1, quantity: ''),
    );
    final canUseCamera = ImagePicker().supportsImageSource(ImageSource.camera);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initial == null ? 'Nouvelle fiche' : 'Modifier la fiche'),
        backgroundColor: Colors.transparent,
        actions: [IconButton(tooltip: 'Enregistrer', icon: const Icon(Icons.check), onPressed: _save)],
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          children: [
            Center(child: SpeciesVisual(preview, size: 96)),
            Wrap(alignment: WrapAlignment.center, spacing: 4, children: [
              if (canUseCamera)
                TextButton.icon(
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('Photo'),
                  onPressed: () => _pickPhoto(ImageSource.camera),
                ),
              TextButton.icon(
                icon: const Icon(Icons.photo_library),
                label: const Text('Image'),
                onPressed: () => _pickPhoto(ImageSource.gallery),
              ),
              TextButton.icon(
                  icon: const Icon(Icons.emoji_emotions), label: const Text('Emoji'), onPressed: _editEmoji),
            ]),
            TextFormField(
              controller: _common,
              decoration: const InputDecoration(labelText: 'Nom commun'),
              validator: _required,
            ),
            TextFormField(
              controller: _scientific,
              decoration: const InputDecoration(labelText: 'Nom latin'),
              validator: _required,
            ),
            _title('☀️ Lumière'),
            Wrap(spacing: 6, runSpacing: 4, children: [
              for (final l in LightLevel.values)
                FilterChip(
                  label: Text(lightLabel(l)),
                  selected: _light.contains(l),
                  onSelected: (on) => setState(() => on ? _light.add(l) : _light.remove(l)),
                ),
            ]),
            _title('🌡️ Température (°C)'),
            Row(children: [
              Expanded(child: _numberField(_minTemp, 'Minimum', decimal: true)),
              const SizedBox(width: 12),
              Expanded(child: _numberField(_maxTemp, 'Maximum', decimal: true)),
            ]),
            TextFormField(
                controller: _soil, decoration: const InputDecoration(labelText: '🪨 Sol'), validator: _required),
            _title('💧 Arrosage'),
            _scheduleEditor(_watering),
            _title('🧪 Engrais'),
            _scheduleEditor(_fertilizing),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('✂️ Bouturage possible'),
              value: _cutting,
              onChanged: (v) => setState(() => _cutting = v),
            ),
            if (_cutting)
              TextFormField(controller: _cuttingMethod, decoration: const InputDecoration(labelText: 'Méthode')),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('🪴 Rempotage'),
              value: _repotting,
              onChanged: (v) => setState(() => _repotting = v),
            ),
            if (_repotting)
              Row(children: [
                Expanded(child: _numberField(_repotYears, 'Tous les … ans', optional: true)),
                const SizedBox(width: 12),
                Expanded(
                    child: TextFormField(
                        controller: _repotPeriod, decoration: const InputDecoration(labelText: 'Période'))),
              ]),
            _title('🌱 Époque de semis'),
            _monthChips(_sowing),
            _title('📏 Plantation (cm)'),
            Row(children: [
              Expanded(child: _numberField(_rowSpacing, 'Entre les rangs', optional: true)),
              const SizedBox(width: 12),
              Expanded(child: _numberField(_plantSpacing, 'Entre les plants', optional: true)),
            ]),
            _title('🩺 Problèmes fréquents'),
            for (final (i, d) in _diagnostics.indexed)
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 4, 8),
                  child: Column(children: [
                    Row(children: [
                      Expanded(
                        child: TextFormField(
                            controller: d.symptom, decoration: const InputDecoration(labelText: 'Symptôme')),
                      ),
                      IconButton(
                        tooltip: 'Supprimer',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => setState(() => _diagnostics.removeAt(i)),
                      ),
                    ]),
                    TextFormField(controller: d.cause, decoration: const InputDecoration(labelText: 'Cause')),
                    TextFormField(controller: d.treatment, decoration: const InputDecoration(labelText: 'Remède')),
                  ]),
                ),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Ajouter un problème'),
                onPressed: () => setState(() => _diagnostics.add(_DiagnosticFields(null))),
              ),
            ),
            _title('📝 Notes'),
            TextFormField(
              controller: _notes,
              decoration: const InputDecoration(hintText: 'Ce que tu veux…', border: OutlineInputBorder()),
              minLines: 3,
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(icon: const Icon(Icons.check), label: const Text('Enregistrer'), onPressed: _save),
          ],
        ),
      ),
    );
  }

  Widget _scheduleEditor(_ScheduleFields f) => Column(children: [
        Row(children: [
          SizedBox(width: 120, child: _numberField(f.everyDays, 'Tous les … jours')),
          const SizedBox(width: 12),
          Expanded(
              child: TextFormField(
                  controller: f.quantity,
                  decoration: const InputDecoration(labelText: 'Quantité'),
                  validator: _required)),
        ]),
        const SizedBox(height: 4),
        _monthChips(f.months),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Mois de pleine saison (fréquence réduite le reste de l\'année)', style: TextStyle(fontSize: 12)),
        ),
      ]);

  Widget _monthChips(Set<int> months) => Wrap(spacing: 2, children: [
        for (var m = 1; m <= 12; m++)
          FilterChip(
            label: Text(_monthLetters[m - 1]),
            tooltip: 'Mois $m',
            showCheckmark: false,
            visualDensity: VisualDensity.compact,
            selected: months.contains(m),
            onSelected: (on) => setState(() => on ? months.add(m) : months.remove(m)),
          ),
      ]);

  Widget _numberField(TextEditingController c, String label, {bool decimal = false, bool optional = false}) =>
      TextFormField(
        controller: c,
        decoration: InputDecoration(labelText: label),
        keyboardType: TextInputType.numberWithOptions(decimal: decimal, signed: decimal),
        validator: (v) {
          if (optional && (v == null || v.trim().isEmpty)) return null;
          final n = _parse(v ?? '');
          if (n == null) return 'Nombre attendu';
          if (!decimal && (n < 1 || n != n.roundToDouble())) return 'Entier ≥ 1';
          return null;
        },
      );

  static Widget _title(String t) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 4),
        child: Builder(builder: (c) => Text(t, style: Theme.of(c).textTheme.titleSmall)),
      );

  static String? _required(String? v) => v == null || v.trim().isEmpty ? 'Obligatoire' : null;
  static double? _parse(String v) => double.tryParse(v.trim().replaceAll(',', '.'));
  static String? _blankToNull(String v) => v.trim().isEmpty ? null : v.trim();
}

class _ScheduleFields {
  _ScheduleFields(CareSchedule s)
      : everyDays = TextEditingController(text: '${s.everyDays}'),
        quantity = TextEditingController(text: s.quantity),
        months = {...s.activeMonths};

  final TextEditingController everyDays, quantity;
  final Set<int> months;

  CareSchedule value() => CareSchedule(
        everyDays: int.parse(everyDays.text.trim()),
        quantity: quantity.text.trim(),
        activeMonths: months.isEmpty ? List.generate(12, (i) => i + 1) : (months.toList()..sort()),
      );
}

class _DiagnosticFields {
  _DiagnosticFields(Diagnostic? d)
      : symptom = TextEditingController(text: d?.symptom),
        cause = TextEditingController(text: d?.cause),
        treatment = TextEditingController(text: d?.treatment);

  final TextEditingController symptom, cause, treatment;

  Diagnostic get value =>
      Diagnostic(symptom: symptom.text.trim(), cause: cause.text.trim(), treatment: treatment.text.trim());
}
