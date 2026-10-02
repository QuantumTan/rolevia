import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Finite count-up for local statistics, with a stable accessibility value.
class AnimatedCount extends StatelessWidget {
  const AnimatedCount(this.value, {super.key});
  final int value;
  @override
  Widget build(BuildContext context) => Semantics(
    label: '$value',
    excludeSemantics: true,
    child: TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : UITokens.transition,
      curve: Curves.easeOutCubic,
      builder: (context, count, _) => Text(
        '${count.round()}',
        style: AppTypography.largeTitle.copyWith(
          color: AppColors.of(context).accent,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    ),
  );
}
