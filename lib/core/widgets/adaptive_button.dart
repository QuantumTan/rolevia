import 'package:flutter/material.dart';

import '../design/colors.dart';
import '../design/motion.dart';
import '../design/radius.dart';
import '../design/spacing.dart';
import 'pressable.dart';

enum AdaptiveButtonVariant {
  primary,
  secondary,
  tertiary,
  destructive,
  compact,
}

/// Adaptive button honoring the 44pt target and subtle spring motion.
class AdaptiveButton extends StatelessWidget {
  const AdaptiveButton({
    super.key,
    required this.onPressed,
    this.label,
    this.child,
    this.icon,
    this.variant = AdaptiveButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
  }) : assert(label != null || child != null, 'Provide either label or child');

  final VoidCallback? onPressed;
  final String? label;
  final Widget? child;
  final Widget? icon;
  final AdaptiveButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final EdgeInsetsGeometry? padding;

  const AdaptiveButton.primary({
    super.key,
    required this.onPressed,
    this.label,
    this.child,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
  }) : variant = AdaptiveButtonVariant.primary;

  const AdaptiveButton.secondary({
    super.key,
    required this.onPressed,
    this.label,
    this.child,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
  }) : variant = AdaptiveButtonVariant.secondary;

  const AdaptiveButton.tertiary({
    super.key,
    required this.onPressed,
    this.label,
    this.child,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
  }) : variant = AdaptiveButtonVariant.tertiary;

  const AdaptiveButton.destructive({
    super.key,
    required this.onPressed,
    this.label,
    this.child,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
  }) : variant = AdaptiveButtonVariant.destructive;

  const AdaptiveButton.compact({
    super.key,
    required this.onPressed,
    this.label,
    this.child,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
  }) : variant = AdaptiveButtonVariant.compact;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = onPressed != null && !isLoading;

    Color bg;
    Color fg;
    Border? border;

    switch (variant) {
      case AdaptiveButtonVariant.primary:
        bg = isEnabled
            ? colors.primary
            : colors.primary.withValues(alpha: 0.35);
        fg = Colors.white;
        break;
      case AdaptiveButtonVariant.secondary:
        bg = isDark
            ? (isEnabled ? const Color(0xFF2C2C2E) : const Color(0xFF1C1C1E))
            : (isEnabled ? const Color(0xFFE5E5EA) : const Color(0xFFF2F2F7));
        fg = isEnabled ? colors.labelPrimary : colors.labelTertiary;
        break;
      case AdaptiveButtonVariant.tertiary:
        bg = Colors.transparent;
        fg = isEnabled ? colors.accent : colors.labelTertiary;
        break;
      case AdaptiveButtonVariant.destructive:
        bg = isDark ? const Color(0x33DC2626) : const Color(0x1FEF4444);
        fg = isEnabled ? colors.error : colors.error.withValues(alpha: 0.4);
        border = Border.all(
          color: colors.error.withValues(alpha: isDark ? 0.3 : 0.2),
          width: 1,
        );
        break;
      case AdaptiveButtonVariant.compact:
        bg = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);
        fg = isEnabled ? colors.labelPrimary : colors.labelTertiary;
        break;
    }

    final double minHeight = variant == AdaptiveButtonVariant.compact
        ? 44.0
        : 48.0;
    final double horizontalPadding = variant == AdaptiveButtonVariant.compact
        ? 12.0
        : 18.0;
    final double verticalPadding = variant == AdaptiveButtonVariant.compact
        ? 6.0
        : 12.0;

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
            label!,
            style: TextStyle(
              fontSize: variant == AdaptiveButtonVariant.compact ? 14 : 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
              color: fg,
            ),
          );

      if (icon != null) {
        content = Row(
          mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconTheme(
              data: IconThemeData(
                color: fg,
                size: variant == AdaptiveButtonVariant.compact ? 16 : 18,
              ),
              child: icon!,
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(child: labelWidget),
          ],
        );
      } else {
        content = labelWidget;
      }
    }

    final buttonCore = Container(
      constraints: BoxConstraints(
        minHeight: minHeight,
        minWidth: isFullWidth ? double.infinity : 44.0,
      ),
      padding:
          padding ??
          EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(
          variant == AdaptiveButtonVariant.compact
              ? AppRadius.sm
              : AppRadius.capsule,
        ),
        border: border,
      ),
      alignment: Alignment.center,
      child: content,
    );

    return PressableScale(
      enabled: isEnabled,
      onPressed: isEnabled
          ? () {
              if (variant == AdaptiveButtonVariant.destructive) {
                AppMotion.mediumHaptic();
              } else {
                AppMotion.lightHaptic();
              }
              onPressed?.call();
            }
          : null,
      child: buttonCore,
    );
  }
}
