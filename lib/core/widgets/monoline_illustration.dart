import 'package:flutter/material.dart';

import '../design/colors.dart';
import '../design/motion.dart';

enum MonolineGraphic {
  emptyBox,
  searchVoid,
  atsScan,
  alertOctagon,
  disconnectCloud,
}

/// Geometric monoline vector illustration with drawn-path animation on first appearance (stroke reveal 600 ms),
/// static under reduce motion. Uses accent tint plus neutrals.
class MonolineIllustration extends StatefulWidget {
  const MonolineIllustration({
    super.key,
    required this.graphic,
    this.size = 120.0,
    this.strokeWidth = 2.0,
  });

  final MonolineGraphic graphic;
  final double size;
  final double strokeWidth;

  @override
  State<MonolineIllustration> createState() => _MonolineIllustrationState();
}

class _MonolineIllustrationState extends State<MonolineIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.hero,
    );
    _controller.forward();
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

    if (reduceMotion) {
      _controller.value = 1.0;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _MonolinePainter(
            graphic: widget.graphic,
            progress: reduceMotion ? 1.0 : _controller.value,
            strokeWidth: widget.strokeWidth,
            accentColor: colors.accent,
            neutralColor: colors.labelTertiary,
          ),
        );
      },
    );
  }
}

class _MonolinePainter extends CustomPainter {
  const _MonolinePainter({
    required this.graphic,
    required this.progress,
    required this.strokeWidth,
    required this.accentColor,
    required this.neutralColor,
  });

  final MonolineGraphic graphic;
  final double progress;
  final double strokeWidth;
  final Color accentColor;
  final Color neutralColor;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 120.0;
    canvas.save();
    canvas.scale(scale, scale);

    final neutralPaint = Paint()
      ..color = neutralColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final accentPaint = Paint()
      ..color = accentColor
      ..strokeWidth = strokeWidth + 0.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    switch (graphic) {
      case MonolineGraphic.emptyBox:
        _drawRevealedPath(canvas, _createBoxPath(), neutralPaint, progress);
        _drawRevealedPath(canvas, _createBoxAccentPath(), accentPaint, progress);

      case MonolineGraphic.searchVoid:
        _drawRevealedPath(canvas, _createSearchPath(), neutralPaint, progress);
        _drawRevealedPath(canvas, _createSearchAccentPath(), accentPaint, progress);

      case MonolineGraphic.atsScan:
        _drawRevealedPath(canvas, _createScanPath(), neutralPaint, progress);
        _drawRevealedPath(canvas, _createScanAccentPath(), accentPaint, progress);

      case MonolineGraphic.alertOctagon:
        _drawRevealedPath(canvas, _createAlertPath(), neutralPaint, progress);
        _drawRevealedPath(canvas, _createAlertAccentPath(), accentPaint, progress);

      case MonolineGraphic.disconnectCloud:
        _drawRevealedPath(canvas, _createCloudPath(), neutralPaint, progress);
        _drawRevealedPath(canvas, _createCloudAccentPath(), accentPaint, progress);
    }

    canvas.restore();
  }

  void _drawRevealedPath(Canvas canvas, Path path, Paint paint, double reveal) {
    if (reveal <= 0.0) return;
    if (reveal >= 1.0) {
      canvas.drawPath(path, paint);
      return;
    }
    for (final metric in path.computeMetrics()) {
      final extract = metric.extractPath(0.0, metric.length * reveal);
      canvas.drawPath(extract, paint);
    }
  }

  Path _createBoxPath() {
    return Path()
      ..moveTo(30, 45)
      ..lineTo(60, 30)
      ..lineTo(90, 45)
      ..lineTo(60, 60)
      ..close()
      ..moveTo(30, 45)
      ..lineTo(30, 80)
      ..lineTo(60, 95)
      ..lineTo(60, 60)
      ..moveTo(90, 45)
      ..lineTo(90, 80)
      ..lineTo(60, 95);
  }

  Path _createBoxAccentPath() {
    return Path()
      ..moveTo(60, 30)
      ..lineTo(60, 60);
  }

  Path _createSearchPath() {
    return Path()
      ..addOval(Rect.fromCircle(center: const Offset(55, 55), radius: 26))
      ..moveTo(74, 74)
      ..lineTo(94, 94);
  }

  Path _createSearchAccentPath() {
    return Path()
      ..moveTo(45, 55)
      ..lineTo(65, 55);
  }

  Path _createScanPath() {
    return Path()
      // Viewfinder
      ..moveTo(25, 45)
      ..lineTo(25, 25)
      ..lineTo(45, 25)
      ..moveTo(75, 25)
      ..lineTo(95, 25)
      ..lineTo(95, 45)
      ..moveTo(25, 75)
      ..lineTo(25, 95)
      ..lineTo(45, 95)
      ..moveTo(75, 95)
      ..lineTo(95, 95)
      ..lineTo(95, 75);
  }

  Path _createScanAccentPath() {
    return Path()
      ..moveTo(30, 60)
      ..lineTo(90, 60);
  }

  Path _createAlertPath() {
    final path = Path()
      ..moveTo(40, 20)
      ..lineTo(80, 20)
      ..lineTo(100, 40)
      ..lineTo(100, 80)
      ..lineTo(80, 100)
      ..lineTo(40, 100)
      ..lineTo(20, 80)
      ..lineTo(20, 40)
      ..close();
    return path;
  }

  Path _createAlertAccentPath() {
    return Path()
      ..moveTo(60, 42)
      ..lineTo(60, 68)
      ..moveTo(60, 78)
      ..lineTo(60, 80);
  }

  Path _createCloudPath() {
    return Path()
      ..moveTo(35, 75)
      ..lineTo(85, 75)
      ..arcToPoint(const Offset(85, 55), radius: const Radius.circular(15))
      ..arcToPoint(const Offset(65, 40), radius: const Radius.circular(20))
      ..arcToPoint(const Offset(45, 50), radius: const Radius.circular(15))
      ..arcToPoint(const Offset(35, 75), radius: const Radius.circular(15))
      ..close();
  }

  Path _createCloudAccentPath() {
    return Path()
      ..moveTo(30, 85)
      ..lineTo(90, 25);
  }

  @override
  bool shouldRepaint(covariant _MonolinePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.graphic != graphic ||
      oldDelegate.accentColor != accentColor ||
      oldDelegate.neutralColor != neutralColor;
}
