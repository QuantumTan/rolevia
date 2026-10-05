import 'package:flutter/material.dart';

import '../design/colors.dart';
import '../design/spacing.dart';
import '../design/typography.dart';
import 'app_button.dart';
import 'monoline_illustration.dart';

/// Error state communicating what happened and what action to take.
/// Features monoline alert graphic and primary retry button.
/// Strictly zero emojis.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.title,
    required this.message,
    this.graphic = MonolineGraphic.alertOctagon,
    this.retryLabel = 'Try again',
    this.onRetry,
    this.action,
  });

  final String title;
  final String message;
  final MonolineGraphic graphic;
  final String retryLabel;
  final VoidCallback? onRetry;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

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
            MonolineIllustration(graphic: graphic, size: 100),
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
            ] else if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.s24),
              AppButton.primary(
                label: retryLabel,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
