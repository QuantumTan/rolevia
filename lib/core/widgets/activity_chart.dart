import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'adaptive_card.dart';

/// Seven-day application activity derived from stored dates, including zeros.
class ActivityChart extends StatelessWidget {
  const ActivityChart(this.dates, {super.key});
  final List<DateTime> dates;
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));
    final counts = days
        .map(
          (d) => dates
              .where(
                (date) =>
                    date.year == d.year &&
                    date.month == d.month &&
                    date.day == d.day,
              )
              .length,
        )
        .toList();
    final colors = AppColors.of(context);
    return AdaptiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Applications this week',
            style: AppTypography.headline.copyWith(color: colors.labelPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          Semantics(
            label: 'Applications in the last seven days: ${counts.join(', ')}',
            child: SizedBox(
              height: 100,
              width: double.infinity,
              child: CustomPaint(
                painter: _ActivityPainter(
                  counts,
                  colors.accent,
                  colors.separator,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: days
                .map(
                  (d) => Expanded(
                    child: Text(
                      [
                        'Mon',
                        'Tue',
                        'Wed',
                        'Thu',
                        'Fri',
                        'Sat',
                        'Sun',
                      ][d.weekday - 1],
                      textAlign: TextAlign.center,
                      style: AppTypography.caption.copyWith(
                        color: colors.labelSecondary,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ActivityPainter extends CustomPainter {
  _ActivityPainter(this.counts, this.color, this.track);
  final List<int> counts;
  final Color color, track;
  @override
  void paint(Canvas canvas, Size size) {
    final max = counts.fold<int>(1, (a, b) => a > b ? a : b);
    final cell = size.width / counts.length;
    for (var i = 0; i < counts.length; i++) {
      final x = cell * i + cell * .25;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, size.height - 2, cell * .5, 2),
          const Radius.circular(1),
        ),
        Paint()..color = track,
      );
      if (counts[i] == 0) continue;
      final height = counts[i] / max * (size.height - 8);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, size.height - height, cell * .5, height),
          const Radius.circular(4),
        ),
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_ActivityPainter old) =>
      old.counts.toString() != counts.toString() ||
      old.color != color ||
      old.track != track;
}
