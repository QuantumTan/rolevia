import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/design/colors.dart';
import '../core/design/radius.dart';
import '../core/design/spacing.dart';
import '../core/design/typography.dart';
import '../core/widgets/adaptive_button.dart';
import '../core/widgets/adaptive_card.dart';
import '../core/widgets/adaptive_toast.dart';
import '../core/widgets/app_top_bar.dart';
import '../core/widgets/pressable.dart';
import '../core/widgets/animated_count.dart';
import '../core/widgets/activity_chart.dart';
import '../models/models.dart';
import '../shared/widgets.dart';
import '../state/app_state.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  void _watchRewardedAd(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _DashboardAdDialog(
        onRewardGranted: () {
          ref.read(appControllerProvider.notifier).unlockRewardedScan();
          showGlassToast(context, '+1 scan unlocked', icon: Icons.bolt_rounded);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final colors = AppColors.of(context);

    final counts = stageCounts(state.applications);
    final appliedCount = counts[ApplicationStage.applied] ?? 0;
    final interviewsCount = counts[ApplicationStage.interview] ?? 0;
    final trackedCount = state.applications.length;
    final scansAvailable = state.profile.scanQuota;

    final stats = [
      ('Applied', '$appliedCount'),
      ('Interviews', '$interviewsCount'),
      ('Tracked roles', '$trackedCount'),
      ('Scans available', '$scansAvailable'),
    ];

    return SafeArea(
      bottom: false,
      child: ScenarioState(
        scenario: state.scenario,
        onRetry: () => ref
            .read(appControllerProvider.notifier)
            .setScenario(DemoScenario.normal),
        normal: CustomScrollView(
          key: const PageStorageKey('dashboard-scroll'),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverAppTopBar(
              title: 'Dashboard',
              subtitle: 'Small steps today. More possibilities tomorrow.',
              expandedHeight: 96,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 108),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 4 Solid Statistics Cards
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.maxWidth >= 720 ? 4 : 2;
                        final cardWidth =
                            (constraints.maxWidth - (columns - 1) * 12) /
                            columns;
                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: stats.map((s) {
                            return SizedBox(
                              width: cardWidth,
                              child: AdaptiveCard(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AnimatedCount(int.parse(s.$2)),
                                    const SizedBox(height: 4),
                                    Text(
                                      s.$1,
                                      style: AppTypography.footnote.copyWith(
                                        color: colors.labelSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    ActivityChart(
                      state.applications.map((a) => a.appliedAt).toList(),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Solid Reward Card
                    AdaptiveCard(
                      padding: const EdgeInsets.all(18),
                      child: Flex(
                        direction:
                            MediaQuery.sizeOf(context).width >= 900 &&
                                MediaQuery.textScalerOf(context).scale(17) < 26
                            ? Axis.horizontal
                            : Axis.vertical,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: colors.paleIndigoSurface,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.play_circle_outline_rounded,
                              color: colors.accent,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12, height: 12),
                          Flexible(
                            fit:
                                MediaQuery.sizeOf(context).width >= 900 &&
                                    MediaQuery.textScalerOf(context).scale(17) <
                                        26
                                ? FlexFit.tight
                                : FlexFit.loose,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Get another scan',
                                  style: AppTypography.headline.copyWith(
                                    color: colors.labelPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'A 5-second demo ad unlocks +1 scan',
                                  style: AppTypography.footnote.copyWith(
                                    color: colors.labelSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12, height: 12),
                          AdaptiveButton.primary(
                            onPressed: () => _watchRewardedAd(context, ref),
                            label: 'Watch ad',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Sample Analyses Section
                    Text(
                      'Sample analyses',
                      style: AppTypography.headline.copyWith(
                        color: colors.labelPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sample history data is illustrative, not an assessment of your uploaded file.',
                      style: AppTypography.caption.copyWith(
                        color: colors.labelTertiary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    if (state.matches.isEmpty)
                      EmptyState(
                        icon: Icons.history_rounded,
                        illustration: 'empty_history',
                        title: 'No analyses yet',
                        message: 'Run a match to see it here.',
                        action: AdaptiveButton.secondary(
                          label: 'Match a job',
                          icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                          onPressed: () => context.go('/match'),
                        ),
                      ),
                    // Sample Analyses Rows
                    ...state.matches.map((match) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: PressableScale(
                          onPressed: () {
                            context.push('/matches/${match.id}');
                          },
                          child: AdaptiveCard(
                            padding: const EdgeInsets.all(16),
                            child: Flex(
                              direction:
                                  MediaQuery.textScalerOf(context).scale(13) >
                                      18
                                  ? Axis.vertical
                                  : Axis.horizontal,
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment:
                                  MediaQuery.textScalerOf(context).scale(13) >
                                      18
                                  ? CrossAxisAlignment.start
                                  : CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  fit:
                                      MediaQuery.textScalerOf(context)
                                              .scale(13) >
                                          18
                                      ? FlexFit.loose
                                      : FlexFit.tight,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        match.role,
                                        style: AppTypography.headline.copyWith(
                                          color: colors.labelPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${match.company} · ${shortDate(match.createdAt)}',
                                        style: AppTypography.caption.copyWith(
                                          color: colors.labelSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12, height: 8),
                                Hero(
                                  tag: 'match-score-${match.id}',
                                  child: MatchBadge(match.overall),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: colors.labelTertiary,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardAdDialog extends StatefulWidget {
  const _DashboardAdDialog({required this.onRewardGranted});

  final VoidCallback onRewardGranted;

  @override
  State<_DashboardAdDialog> createState() => _DashboardAdDialogState();
}

class _DashboardAdDialogState extends State<_DashboardAdDialog> {
  int secondsRemaining = 5;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsRemaining > 1) {
        setState(() => secondsRemaining--);
      } else {
        timer?.cancel();
        setState(() => secondsRemaining = 0);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Advertisement',
                  style: AppTypography.caption.copyWith(
                    color: colors.labelTertiary,
                    letterSpacing: 0.5,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colors.paleIndigoSurface,
                    borderRadius: BorderRadius.circular(AppRadius.capsule),
                  ),
                  child: Text(
                    'Demo Ad',
                    style: TextStyle(
                      color: colors.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Icon(
              Icons.play_circle_fill_rounded,
              size: 56,
              color: colors.accent,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              secondsRemaining > 0 ? 'Ad playing' : 'Reward ready',
              style: AppTypography.title2.copyWith(
                color: colors.labelPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              secondsRemaining > 0
                  ? 'Close in ${secondsRemaining}s'
                  : 'Thanks for watching. You earned +1 scan!',
              style: AppTypography.body.copyWith(color: colors.labelSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            AdaptiveButton.primary(
              isFullWidth: true,
              onPressed: secondsRemaining == 0
                  ? () {
                      Navigator.pop(context);
                      widget.onRewardGranted();
                    }
                  : null,
              label: secondsRemaining == 0
                  ? 'Close & Collect'
                  : 'Watching ad...',
            ),
          ],
        ),
      ),
    ),
  );
  }
}
