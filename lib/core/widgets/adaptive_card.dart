import 'package:flutter/material.dart';

import '../design/colors.dart';
import '../design/spacing.dart';
import 'app_card.dart';
import 'tactile_card.dart';

export 'app_card.dart';
export 'tactile_card.dart';

/// Backward-compatible AdaptiveCard wrapper delegating to AppCard or TactileCard
class AdaptiveCard extends StatelessWidget {
  const AdaptiveCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.edgeInsetsCard,
    this.margin,
    this.onTap,
    this.borderRadius,
    this.showBorder = true,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final bool showBorder;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (onTap != null) {
      return TactileCard(
        onTap: onTap,
        padding: padding,
        margin: margin,
        borderRadius: borderRadius,
        showBorder: showBorder,
        color: color,
        child: child,
      );
    }

    return AppCard(
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      showBorder: showBorder,
      color: color,
      child: child,
    );
  }
}

/// Inset-grouped container grouping related rows with subtle hairline separators.
class GroupedSection extends StatelessWidget {
  const GroupedSection({
    super.key,
    this.header,
    this.footer,
    required this.children,
    this.margin = const EdgeInsets.only(bottom: AppSpacing.lg),
  });

  final String? header;
  final String? footer;
  final List<Widget> children;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (header != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 6, AppSpacing.xs),
              child: Text(
                header!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.labelSecondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          AppCard(
            padding: EdgeInsets.zero,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: children.length,
              separatorBuilder: (_, _) => Divider(
                height: 1,
                thickness: 0.5,
                color: colors.hairlineBorder,
                indent: 16,
              ),
              itemBuilder: (_, index) => children[index],
            ),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(6, AppSpacing.xs, 6, 0),
              child: Text(
                footer!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.labelTertiary,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}
