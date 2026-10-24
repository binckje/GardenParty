import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme.dart';
import 'illustration_settings.dart';
import 'mascot_painter.dart';

/// Illustration d'une [scene], rendue selon le style choisi dans les réglages.
class KawaiiIllustration extends ConsumerStatefulWidget {
  const KawaiiIllustration(this.scene, {super.key, this.size = 140, this.style});

  final IllustrationScene scene;
  final double size;

  /// Force un style (aperçu des réglages) au lieu de celui choisi.
  final IllustrationStyle? style;

  @override
  ConsumerState<KawaiiIllustration> createState() => _KawaiiIllustrationState();
}

class _KawaiiIllustrationState extends ConsumerState<KawaiiIllustration> with SingleTickerProviderStateMixin {
  late final _bounce = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Quelques rebonds puis repos : pas d'animation sans fin (batterie, pumpAndSettle des tests).
    if (!_bounce.isAnimating && _bounce.value == 0 && !MediaQuery.disableAnimationsOf(context)) {
      _bounce.repeat(reverse: true, count: 3);
    }
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(illustrationSettingsProvider);
    final style = widget.style ?? settings.style;
    final svg = settings.customSvgs[widget.scene];
    final size = widget.size;

    final Widget child = switch (style) {
      IllustrationStyle.custom when svg != null => SvgPicture.string(
          svg,
          width: size,
          height: size,
          errorBuilder: (_, __, ___) => _drawn(size),
        ),
      IllustrationStyle.emoji => _emoji(size),
      _ => _drawn(size),
    };
    return Semantics(label: widget.scene.label, image: true, child: SizedBox.square(dimension: size, child: child));
  }

  Widget _drawn(double size) => AnimatedBuilder(
        animation: _bounce,
        builder: (_, __) => CustomPaint(
          size: Size.square(size),
          painter: MascotPainter(widget.scene.mood, bounce: Curves.easeInOut.transform(_bounce.value)),
        ),
      );

  Widget _emoji(double size) => AnimatedBuilder(
        animation: _bounce,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, -size * 0.04 * Curves.easeInOut.transform(_bounce.value)),
          child: child,
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(colors: [KawaiiColors.cream, KawaiiColors.mint]),
            boxShadow: [BoxShadow(color: KawaiiColors.cocoa.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 6))],
          ),
          alignment: Alignment.center,
          child: Text(widget.scene.emoji, style: TextStyle(fontSize: size * 0.45)),
        ),
      );
}

/// Illustration + message, pour les écrans vides.
class EmptyState extends StatelessWidget {
  const EmptyState(this.scene, this.message, {super.key, this.size = 140});

  final IllustrationScene scene;
  final String message;
  final double size;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              KawaiiIllustration(scene, size: size),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      );
}
