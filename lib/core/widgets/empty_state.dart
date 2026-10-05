import 'package:flutter/material.dart';

import '../design/colors.dart';
import '../design/spacing.dart';
import '../design/typography.dart';
import 'app_button.dart';
import 'monoline_illustration.dart';

/// Clean editorial empty state:
/// - Monoline illustration with stroke reveal animation
/// - Terse functional headline and message
/// - Optional primary action button
/// - Strictly zero emojis
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.graphic = MonolineGraphic.emptyBox,
    this.icon,
    this.illustration,
    this.actionLabel,
    this.onAction,
    this.action,
  });

  final String title;
  final String message;
  final MonolineGraphic graphic;
  final IconData? icon;
  final String? illustration;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    MonolineGraphic displayGraphic = graphic;
    if (illustration != null) {
      if (illustration!.contains('search')) {
        displayGraphic = MonolineGraphic.searchVoid;
      } else if (illustration!.contains('tracker') || illustration!.contains('vault')) {
        displayGraphic = MonolineGraphic.emptyBox;
      } else if (illustration!.contains('offline')) {
        displayGraphic = MonolineGraphic.disconnectCloud;
      }
    } else if (icon != null) {
      if (icon == Icons.search_off_rounded || icon == Icons.work_off_outlined) {
        displayGraphic = MonolineGraphic.searchVoid;
      } else if (icon == Icons.wifi_off_rounded) {
        displayGraphic = MonolineGraphic.disconnectCloud;
      }
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s32,
          vertical: AppSpacing.s48,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MonolineIllustration(graphic: displayGraphic, size: 100),
            const SizedBox(height: AppSpacing.s24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.title.copyWith(
                color: colors.labelPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: colors.labelSecondary,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.s24),
              action!,
            ] else if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.s24),
              AppButton.primary(
                label: actionLabel!,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
