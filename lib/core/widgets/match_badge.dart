import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Consistent score bands for rings, cards and history.
class MatchBand {
  const MatchBand._();
  static String verdict(int score) => score >= 75
      ? 'Strong match'
      : score >= 50
      ? 'Almost there'
      : 'Needs work';
  static Color color(BuildContext context, int score) {
    final colors = AppColors.of(context);
    return score >= 75
        ? colors.success
        : score >= 50
        ? colors.warning
        : colors.error;
  }

  static Color background(BuildContext context, int score) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return score >= 75
          ? const Color(0xFF173323)
          : score >= 50
          ? const Color(0xFF352B15)
          : const Color(0xFF3B1F21);
    }
    return score >= 75
        ? const Color(0xFFE8F5E9)
        : score >= 50
        ? const Color(0xFFFFF8E1)
        : const Color(0xFFFFEBEE);
  }
}

/// A readable band label; the score is never communicated by color alone.
class MatchBadge extends StatelessWidget {
  const MatchBadge(this.score, {super.key});
  final int score;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Match score $score percent, ${MatchBand.verdict(score)}',
    excludeSemantics: true,
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: MatchBand.background(context, score),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$score% Match',
        style: AppTypography.footnote.copyWith(
          color: MatchBand.color(context, score),
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
