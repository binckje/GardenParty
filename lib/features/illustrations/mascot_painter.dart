import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'illustration_settings.dart';

/// Mascotte kawaii dessinée en code : pot souriant et pousse, humeur selon la scène.
class MascotPainter extends CustomPainter {
  const MascotPainter(this.mood, {this.bounce = 0});

  final MascotMood mood;

  /// 0..1, léger rebond de la pousse.
  final double bounce;

  @override
  void paint(Canvas canvas, Size size) {
    final s = min(size.width, size.height) / 100;
    canvas.save();
    canvas.translate((size.width - 100 * s) / 2, (size.height - 100 * s) / 2);
    canvas.scale(s);

    final fill = Paint()..style = PaintingStyle.fill;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..color = KawaiiColors.cocoa;

    // Ombre.
    canvas.drawOval(Rect.fromCenter(center: const Offset(50, 93), width: 56, height: 8),
        fill..color = KawaiiColors.cocoa.withValues(alpha: 0.12));

    // Pousse : tige et deux feuilles, qui oscillent un peu.
    canvas.save();
    canvas.translate(50, 50);
    canvas.rotate((bounce - 0.5) * 0.12);
    canvas.drawLine(Offset.zero, const Offset(0, -20), line);
    for (final dir in [-1.0, 1.0]) {
      final leaf = Path()
        ..moveTo(0, -18)
        ..quadraticBezierTo(dir * 6, -38, dir * 24, -34)
        ..quadraticBezierTo(dir * 18, -16, 0, -18)
        ..close();
      canvas.drawPath(leaf, fill..color = KawaiiColors.leaf);
      canvas.drawPath(leaf, line..strokeWidth = 2);
    }
    if (mood == MascotMood.proud) {
      canvas.drawCircle(const Offset(0, -24), 6, fill..color = KawaiiColors.blush);
      canvas.drawCircle(const Offset(0, -24), 2.5, fill..color = KawaiiColors.peach);
    }
    canvas.restore();

    // Pot.
    final pot = Path()
      ..moveTo(24, 52)
      ..lineTo(76, 52)
      ..lineTo(70, 90)
      ..quadraticBezierTo(50, 94, 30, 90)
      ..close();
    canvas.drawPath(pot, fill..color = KawaiiColors.peach);
    canvas.drawPath(pot, line..strokeWidth = 2.5);
    final rim = RRect.fromRectAndRadius(const Rect.fromLTWH(20, 46, 60, 10), const Radius.circular(5));
    canvas.drawRRect(rim, fill..color = KawaiiColors.blush);
    canvas.drawRRect(rim, line);

    // Joues.
    for (final x in [36.0, 64.0]) {
      canvas.drawOval(Rect.fromCenter(center: Offset(x, 76), width: 9, height: 5),
          fill..color = KawaiiColors.blush.withValues(alpha: 0.8));
    }

    // Yeux.
    switch (mood) {
      case MascotMood.sleepy:
        for (final x in [40.0, 60.0]) {
          canvas.drawArc(Rect.fromCenter(center: Offset(x, 68), width: 8, height: 6), 0, pi, false, line);
        }
        _zzz(canvas);
      case MascotMood.proud:
        for (final x in [40.0, 60.0]) {
          canvas.drawArc(Rect.fromCenter(center: Offset(x, 70), width: 8, height: 7), pi, pi, false, line);
        }
        _sparkle(canvas, const Offset(86, 30), 5);
        _sparkle(canvas, const Offset(14, 40), 4);
      case MascotMood.curious:
      case MascotMood.happy:
        for (final x in [40.0, 60.0]) {
          canvas.drawCircle(Offset(x, 68), 3.5, fill..color = KawaiiColors.cocoa);
          canvas.drawCircle(Offset(x + 1.2, 66.8), 1.2, fill..color = Colors.white);
        }
    }

    // Bouche.
    if (mood == MascotMood.curious) {
      canvas.drawCircle(const Offset(50, 77), 2.5, line..strokeWidth = 2);
    } else {
      canvas.drawArc(Rect.fromCenter(center: const Offset(50, 74), width: 10, height: 8), 0.2, pi - 0.4, false,
          line..strokeWidth = 2.5);
    }

    canvas.restore();
  }

  void _sparkle(Canvas canvas, Offset c, double r) {
    final p = Path()
      ..moveTo(c.dx, c.dy - r * 2)
      ..quadraticBezierTo(c.dx, c.dy, c.dx + r * 2, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r * 2)
      ..quadraticBezierTo(c.dx, c.dy, c.dx - r * 2, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r * 2)
      ..close();
    canvas.drawPath(p, Paint()..color = const Color(0xFFFFD86B));
  }

  void _zzz(Canvas canvas) {
    final tp = TextPainter(
      text: const TextSpan(text: 'z z', style: TextStyle(color: KawaiiColors.cocoa, fontSize: 12, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, const Offset(70, 18));
  }

  @override
  bool shouldRepaint(MascotPainter old) => old.mood != mood || old.bounce != bounce;
}
