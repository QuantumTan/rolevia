import 'package:flutter/material.dart';

import '../design/colors.dart';
import '../design/radius.dart';
import '../design/spacing.dart';
import '../design/typography.dart';

/// Clean editorial section header:
/// - Headline style (17/600)
/// - Optional count pill with tabular figures
/// - Optional trailing action
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.count,
    this.actionLabel,
    this.onAction,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.s24, AppSpacing.s16, AppSpacing.s8),
  });

  final String title;
  final int? count;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Padding(
      padding: padding,
      child: Row(
        children: [
          Text(
            title,
            style: AppTypography.headline.copyWith(
              color: colors.labelPrimary,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: AppSpacing.s8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colors.elevatedSurface,
                borderRadius: AppRadius.capsuleRadius,
                border: Border.all(
                  color: colors.hairlineBorder,
                  width: AppRadius.hairline,
                ),
              ),
              child: Text(
                '$count',
                style: AppTypography.caption.copyWith(
                  color: colors.labelSecondary,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
          const Spacer(),
          if (trailing != null)
            trailing!
          else if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                minimumSize: const Size(44, 44),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                actionLabel!,
                style: AppTypography.caption.copyWith(
                  color: colors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
