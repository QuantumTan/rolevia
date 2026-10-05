import 'package:flutter/material.dart';

import '../design/colors.dart';
import '../design/motion.dart';
import '../design/radius.dart';
import '../design/spacing.dart';
import '../design/typography.dart';
import 'pressable.dart';

enum AppButtonVariant { primary, secondary, text, destructive }

/// Standardized action button:
/// - 50px height (well exceeding 44x44 minimum touch target)
/// - Capsule radius
/// - Variants: primary, secondary, text, destructive
/// - Built-in loading state with progress indicator
/// - Spring press feedback scale 0.98
/// - Respects reduce motion and accessibility semantics
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    this.label,
    this.child,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.height = 50.0,
    this.padding,
    this.semanticLabel,
  }) : assert(label != null || child != null, 'Provide either label or child');

  final VoidCallback? onPressed;
  final String? label;
  final Widget? child;
  final Widget? icon;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final double height;
  final EdgeInsetsGeometry? padding;
  final String? semanticLabel;

  const AppButton.primary({
    super.key,
    required this.onPressed,
    this.label,
    this.child,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.height = 50.0,
    this.padding,
    this.semanticLabel,
  }) : variant = AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.onPressed,
    this.label,
    this.child,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.height = 50.0,
    this.padding,
    this.semanticLabel,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.text({
    super.key,
    required this.onPressed,
    this.label,
    this.child,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.height = 50.0,
    this.padding,
    this.semanticLabel,
  }) : variant = AppButtonVariant.text;

  const AppButton.destructive({
    super.key,
    required this.onPressed,
    this.label,
    this.child,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.height = 50.0,
    this.padding,
    this.semanticLabel,
  }) : variant = AppButtonVariant.destructive;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = onPressed != null && !isLoading;

    Color bg;
    Color fg;
    Border? border;

    switch (variant) {
      case AppButtonVariant.primary:
        bg = isEnabled ? colors.accent : colors.accent.withValues(alpha: 0.35);
        fg = colors.onAccent;
        border = null;

      case AppButtonVariant.secondary:
        bg = isDark
            ? (isEnabled ? colors.elevatedSurface : colors.surface)
            : (isEnabled ? const Color(0xFFE2E8F0) : const Color(0xFFF1F5F9));
        fg = isEnabled ? colors.labelPrimary : colors.labelTertiary;
        border = Border.all(
          color: colors.hairlineBorder,
          width: AppRadius.hairline,
        );

      case AppButtonVariant.text:
        bg = Colors.transparent;
        fg = isEnabled ? colors.accent : colors.labelTertiary;
        border = null;

      case AppButtonVariant.destructive:
        bg = isDark ? colors.error.withValues(alpha: 0.2) : colors.diffPrunedBg;
        fg = isEnabled ? colors.error : colors.labelTertiary;
        border = Border.all(
          color: colors.error.withValues(alpha: isDark ? 0.3 : 0.2),
          width: AppRadius.hairline,
        );
    }

    Widget content;
    if (isLoading) {
      content = SizedBox.square(
        dimension: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(fg),
        ),
      );
    } else {
      final labelWidget =
          child ??
          Text(
            label ?? '',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: AppTypography.headline.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          );

      if (icon != null) {
        content = Row(
          mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconTheme(
              data: IconThemeData(color: fg, size: 18),
              child: icon!,
            ),
            const SizedBox(width: AppSpacing.s8),
            Flexible(child: labelWidget),
          ],
        );
      } else {
        content = labelWidget;
      }
    }

    final buttonBox = Container(
      constraints: BoxConstraints(
        minHeight: height,
        minWidth: isFullWidth ? double.infinity : 44.0,
      ),
      padding:
          padding ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s8,
          ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.capsuleRadius,
        border: border,
      ),
      alignment: Alignment.center,
      child: content,
    );

    return PressableScale(
      enabled: isEnabled,
      semanticLabel: semanticLabel ?? label,
      onPressed: isEnabled
          ? () {
              if (variant == AppButtonVariant.destructive) {
                AppMotion.destructiveConfirm();
              } else {
                AppMotion.segmentedControlOrChip();
              }
              onPressed?.call();
            }
          : null,
      child: buttonBox,
    );
  }
}
