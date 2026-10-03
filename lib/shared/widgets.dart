import 'package:flutter/material.dart';

import '../core/design/colors.dart';
import '../core/design/icons.dart';
import '../core/design/radius.dart';
import '../core/design/spacing.dart';
import '../core/design/typography.dart';
import '../core/widgets/adaptive_button.dart';
import '../core/widgets/adaptive_dialog.dart';
import '../core/widgets/liquid_glass.dart';
import '../core/widgets/skeleton.dart';
import '../core/widgets/score_ring.dart';
import '../core/widgets/product_illustration.dart';
export '../core/widgets/match_badge.dart';
export '../core/widgets/company_avatar.dart';
import '../models/models.dart';

export '../core/widgets/liquid_glass.dart';

/// Legacy adapter for GlassSurface delegating directly to refined LiquidGlass
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.radius = AppRadius.xl,
    this.solid = false,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final bool solid;

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      padding: padding,
      radius: radius,
      solid: solid,
      child: child,
    );
  }
}

class PageTitle extends StatelessWidget {
  const PageTitle(this.title, {super.key, this.subtitle, this.trailing});

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.largeTitle.copyWith(
                  color: colors.labelPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  subtitle!,
                  style: AppTypography.subheadline.copyWith(
                    color: colors.labelSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.illustration,
  });

  final IconData icon;
  final String title, message;
  final Widget? action;
  final String? illustration;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ProductIllustration(
              illustration ??
                  (icon == Icons.view_kanban_outlined
                      ? 'empty_tracker'
                      : icon == Icons.work_off_outlined ||
                            icon == Icons.search_off_rounded
                      ? 'empty_search'
                      : icon == Icons.history_rounded
                      ? 'empty_history'
                      : 'empty_vault'),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTypography.title3.copyWith(color: colors.labelPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.subheadline.copyWith(
                color: colors.labelSecondary,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorPanel extends StatelessWidget {
  const ErrorPanel({
    super.key,
    required this.onRetry,
    this.message = 'We could not load this view. Please try again.',
  });

  final VoidCallback onRetry;
  final String message;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: AppIcons.resolve(AppSemanticIcon.error, context),
      illustration: 'error_generic',
      title: 'Unable to load content',
      message: message,
      action: AdaptiveButton.secondary(
        onPressed: onRetry,
        icon: AppIcon(AppSemanticIcon.reset, size: 16),
        label: 'Retry',
      ),
    );
  }
}

class SkillWrap extends StatelessWidget {
  const SkillWrap(this.values, {super.key});

  final List<String> values;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: values.map((s) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: isDark ? const Color(0xFF38383A) : const Color(0xFFE5E7EB),
              width: 0.8,
            ),
          ),
          child: Text(
            s,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colors.labelPrimary,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class ScoreRing extends BandScoreRing {
  const ScoreRing(super.score, {super.key, super.size});
}

class ScenarioState extends StatelessWidget {
  const ScenarioState({
    super.key,
    required this.scenario,
    required this.normal,
    required this.onRetry,
    this.empty,
  });

  final dynamic scenario;
  final Widget normal;
  final Widget? empty;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    switch (scenario.toString().split('.').last) {
      case 'loading':
        return ListView(
          padding: AppSpacing.edgeInsetsScreen,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            SkeletonCard(),
            SizedBox(height: AppSpacing.md),
            SkeletonCard(),
            SizedBox(height: AppSpacing.md),
            SkeletonCard(),
          ],
        );
      case 'error':
        return ErrorPanel(onRetry: onRetry);
      case 'empty':
        return empty ??
            EmptyState(
              icon: AppIcons.resolve(AppSemanticIcon.document, context),
              title: 'Nothing here yet',
              message: 'Add an item to see it here.',
            );
      default:
        return normal;
    }
  }
}

Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Delete',
}) async {
  return await showAdaptiveConfirmDialog(
    context,
    title: title,
    message: message,
    confirmLabel: confirmLabel,
    isDestructive:
        confirmLabel.toLowerCase().contains('delete') ||
        confirmLabel.toLowerCase().contains('reset'),
  );
}

String shortDate(DateTime date) => '${date.month}/${date.day}/${date.year}';
String stageLabel(ApplicationStage value) => value.label;
