import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../design/motion.dart';
import '../design/radius.dart';

/// Fluid container transform that settles with the shared spring system.
class ContainerTransformRoute<T> extends PageRoute<T> {
  ContainerTransformRoute({
    required this.builder,
    this.sourceRect,
    this.sourceRadius = AppRadius.card,
    this.targetRadius = 0.0,
    this.sourceColor,
    this.targetColor,
    super.settings,
    this.duration = AppMotion.standard,
  });

  final WidgetBuilder builder;
  final Rect? sourceRect;
  final double sourceRadius;
  final double targetRadius;
  final Color? sourceColor;
  final Color? targetColor;
  final Duration duration;

  @override
  Duration get transitionDuration => duration;

  @override
  Duration get reverseTransitionDuration => duration;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: const _ClampedSpringCurve(),
      reverseCurve: const _ClampedSpringCurve().flipped,
    );

    final screenSize = MediaQuery.sizeOf(context);
    final targetScreenRect = Rect.fromLTWH(
      0,
      0,
      screenSize.width,
      screenSize.height,
    );
    final rectTween = RectTween(
      begin:
          sourceRect ??
          Rect.fromCenter(
            center: Offset(screenSize.width / 2, screenSize.height / 2),
            width: screenSize.width * 0.9,
            height: 200,
          ),
      end: targetScreenRect,
    );

    final radiusTween = Tween<double>(begin: sourceRadius, end: targetRadius);

    final theme = Theme.of(context);
    final startColor = sourceColor ?? theme.colorScheme.surface;
    final endColor = targetColor ?? theme.scaffoldBackgroundColor;
    final colorTween = ColorTween(begin: startColor, end: endColor);

    return AnimatedBuilder(
      animation: curvedAnimation,
      builder: (context, _) {
        final currentRect = rectTween.evaluate(curvedAnimation)!;
        final currentRadius = radiusTween.evaluate(curvedAnimation);
        final currentColor = colorTween.evaluate(curvedAnimation);
        final opacity = curvedAnimation.value.clamp(0.0, 1.0);

        return Stack(
          children: [
            Positioned.fromRect(
              rect: currentRect,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(currentRadius),
                child: Material(
                  color: currentColor,
                  elevation: (1.0 - opacity) * 4.0,
                  child: OverflowBox(
                    alignment: Alignment.topCenter,
                    minWidth: screenSize.width,
                    maxWidth: screenSize.width,
                    minHeight: screenSize.height,
                    maxHeight: screenSize.height,
                    child: FadeTransition(
                      opacity: CurvedAnimation(
                        parent: animation,
                        curve: const Interval(0.1, 1.0, curve: Curves.easeOut),
                      ),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ClampedSpringCurve extends Curve {
  const _ClampedSpringCurve();

  @override
  double transformInternal(double t) {
    if (t <= 0) return 0;
    if (t >= 1) return 1;
    final simulation = SpringSimulation(AppMotion.spring, 0, 1, 0);
    return simulation.x(t * 0.28).clamp(0.0, 1.0);
  }
}

/// Helper extension to launch a container transform from any BuildContext
extension ContainerTransformExtension on BuildContext {
  Future<T?> pushWithContainerTransform<T>(
    WidgetBuilder builder, {
    Rect? sourceRect,
    double sourceRadius = AppRadius.card,
    Color? sourceColor,
  }) {
    return Navigator.of(this).push<T>(
      ContainerTransformRoute<T>(
        builder: builder,
        sourceRect: sourceRect,
        sourceRadius: sourceRadius,
        sourceColor: sourceColor,
      ),
    );
  }
}
