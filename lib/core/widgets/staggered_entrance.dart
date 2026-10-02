import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A finite list reveal; stagger is capped so long lists remain responsive.
class StaggeredEntrance extends StatelessWidget {
  const StaggeredEntrance({super.key, required this.child, this.index = 0});
  final Widget child;
  final int index;
  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final delay = index.clamp(0, 4) * 40 / 300;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: UITokens.transition,
      child: child,
      builder: (context, value, child) {
        final fraction = Curves.easeOutCubic.transform(
          ((value - delay) / (1 - delay)).clamp(0, 1),
        );
        return Opacity(
          opacity: fraction,
          child: Transform.translate(
            offset: Offset(0, 8 * (1 - fraction)),
            child: child,
          ),
        );
      },
    );
  }
}
