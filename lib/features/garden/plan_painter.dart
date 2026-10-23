import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/garden.dart';
import 'plan_geometry.dart';

/// Vue du plan : [scale] pixels par mètre, [pan] décalage écran de l'origine.
class PlanView {
  const PlanView({required this.scale, required this.pan});

  final double scale;
  final Offset pan;

  Offset toScreen(Offset m) => m * scale + pan;
  Offset toWorld(Offset px) => (px - pan) / scale;
  Rect rectToScreen(Rect m) => Rect.fromPoints(toScreen(m.topLeft), toScreen(m.bottomRight));
}

/// Plante à dessiner : position absolue en mètres.
class PlanPlant {
  const PlanPlant({required this.id, required this.emoji, required this.position});

  final String id;
  final String emoji;
  final Offset position;
}

class PlanPainter extends CustomPainter {
  PlanPainter({required this.spaces, required this.view, this.selectedId, this.plants = const [], this.draggedPlantId});

  final List<Space> spaces;
  final PlanView view;
  final String? selectedId;
  final List<PlanPlant> plants;
  final String? draggedPlantId;

  static const handleRadius = 10.0;
  static const plantRadius = 16.0;
  static const _window = Color(0xFF9FD3F0);

  @override
  void paint(Canvas canvas, Size size) {
    _paintGrid(canvas, size);
    for (final s in PlanGeometry.drawOrder(spaces)) {
      _paintSpace(canvas, s, selected: s.id == selectedId);
    }
    for (final p in plants) {
      _paintPlant(canvas, p);
    }
  }

  void _paintPlant(Canvas canvas, PlanPlant p) {
    final c = view.toScreen(p.position);
    final dragged = p.id == draggedPlantId;
    final r = dragged ? plantRadius * 1.25 : plantRadius;
    canvas.drawCircle(c + const Offset(0, 2), r, Paint()..color = KawaiiColors.cocoa.withValues(alpha: 0.2));
    canvas.drawCircle(c, r, Paint()..color = Colors.white);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = KawaiiColors.leaf,
    );
    final emoji = TextPainter(
      text: TextSpan(text: p.emoji, style: TextStyle(fontSize: r * 1.1)),
      textDirection: TextDirection.ltr,
    )..layout();
    emoji.paint(canvas, c - Offset(emoji.width / 2, emoji.height / 2));
  }

  void _paintGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = KawaiiColors.cocoa.withValues(alpha: 0.07)
      ..strokeWidth = 1;
    final topLeft = view.toWorld(Offset.zero), bottomRight = view.toWorld(Offset(size.width, size.height));
    for (var x = topLeft.dx.floorToDouble(); x <= bottomRight.dx; x++) {
      final px = view.toScreen(Offset(x, 0)).dx;
      canvas.drawLine(Offset(px, 0), Offset(px, size.height), paint);
    }
    for (var y = topLeft.dy.floorToDouble(); y <= bottomRight.dy; y++) {
      final py = view.toScreen(Offset(0, y)).dy;
      canvas.drawLine(Offset(0, py), Offset(size.width, py), paint);
    }
  }

  void _paintSpace(Canvas canvas, Space s, {required bool selected}) {
    final indoor = s.kind == SpaceKind.indoorRoom;
    final rect = view.rectToScreen(PlanGeometry.rectOf(s));
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(indoor ? 6 : 16));
    canvas.drawRRect(rrect, Paint()..color = indoor ? KawaiiColors.peach.withValues(alpha: 0.6) : KawaiiColors.mint.withValues(alpha: 0.6));
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = selected ? 4 : (indoor ? 3 : 2)
        ..color = selected ? KawaiiColors.leaf : KawaiiColors.cocoa.withValues(alpha: indoor ? 0.8 : 0.4),
    );

    for (final o in s.openings) {
      _paintOpening(canvas, s, o);
    }

    final label = TextPainter(
      text: TextSpan(children: [
        TextSpan(text: '${s.name}\n', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        TextSpan(text: '${_m(s.width)} × ${_m(s.height)} m', style: const TextStyle(fontSize: 11)),
      ], style: const TextStyle(color: KawaiiColors.cocoa)),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '…',
    )..layout(maxWidth: max(0, rect.width - 8));
    if (label.height < rect.height) label.paint(canvas, rect.center - Offset(label.width / 2, label.height / 2));

    if (selected) {
      final h = view.toScreen(PlanGeometry.handleOf(s));
      canvas.drawCircle(h, handleRadius, Paint()..color = Colors.white);
      canvas.drawCircle(
        h,
        handleRadius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = KawaiiColors.leaf,
      );
    }
  }

  void _paintOpening(Canvas canvas, Space s, Opening o) {
    final (a, b) = PlanGeometry.segmentOf(s, o);
    final pa = view.toScreen(a), pb = view.toScreen(b);
    // Efface le mur sous l'ouverture.
    canvas.drawLine(pa, pb, Paint()..color = Colors.white..strokeWidth = 6);
    if (o.kind == OpeningKind.window) {
      canvas.drawLine(pa, pb, Paint()..color = _window..strokeWidth = 5..strokeCap = StrokeCap.round);
      return;
    }
    // Porte : battant + arc d'ouverture vers l'intérieur.
    final len = (pb - pa).distance;
    final inward = switch (o.wall) { 0 => pi / 2, 1 => pi, 2 => -pi / 2, _ => 0.0 };
    final along = atan2(pb.dy - pa.dy, pb.dx - pa.dx);
    final sweep = _normalize(inward - along);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = KawaiiColors.blush;
    canvas.drawLine(pa, pa + Offset(cos(inward), sin(inward)) * len, paint..strokeWidth = 3);
    canvas.drawArc(Rect.fromCircle(center: pa, radius: len), along, sweep, false, paint..strokeWidth = 1.5);
  }

  static double _normalize(double a) => atan2(sin(a), cos(a));

  static String _m(double v) => v.toStringAsFixed(v == v.roundToDouble() ? 0 : 2).replaceAll('.', ',');

  @override
  bool shouldRepaint(PlanPainter old) => true;
}
