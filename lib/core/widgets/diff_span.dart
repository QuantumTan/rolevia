import 'package:flutter/material.dart';

import '../design/colors.dart';
import '../design/radius.dart';
import '../design/spacing.dart';
import '../design/typography.dart';

enum DiffType {
  added,
  pruned,
  unchanged,
}

/// Renders resume / job diff text with high-contrast semantic highlighting.
class DiffSpan extends StatelessWidget {
  const DiffSpan({
    super.key,
    required this.text,
    required this.type,
    this.prefix,
  });

  final String text;
  final DiffType type;
  final String? prefix;

  const DiffSpan.added(this.text, {super.key, this.prefix = '+'})
      : type = DiffType.added;

  const DiffSpan.pruned(this.text, {super.key, this.prefix = '-'})
      : type = DiffType.pruned;

  const DiffSpan.unchanged(this.text, {super.key, this.prefix})
      : type = DiffType.unchanged;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    Color fg;
    Color bg;

    switch (type) {
      case DiffType.added:
        fg = colors.diffAddedText;
        bg = colors.diffAddedBg;
      case DiffType.pruned:
        fg = colors.diffPrunedText;
        bg = colors.diffPrunedBg;
      case DiffType.unchanged:
        fg = colors.labelPrimary;
        bg = Colors.transparent;
    }

    final displayText = prefix != null ? '$prefix $text' : text;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s8,
        vertical: AppSpacing.s4 / 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: type != DiffType.unchanged
            ? Border.all(
                color: fg.withValues(alpha: 0.25),
                width: 0.5,
              )
            : null,
      ),
      child: Text(
        displayText,
        style: AppTypography.mono.copyWith(
          color: fg,
          fontSize: 12,
          fontWeight: type != DiffType.unchanged ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}
