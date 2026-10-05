import 'package:flutter/material.dart';
import '../design/radius.dart';

/// Fluid Container Transform Route interpolating source rect, radius,
/// elevation and color over 280ms using Apple's standard spring physics curve (cubic-bezier(0.25, 1, 0.5, 1)).
class ContainerTransformRoute<T> extends PageRoute<T> {
  ContainerTransformRoute({
    required this.builder,
    this.sourceRect,
    this.sourceRadius = AppRadius.card,
    this.targetRadius = 0.0,
    this.sourceColor,
    this.targetColor,
    super.settings,
    this.duration = const Duration(milliseconds: 280),
  });

  final WidgetBuilder builder;
  final Rect? sourceRect;
  final double sourceRadius;
  final double targetRadius;
  final Color? sourceColor;
  final Color? targetColor;
  final Duration duration;

  // Apple's spring physics curve cubic-bezier(0.25, 1, 0.5, 1)
  static const Curve appleSpringCurve = Cubic(0.25, 1.0, 0.5, 1.0);

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
      curve: appleSpringCurve,
      reverseCurve: appleSpringCurve.flipped,
    );

    final screenSize = MediaQuery.sizeOf(context);
    final targetScreenRect = Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
    final rectTween = RectTween(
      begin: sourceRect ?? Rect.fromCenter(
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
