import 'package:flutter/material.dart';

import '../design/colors.dart';
import '../design/radius.dart';
import '../design/spacing.dart';

/// Specular highlight painter on dark surfaces: faint top hairline edge.
class SpecularTopBorderPainter extends CustomPainter {
  const SpecularTopBorderPainter({
    required this.highlightColor,
    required this.borderRadius,
    this.strokeWidth = 0.5,
  });

  final Color highlightColor;
  final BorderRadius borderRadius;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (highlightColor.a <= 0) return;

    final paint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final rrect = borderRadius.toRRect(rect);
    final path = Path()
      ..moveTo(rrect.left, rrect.top + rrect.tlRadiusY)
      ..arcToPoint(
        Offset(rrect.left + rrect.tlRadiusX, rrect.top),
        radius: Radius.circular(rrect.tlRadiusX),
      )
      ..lineTo(rrect.right - rrect.trRadiusX, rrect.top)
      ..arcToPoint(
        Offset(rrect.right, rrect.top + rrect.trRadiusY),
        radius: Radius.circular(rrect.trRadiusX),
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SpecularTopBorderPainter oldDelegate) =>
      oldDelegate.highlightColor != highlightColor ||
      oldDelegate.borderRadius != borderRadius ||
      oldDelegate.strokeWidth != strokeWidth;
}

/// Engineered card surface:
/// - 16px corner radius
/// - 0.5 logical px hairline border
/// - Faint specular top highlight on dark surfaces
/// - Flat surface without muddy shadows
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.edgeInsetsCard,
    this.margin,
    this.borderRadius,
    this.color,
    this.showBorder = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? color;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final radius = borderRadius ?? AppRadius.cardRadius;

    Widget card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? colors.surface,
        borderRadius: radius,
        border: showBorder
            ? Border.all(
                color: colors.hairlineBorder,
                width: AppRadius.hairline,
              )
            : null,
      ),
      child: child,
    );

    if (colors.glassHighlight.a > 0 && showBorder) {
      card = CustomPaint(
        foregroundPainter: SpecularTopBorderPainter(
          highlightColor: colors.glassHighlight,
          borderRadius: radius,
          strokeWidth: AppRadius.hairline,
        ),
        child: card,
      );
    }

    if (margin != null) {
      card = Padding(padding: margin!, child: card);
    }

    return card;
  }
}
