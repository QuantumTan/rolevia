import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/design/colors.dart';
import '../core/design/radius.dart';
import '../core/design/spacing.dart';
import '../core/design/typography.dart';
import '../core/widgets/adaptive_button.dart';
import '../core/widgets/adaptive_card.dart';
import '../core/widgets/app_top_bar.dart';
import '../core/widgets/pressable.dart';
import '../core/widgets/animated_count.dart';
import '../core/widgets/activity_chart.dart';
import '../models/models.dart';
import '../shared/widgets.dart';
import '../state/app_state.dart';
import '../core/design/motion.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key, this.isEmbedded = false});

  final bool isEmbedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final colors = AppColors.of(context);

    if (!state.authenticated) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: colors.paleIndigoSurface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: 36,
                    color: colors.accent,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Career Dashboard is Locked',
                  style: AppTypography.title2.copyWith(
                    color: colors.labelPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Please sign in to track your job applications metrics and career goals.',
                  style: AppTypography.body.copyWith(
                    color: colors.labelSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                AdaptiveButton.primary(
                  label: 'Sign in to access',
                  icon: const Icon(Icons.login_rounded, size: 18),
                  onPressed: () => context.go('/sign-in'),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
      child: ContentState(
        isLoading: !state.ready,
        onRetry: () => ref.invalidate(appControllerProvider),
        normal: CustomScrollView(
          key: const PageStorageKey('dashboard-scroll'),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            if (!isEmbedded)
              SliverAppTopBar(
                title: 'Dashboard',
                avatarLetter: state.profile.initialLetter,
                avatarUrl: state.profile.avatarUrl,
                expandedHeight: 64,
              ),
            if (isEmbedded)
              const SliverToBoxAdapter(
                child: SizedBox(height: 8),
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

                    RepaintBoundary(
                      child: ActivityChart(
                        state.applications.map((a) => a.appliedAt).toList(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Career Arena Launcher Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        border: Border.all(color: colors.borderSubtle),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: colors.paleIndigoSurface,
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                ),
                                child: Icon(Icons.sports_kabaddi_rounded, color: colors.accent, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Career Arena',
                                      style: AppTypography.headline.copyWith(
                                        color: colors.labelPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      'Practice AI interviews & roast resume blindspots',
                                      style: AppTypography.caption.copyWith(color: colors.labelSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: PressableScale(
                                  onPressed: () {
                                    AppMotion.selectionHaptic();
                                    context.push('/arena');
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: colors.paleIndigoSurface,
                                      borderRadius: BorderRadius.circular(AppRadius.md),
                                      border: Border.all(color: colors.accent.withValues(alpha: 0.3)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.mic_rounded, size: 16, color: colors.accent),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            'Mock Simulator',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTypography.footnote.copyWith(
                                              color: colors.accent,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: PressableScale(
                                  onPressed: () {
                                    AppMotion.selectionHaptic();
                                    context.push('/arena');
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: colors.diffPrunedBg,
                                      borderRadius: BorderRadius.circular(AppRadius.md),
                                      border: Border.all(color: colors.diffPrunedText.withValues(alpha: 0.3)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.local_fire_department_rounded, size: 16, color: colors.diffPrunedText),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            'Candid Critique',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTypography.footnote.copyWith(
                                              color: colors.diffPrunedText,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Recent analyses
                    Text(
                      'Recent analyses',
                      style: AppTypography.headline.copyWith(
                        color: colors.labelPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Review your previous matches and next steps.',
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
                          icon: const Icon(
                            Icons.analytics_outlined,
                            size: 18,
                          ),
                          onPressed: () => context.go('/match'),
                        ),
                      ),
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
