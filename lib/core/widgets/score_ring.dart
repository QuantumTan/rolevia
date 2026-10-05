import 'package:flutter/material.dart';

import '../design/colors.dart';
import '../design/motion.dart';
import '../design/typography.dart';
import 'match_badge.dart';

/// Animated progress with a stable screen-reader label, tabular numerals,
/// and settles haptic feedback.
class ScoreRing extends StatefulWidget {
  const ScoreRing(
    this.score, {
    super.key,
    this.size = 88.0,
    this.strokeWidth = 7.0,
    this.showLabel = true,
  });

  final int score;
  final double size;
  final double strokeWidth;
  final bool showLabel;

  @override
  State<ScoreRing> createState() => _ScoreRingState();
}

class _ScoreRingState extends State<ScoreRing> {
  bool _settled = false;

  @override
  void didUpdateWidget(covariant ScoreRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _settled = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bounded = widget.score.clamp(0, 100);
    final scaledSize =
        widget.size *
        (MediaQuery.textScalerOf(context).scale(17) / 17).clamp(1.0, 1.4);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return RepaintBoundary(
      child: Semantics(
        label: 'Match score $bounded percent, ${MatchBand.verdict(bounded)}',
        excludeSemantics: true,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: bounded / 100.0),
          duration: reduceMotion ? Duration.zero : AppMotion.hero,
          curve: AppMotion.curveStandard,
          onEnd: () {
            if (!_settled) {
              _settled = true;
              AppMotion.scoreSettles();
            }
          },
          builder: (context, value, _) {
            final currentInt = (value * 100).round();
            final bandColor = MatchBand.color(context, bounded);

            return SizedBox.square(
              dimension: scaledSize,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: value,
                    strokeWidth: widget.strokeWidth,
                    strokeCap: StrokeCap.round,
                    color: bandColor,
                    backgroundColor: AppColors.of(context).hairlineBorder,
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$currentInt%',
                          style:
                              (widget.size >= 80
                                      ? AppTypography.title
                                      : AppTypography.headline)
                                  .copyWith(
                                    color: AppColors.of(context).labelPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                        ),
                        if (widget.showLabel && widget.size >= 64)
                          Text(
                            'Match',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.of(context).labelSecondary,
                              fontSize: 10,
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
      ),
    );
  }
}

// Backward compatibility alias
typedef BandScoreRing = ScoreRing;
