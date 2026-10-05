import 'package:flutter/material.dart';

enum AppCustomIconType {
  atsPass,
  atsWarn,
  evidence,
  constellation,
  scan,
}

/// Custom 24dp vector icons with 1.5 to 2 px stroke and rounded caps.
/// Used where platform Material/Cupertino has no direct semantic equivalent.
class AppCustomIcon extends StatelessWidget {
  const AppCustomIcon(
    this.type, {
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeWidth = 1.8,
  });

  final AppCustomIconType type;
  final double size;
  final Color? color;
  final double strokeWidth;

  const AppCustomIcon.atsPass({Key? key, double size = 24, Color? color})
      : this(AppCustomIconType.atsPass, key: key, size: size, color: color);

  const AppCustomIcon.atsWarn({Key? key, double size = 24, Color? color})
      : this(AppCustomIconType.atsWarn, key: key, size: size, color: color);

  const AppCustomIcon.evidence({Key? key, double size = 24, Color? color})
      : this(AppCustomIconType.evidence, key: key, size: size, color: color);

  const AppCustomIcon.constellation({Key? key, double size = 24, Color? color})
      : this(AppCustomIconType.constellation, key: key, size: size, color: color);

  const AppCustomIcon.scan({Key? key, double size = 24, Color? color})
      : this(AppCustomIconType.scan, key: key, size: size, color: color);

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? IconTheme.of(context).color ?? const Color(0xFF0F172A);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _CustomIconPainter(
          type: type,
          color: iconColor,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _CustomIconPainter extends CustomPainter {
  const _CustomIconPainter({
    required this.type,
    required this.color,
    required this.strokeWidth,
  });

  final AppCustomIconType type;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth * (size.width / 24.0)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    switch (type) {
      case AppCustomIconType.atsPass:
        // Shield outline with checkmark
        final path = Path()
          ..moveTo(12, 3)
          ..cubicTo(16, 3, 19, 4.5, 19, 7)
          ..cubicTo(19, 14, 15, 19, 12, 21)
          ..cubicTo(9, 19, 5, 14, 5, 7)
          ..cubicTo(5, 4.5, 8, 3, 12, 3)
          ..close();
        canvas.drawPath(path, paint);
        // Checkmark inside
        final check = Path()
          ..moveTo(8.5, 11.5)
          ..lineTo(11, 14)
          ..lineTo(15.5, 9.5);
        canvas.drawPath(check, paint);

      case AppCustomIconType.atsWarn:
        // Rounded alert triangle with exclamation point
        final path = Path()
          ..moveTo(12, 3.5)
          ..lineTo(21, 19.5)
          ..cubicTo(21.4, 20.2, 20.9, 21, 20.1, 21)
          ..lineTo(3.9, 21)
          ..cubicTo(3.1, 21, 2.6, 20.2, 3, 19.5)
          ..lineTo(12, 3.5)
          ..close();
        canvas.drawPath(path, paint);
        // Exclamation line and dot
        canvas.drawLine(const Offset(12, 9), const Offset(12, 14), paint);
        final dotPaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawCircle(const Offset(12, 17.5), 1.2, dotPaint);

      case AppCustomIconType.evidence:
        // Document with highlight line and magnifying loop
        final doc = Path()
          ..moveTo(5, 3)
          ..lineTo(14, 3)
          ..lineTo(19, 8)
          ..lineTo(19, 21)
          ..lineTo(5, 21)
          ..close();
        canvas.drawPath(doc, paint);
        // Fold corner
        final fold = Path()
          ..moveTo(14, 3)
          ..lineTo(14, 8)
          ..lineTo(19, 8);
        canvas.drawPath(fold, paint);
        // Evidence citation bars
        canvas.drawLine(const Offset(8, 12), const Offset(14, 12), paint);
        canvas.drawLine(const Offset(8, 16), const Offset(16, 16), paint);

      case AppCustomIconType.constellation:
        // Interconnected node network
        final fillPaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;
        const n1 = Offset(6, 6);
        const n2 = Offset(18, 5);
        const n3 = Offset(19, 17);
        const n4 = Offset(8, 19);
        const n5 = Offset(12, 11);

        // Lines
        canvas.drawLine(n1, n2, paint);
        canvas.drawLine(n2, n3, paint);
        canvas.drawLine(n3, n4, paint);
        canvas.drawLine(n4, n1, paint);
        canvas.drawLine(n1, n5, paint);
        canvas.drawLine(n2, n5, paint);
        canvas.drawLine(n3, n5, paint);
        canvas.drawLine(n4, n5, paint);

        // Nodes
        canvas.drawCircle(n1, 2.0, fillPaint);
        canvas.drawCircle(n2, 2.0, fillPaint);
        canvas.drawCircle(n3, 2.0, fillPaint);
        canvas.drawCircle(n4, 2.0, fillPaint);
        canvas.drawCircle(n5, 2.4, fillPaint);

      case AppCustomIconType.scan:
        // Viewfinder 4 corners + horizontal sweep line
        // Top-left
        final tl = Path()
          ..moveTo(3, 8)
          ..lineTo(3, 4)
          ..lineTo(7, 4);
        canvas.drawPath(tl, paint);
        // Top-right
        final tr = Path()
          ..moveTo(17, 4)
          ..lineTo(21, 4)
          ..lineTo(21, 8);
        canvas.drawPath(tr, paint);
        // Bottom-left
        final bl = Path()
          ..moveTo(3, 16)
          ..lineTo(3, 20)
          ..lineTo(7, 20);
        canvas.drawPath(bl, paint);
        // Bottom-right
        final br = Path()
          ..moveTo(17, 20)
          ..lineTo(21, 20)
          ..lineTo(21, 16);
        canvas.drawPath(br, paint);
        // Center scanline
        canvas.drawLine(const Offset(4, 12), const Offset(20, 12), paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CustomIconPainter oldDelegate) =>
      oldDelegate.type != type ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
}
