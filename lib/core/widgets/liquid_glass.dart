import 'dart:ui';

import 'package:flutter/material.dart';

import '../design/colors.dart';
import '../design/radius.dart';

/// Refined Liquid Glass surface layer implementing iOS 27 principles.
/// Features backdrop blur, subtle top specular highlight, and graceful
/// fallback to solid material when reduced transparency or high contrast is active.
class LiquidGlass extends StatelessWidget {
  const LiquidGlass({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.borderRadius,
    this.radius = AppRadius.xl,
    this.solid = false,
    this.blurSigma = 22.0,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isHighContrast = MediaQuery.highContrastOf(context);
    final effectiveRadius = borderRadius ?? BorderRadius.circular(radius);

    final shouldBeSolid = solid || isHighContrast;

    final decoration = BoxDecoration(
      color: shouldBeSolid ? colors.surface : colors.glassSurface,
      borderRadius: effectiveRadius,
      border: showBorder
          ? Border.all(color: colors.glassBorder, width: 0.8)
          : null,
      boxShadow: (showShadow && !isHighContrast)
          ? [
              BoxShadow(
                color: isDark
                    ? const Color(0x38000000)
                    : const Color(0x0F000000),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ]
          : null,
    );

    if (shouldBeSolid) {
      return Container(decoration: decoration, padding: padding, child: child);
    }

    return ClipRRect(
      borderRadius: effectiveRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: DecoratedBox(
          decoration: decoration,
          child: Stack(
            children: [
              // Subtle top specular gradient sheen
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 1.5,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors.glassHighlight,
                        colors.glassHighlight.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(padding: padding, child: child),
            ],
          ),
        ),
      ),
    );
  }
}
