import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// One short, deterministic burst; reduced motion removes the animation.
class Celebration extends StatefulWidget {
  const Celebration({super.key});
  @override
  State<Celebration> createState() => _CelebrationState();
}

class _CelebrationState extends State<Celebration>
    with SingleTickerProviderStateMixin {
  late final controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      controller.stop();
      controller.value = 1;
    } else if (controller.value == 0 && !controller.isAnimating) {
      controller.forward();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ExcludeSemantics(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => CustomPaint(
          size: const Size(double.infinity, 90),
          painter: _Confetti(controller.value, AppColors.of(context).accent),
        ),
      ),
    ),
  );
}

class _Confetti extends CustomPainter {
  _Confetti(this.progress, this.indigo);
  final double progress;
  final Color indigo;
  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0 || progress == 1) return;
    for (var i = 0; i < 24; i++) {
      final angle = i * math.pi * 2 / 24;
      final travel = progress * (40 + i % 5 * 12);
      final center = Offset(
        size.width / 2 + math.cos(angle) * travel,
        size.height / 2 + math.sin(angle) * travel + progress * progress * 30,
      );
      canvas.drawCircle(
        center,
        2 + i % 3.0,
        Paint()
          ..color = (i.isEven ? indigo : UITokens.amber).withValues(
            alpha: 1 - progress,
          ),
      );
    }
  }

  @override
  bool shouldRepaint(_Confetti oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.indigo != indigo;
}
