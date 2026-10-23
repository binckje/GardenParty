import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme.dart';
import '../../data/api/species_mapper.dart';
import '../../models/garden.dart';
import '../../models/plant.dart';

const _months = ['janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'];

String lightLabel(LightLevel l) => switch (l) {
      LightLevel.shade => 'Ombre',
      LightLevel.lowLight => 'Peu de lumière',
      LightLevel.brightIndirect => 'Lumineux sans soleil direct',
      LightLevel.partialSun => 'Soleil doux',
      LightLevel.fullSun => 'Plein soleil',
    };

/// Emoji de la plante, utilisable dans un texte ou sur le plan.
String speciesEmoji(PlantSpecies? s) {
  final v = s?.imageUrl;
  return v == null || v.isEmpty || v.startsWith('http') || v.startsWith('assets/') || v.startsWith('data:') ? '🪴' : v;
}

/// Octets décodés des photos en data URI, gardés pour ne pas redécoder l'image à chaque affichage.
final _dataCache = <String, Uint8List>{};

Uint8List _dataBytes(String uri) {
  if (_dataCache.length > 64) _dataCache.clear();
  return _dataCache[uri] ??= UriData.parse(uri).contentAsBytes();
}

/// Visuel d'une espèce : image (URL, asset ou photo en data URI) si fournie, sinon emoji.
class SpeciesVisual extends StatelessWidget {
  const SpeciesVisual(this.species, {super.key, this.size = 40});

  final PlantSpecies? species;
  final double size;

  @override
  Widget build(BuildContext context) {
    final v = species?.imageUrl ?? '';
    final fallback = Text(speciesEmoji(species), style: TextStyle(fontSize: size * 0.7));
    final Widget child = v.startsWith('http')
        ? Image.network(v, fit: BoxFit.cover, errorBuilder: (_, __, ___) => fallback)
        : v.startsWith('data:')
            // Photo prise dans l'éditeur de fiche (data URI base64).
            ? Image.memory(_dataBytes(v), fit: BoxFit.cover, gaplessPlayback: true, errorBuilder: (_, __, ___) => fallback)
            : v.startsWith('assets/')
                ? Image.asset(v, fit: BoxFit.cover, errorBuilder: (_, __, ___) => fallback)
                : fallback;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(color: KawaiiColors.mint, shape: BoxShape.circle),
      child: child,
    );
  }
}

/// Fiche d'identité complète d'une espèce.
class SpeciesDetails extends StatelessWidget {
  const SpeciesDetails(this.species, {super.key});

  final PlantSpecies species;

  @override
  Widget build(BuildContext context) {
    final s = species;
    final cutting = s.cutting, repotting = s.repotting;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (s.id.startsWith(gbifSpeciesPrefix))
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Fiche simplifiée'),
              subtitle: Text('Pas de fiche d\'entretien gratuite en ligne : valeurs moyennes de plante '
                  'd\'intérieur, à vérifier.'),
            ),
          ),
        if (s.id.startsWith(telaSpeciesPrefix))
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Fiche écologique (Tela Botanica)'),
              subtitle: Text('Entretien déduit du milieu naturel de l\'espèce en France : à ajuster.'),
            ),
          ),
        _Section('☀️ Lumière', Wrap(spacing: 6, runSpacing: 4, children: [
          for (final l in s.light) Chip(label: Text(lightLabel(l)), visualDensity: VisualDensity.compact),
        ])),
        _Section('🌡️ Température', Text('${_n(s.minTempC)} à ${_n(s.maxTempC)} °C')),
        _Section('🪨 Sol', Text(s.soil)),
        _Section('💧 Arrosage', Text(_schedule(s.watering))),
        _Section('🧪 Engrais', Text(_schedule(s.fertilizing))),
        _Section(
          '✂️ Bouturage',
          Text(cutting != null && cutting.possible ? cutting.method ?? 'Possible' : 'Peu adapté'),
        ),
        _Section(
          '🪴 Rempotage',
          Text(repotting != null && repotting.needed
              ? [
                  if (repotting.everyYears case final y?) y == 1 ? 'Tous les ans' : 'Tous les $y ans',
                  if (repotting.period != null) repotting.period!,
                ].join(', ')
              : 'Pas nécessaire'),
        ),
        if (s.diagnostics.isNotEmpty)
          _Section('🩺 Problèmes fréquents', Column(children: [
            for (final d in s.diagnostics)
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(d.symptom),
                childrenPadding: const EdgeInsets.only(bottom: 8),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [Text('Cause : ${d.cause}'), Text('Remède : ${d.treatment}')],
              ),
          ])),
        _SourceSection(speciesSource(s.id)),
      ],
    );
  }

  static String _n(double v) => v.toStringAsFixed(v == v.roundToDouble() ? 0 : 1).replaceAll('.', ',');

  static String _schedule(CareSchedule c) {
    final months = c.activeMonths.length == 12
        ? 'toute l’année'
        : c.activeMonths.length == 1
            ? 'en ${_months[c.activeMonths.single - 1]}'
            : 'de ${_months[c.activeMonths.first - 1]} à ${_months[c.activeMonths.last - 1]}';
    return 'Tous les ${c.everyDays} jours, ${c.quantity} ($months)';
  }
}

class _SourceSection extends StatelessWidget {
  const _SourceSection(this.source);

  final ({String label, Uri? url}) source;

  @override
  Widget build(BuildContext context) {
    final url = source.url;
    return _Section(
      '📚 Source',
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(source.label),
        if (url != null)
          InkWell(
            onTap: () => launchUrl(url, mode: LaunchMode.externalApplication),
            child: Text(
              url.toString(),
              style: TextStyle(color: Theme.of(context).colorScheme.primary, decoration: TextDecoration.underline),
            ),
          ),
      ]),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title, this.child);

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          child,
        ]),
      );
}
