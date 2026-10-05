import 'package:flutter/material.dart';

import '../design/colors.dart';
import '../design/radius.dart';
import '../design/spacing.dart';
import 'pressable.dart';

/// Content container following Job Matcher specifications:
/// Solid surfaces, 16px corners, no borders, shadow 0 1px 3px rgba(0,0,0,0.06).
class AdaptiveCard extends StatelessWidget {
  const AdaptiveCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.edgeInsetsCard,
    this.margin,
    this.onTap,
    this.borderRadius,
    this.showBorder = false,
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
    final colors = AppColors.of(context);
    final radius = borderRadius ?? AppRadius.cardRadius;

    final cardContent = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? colors.surface,
        borderRadius: radius,
        border: Border.all(
          color: colors.hairlineBorder,
          width: 1.0,
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      return PressableScale(onPressed: onTap, child: cardContent);
    }

    return cardContent;
  }
}

/// An iOS inset-grouped container that groups related rows with subtle separators.
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
                header!.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                  color: colors.labelSecondary,
                ),
              ),
            ),
          Material(
            color: colors.surface,
            borderRadius: AppRadius.cardRadius,
            elevation: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: AppRadius.cardRadius,
                border: Border.all(
                  color: colors.hairlineBorder,
                  width: 1.0,
                ),
              ),
              child: ClipRRect(
                borderRadius: AppRadius.cardRadius,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < children.length; i++) ...[
                      children[i],
                      if (i < children.length - 1)
                        Divider(
                          height: 1,
                          thickness: 0.8,
                          indent: 16,
                          endIndent: 0,
                          color: colors.separator,
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(6, AppSpacing.xs, 6, 0),
              child: Text(
                footer!,
                style: TextStyle(fontSize: 12, color: colors.labelTertiary),
              ),
            ),
        ],
      ),
    );
  }
}
