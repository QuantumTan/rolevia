import 'dart:ui';

import 'package:flutter/foundation.dart';
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
    final reduceTransparency =
        Theme.of(context).extension<SurfacePreferences>()?.solid ?? false;
    final useNativeMaterial =
        defaultTargetPlatform == TargetPlatform.iOS &&
        !solid &&
        !reduceTransparency;

    final decoration = BoxDecoration(
      color: useNativeMaterial
          ? colors.surface.withValues(alpha: 0.78)
          : colors.surface,
      borderRadius: effectiveRadius,
      border: showBorder
          ? Border.all(color: colors.hairlineBorder, width: 0.5)
          : null,
      boxShadow: showShadow
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ]
          : null,
    );

    final content = Container(
      decoration: decoration,
      padding: padding,
      child: child,
    );

    if (!useNativeMaterial) return content;
    return ClipRRect(
      borderRadius: effectiveRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: content,
      ),
    );
  }
}
