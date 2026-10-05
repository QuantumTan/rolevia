import 'package:flutter/material.dart';

import '../design/colors.dart';
import '../design/spacing.dart';
import '../design/typography.dart';
import 'app_card.dart';

/// Compact data stat tile displaying key metrics (counts, percentages, currency):
/// - Label in Caption style
/// - Value in Title or Display style with tabular numerals
/// - Optional subtitle, trend indicator, or icon
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    this.icon,
    this.trend,
    this.trendPositive,
    this.onTap,
  });

  final String label;
  final String value;
  final String? subtitle;
  final Widget? icon;
  final String? trend;
  final bool? trendPositive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    Color? trendColor;
    if (trendPositive != null) {
      trendColor = trendPositive! ? colors.diffAddedText : colors.diffPrunedText;
    }

    final card = AppCard(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                IconTheme(
                  data: IconThemeData(size: 16, color: colors.labelSecondary),
                  child: icon!,
                ),
                const SizedBox(width: AppSpacing.s8),
              ],
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: colors.labelSecondary,
                  ),
                ),
              ),
              if (trend != null) ...[
                Text(
                  trend!,
                  style: AppTypography.caption.copyWith(
                    color: trendColor ?? colors.labelSecondary,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            value,
            style: AppTypography.title.copyWith(
              color: colors.labelPrimary,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.s4),
            Text(
              subtitle!,
              style: AppTypography.caption.copyWith(
                color: colors.labelTertiary,
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return card;

    return Semantics(
      button: true,
      label: '$label: $value',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: card,
      ),
    );
  }
}
