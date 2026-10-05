import 'package:flutter/material.dart';

import '../design/colors.dart';
import '../design/radius.dart';
import '../design/spacing.dart';
import '../design/typography.dart';

/// Consistent score bands for rings, cards, and history.
class MatchBand {
  const MatchBand._();

  static String verdict(int score) => score >= 80
      ? 'Strong Fit'
      : score >= 60
          ? 'Good Match'
          : score >= 40
              ? 'Needs Tailoring'
              : 'Low Match';

  static Color color(BuildContext context, int score) {
    final colors = AppColors.of(context);
    return score >= 75
        ? colors.success
        : score >= 50
            ? colors.warning
            : colors.error;
  }

  static Color background(BuildContext context, int score) {
    final colors = AppColors.of(context);
    return score >= 75
        ? colors.diffAddedBg
        : score >= 50
            ? (Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF78350F)
                : const Color(0xFFFEF3C7))
            : colors.diffPrunedBg;
  }
}

/// A readable band label; score is never communicated by color alone.
/// Uses tabular numerals and capsule border radius.
class MatchBadge extends StatelessWidget {
  const MatchBadge(
    this.score, {
    super.key,
    this.compact = false,
    this.showVerdict = false,
  });

  final int score;
  final bool compact;
  final bool showVerdict;

  @override
  Widget build(BuildContext context) {
    final bounded = score.clamp(0, 100);
    final verdictText = MatchBand.verdict(bounded);
    final textColor = MatchBand.color(context, bounded);
    final bgColor = MatchBand.background(context, bounded);

    final label = compact
        ? '$bounded%'
        : showVerdict
            ? '$bounded% $verdictText'
            : '$bounded% Match';

    return Semantics(
      label: 'Match score $bounded percent, $verdictText',
      excludeSemantics: true,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? AppSpacing.s8 : AppSpacing.s12,
          vertical: compact ? AppSpacing.s4 / 2 : AppSpacing.s4,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadius.capsuleRadius,
          border: Border.all(
            color: AppColors.of(context).hairlineBorder,
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}
