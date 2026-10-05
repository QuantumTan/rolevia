import 'package:flutter/material.dart';
import '../design/colors.dart';

enum GridBackgroundStyle {
  dotGrid,
  hairlineGrid,
}

/// Faint dot-grid or hairline grid at 4 to 6% opacity drawn by a cached CustomPainter
/// inside a RepaintBoundary.
class GridBackground extends StatelessWidget {
  const GridBackground({
    super.key,
    this.child,
    this.style = GridBackgroundStyle.dotGrid,
    this.opacity = 0.05,
    this.gridSpacing = 24.0,
  });

  final Widget? child;
  final GridBackgroundStyle style;
  final double opacity;
  final double gridSpacing;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gridColor = (isDark ? Colors.white : Colors.black).withValues(alpha: opacity);

    return RepaintBoundary(
      child: CustomPaint(
        painter: _GridBackgroundPainter(
          color: gridColor,
          style: style,
          spacing: gridSpacing,
        ),
        child: child,
      ),
    );
  }
}

class _GridBackgroundPainter extends CustomPainter {
  const _GridBackgroundPainter({
    required this.color,
    required this.style,
    required this.spacing,
  });

  final Color color;
  final GridBackgroundStyle style;
  final double spacing;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    if (style == GridBackgroundStyle.dotGrid) {
      paint.style = PaintingStyle.fill;
      const dotRadius = 1.0;
      for (double x = spacing; x < size.width; x += spacing) {
        for (double y = spacing; y < size.height; y += spacing) {
          canvas.drawCircle(Offset(x, y), dotRadius, paint);
        }
      }
    } else {
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 0.5;
      for (double x = spacing; x < size.width; x += spacing) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      }
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridBackgroundPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.style != style ||
      oldDelegate.spacing != spacing;
}

/// Scanline motif: thin horizontal sweep as the brand device for ATS and analysis.
class ScanlineSweep extends StatefulWidget {
  const ScanlineSweep({
    super.key,
    this.child,
    this.active = true,
    this.duration = const Duration(milliseconds: 2400),
  });

  final Widget? child;
  final bool active;
  final Duration duration;

  @override
  State<ScanlineSweep> createState() => _ScanlineSweepState();
}

class _ScanlineSweepState extends State<ScanlineSweep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    if (widget.active) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant ScanlineSweep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active) {
      if (widget.active) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.value = 0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    if (reduceMotion || !widget.active) {
      return widget.child ?? const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          foregroundPainter: _ScanlinePainter(
            progress: _controller.value,
            color: colors.accent.withValues(alpha: 0.35),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  const _ScanlinePainter({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final y = progress * size.height;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Laser beam / scanline line
    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);

    // Subtle fade gradient trailing the line
    final trailRect = Rect.fromLTRB(0, (y - 20).clamp(0, size.height), size.width, y);
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.transparent, color.withValues(alpha: 0.15)],
    );
    final trailPaint = Paint()..shader = gradient.createShader(trailRect);
    canvas.drawRect(trailRect, trailPaint);
  }

  @override
  bool shouldRepaint(covariant _ScanlinePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
