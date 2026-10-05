import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Blurred navigation surface with a solid accessibility fallback.
class LiquidGlass extends StatelessWidget {
  const LiquidGlass({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.borderRadius,
    this.radius = AppRadius.xl,
    this.solid = false,
    this.blurSigma = 20.0,
    this.showBorder = true,
    this.showShadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final double radius;
  final bool solid;
  final double blurSigma;
  final bool showBorder;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final effectiveRadius = borderRadius ?? BorderRadius.circular(radius);

    final decoration = BoxDecoration(
      color: colors.surface,
      borderRadius: effectiveRadius,
      border: showBorder
          ? Border.all(color: colors.hairlineBorder, width: 0.5)
          : null,
    );

    return Container(
      decoration: decoration,
      padding: padding,
      child: child,
    );
  }
}
