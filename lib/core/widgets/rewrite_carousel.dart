import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../design/motion.dart';
import 'adaptive_button.dart';

/// Each before/after pair stays together, with swipe and keyboard alternatives.
class RewriteCarousel extends StatefulWidget {
  const RewriteCarousel({super.key, required this.children});
  final List<Widget> children;
  @override
  State<RewriteCarousel> createState() => _RewriteCarouselState();
}

class _RewriteCarouselState extends State<RewriteCarousel> {
  int index = 0;
  void select(int next) {
    if (next < 0 || next >= widget.children.length) return;
    AppMotion.selectionHaptic();
    setState(() => index = next);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onHorizontalDragEnd: (details) {
      if ((details.primaryVelocity ?? 0).abs() > 100) {
        select(index + ((details.primaryVelocity ?? 0) < 0 ? 1 : -1));
      }
    },
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AdaptiveButton.tertiary(
                onPressed: index > 0 ? () => select(index - 1) : null,
                label: 'Previous',
              ),
            ),
            Semantics(
              liveRegion: true,
              label: 'Pair ${index + 1} of ${widget.children.length}',
              child: Row(
                children: List.generate(
                  widget.children.length,
                  (i) => AnimatedContainer(
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : UITokens.selection,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == index ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == index
                          ? AppColors.of(context).accent
                          : AppColors.of(context).separator,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: AdaptiveButton.tertiary(
                onPressed: index + 1 < widget.children.length
                    ? () => select(index + 1)
                    : null,
                label: 'Next',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        widget.children[index],
      ],
    ),
  );
}

/// Emphasizes the action verb and measured results without inventing metrics.
class BulletText extends StatelessWidget {
  const BulletText(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) {
    final pattern = RegExp(r'^\S+|\d[\d,.]*\+?%?');
    final spans = <TextSpan>[];
    int cursor = 0;
    for (final match in pattern.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(0),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      );
      cursor = match.end;
    }
    if (cursor < text.length) spans.add(TextSpan(text: text.substring(cursor)));
    return Text.rich(
      TextSpan(children: spans),
      style: AppTypography.body.copyWith(color: AppColors.of(context).success),
    );
  }
}
