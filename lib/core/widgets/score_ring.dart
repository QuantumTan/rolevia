import 'package:flutter/material.dart';

import '../design/motion.dart';
import '../theme/tokens.dart';
import 'match_badge.dart';

/// Animated progress with a stable screen-reader label, tabular numerals,
/// and calibrated ATS Counter Ratchet micro-haptics.
class BandScoreRing extends StatefulWidget {
  const BandScoreRing(this.score, {super.key, this.size = 88});
  final int score;
  final double size;

  @override
  State<BandScoreRing> createState() => _BandScoreRingState();
}

class _BandScoreRingState extends State<BandScoreRing> {
  int _lastTick = 0;

  @override
  Widget build(BuildContext context) {
    final bounded = widget.score.clamp(0, 100);
    final scaledSize = widget.size *
        (MediaQuery.textScalerOf(context).scale(17) / 17).clamp(1, 1.5);

    return Semantics(
      label: 'Match score $bounded percent, ${MatchBand.verdict(bounded)}',
      excludeSemantics: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: bounded / 100),
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : UITokens.score,
        curve: Curves.easeOutCubic,
        builder: (context, value, _) {
          final currentInt = (value * 100).round();
          if (currentInt != _lastTick && currentInt > 0) {
            _lastTick = currentInt;
            // Calibrated ATS Counter Ratchet: subtle selection click that decelerates
            if (currentInt % 3 == 0 || currentInt == bounded) {
              AppMotion.selectionHaptic();
            }
          }

          return SizedBox.square(
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
                        '$currentInt%',
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
          );
        },
      ),
    );
  }
}
