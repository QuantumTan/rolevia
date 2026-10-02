import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A document drop-zone outline; the child owns the upload action.
class DashedFrame extends StatelessWidget {
  const DashedFrame({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => CustomPaint(
    foregroundPainter: _DashPainter(AppColors.of(context).accent),
    child: Padding(padding: const EdgeInsets.all(AppSpacing.sm), child: child),
  );
}

class _DashPainter extends CustomPainter {
  _DashPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(UITokens.cardRadius),
        ),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final metric in path.computeMetrics()) {
      for (double distance = 0; distance < metric.length; distance += 10) {
        canvas.drawPath(
          metric.extractPath(distance, (distance + 5).clamp(0, metric.length)),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color;
}
