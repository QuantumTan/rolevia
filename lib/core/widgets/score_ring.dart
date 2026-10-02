import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'match_badge.dart';

/// Animated progress with a stable screen-reader label and tabular numerals.
class BandScoreRing extends StatelessWidget {
  const BandScoreRing(this.score, {super.key, this.size = 88});
  final int score;
  final double size;
  @override
  Widget build(BuildContext context) {
    final bounded = score.clamp(0, 100);
    final scaledSize =
        size * (MediaQuery.textScalerOf(context).scale(17) / 17).clamp(1, 1.5);
    return Semantics(
      label: 'Match score $bounded percent, ${MatchBand.verdict(bounded)}',
      excludeSemantics: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: bounded / 100),
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : UITokens.score,
        curve: Curves.easeOutCubic,
        builder: (context, value, _) => SizedBox.square(
          dimension: scaledSize,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: value,
                strokeWidth: 7,
                strokeCap: StrokeCap.round,
                color: MatchBand.color(context, bounded),
                backgroundColor: AppColors.of(context).separator,
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(value * 100).round()}%',
                      style: AppTypography.title2.copyWith(
                        color: AppColors.of(context).labelPrimary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    Text(
                      'Match',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.of(context).labelSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
