import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/brand.dart';
import '../core/design/colors.dart';
import '../core/design/motion.dart';
import '../core/design/radius.dart';
import '../core/design/spacing.dart';
import '../core/design/typography.dart';
import '../core/widgets/adaptive_button.dart';
import '../core/widgets/adaptive_card.dart';
import '../core/widgets/adaptive_dialog.dart';
import '../core/widgets/adaptive_sheet.dart';
import '../core/widgets/adaptive_switch.dart';
import '../core/widgets/adaptive_toast.dart';
import '../core/widgets/liquid_glass.dart';
import '../core/widgets/pressable.dart';
import '../data/fixtures.dart';
import '../models/models.dart';
import '../shared/widgets.dart';
import '../state/app_state.dart';

// Reusable pushed screen header with 44px circular glass back button
class PushedHeader extends StatelessWidget implements PreferredSizeWidget {
  const PushedHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final canPop = Navigator.canPop(context);

    return SafeArea(
      bottom: false,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            if (canPop)
              Tooltip(
                message: 'Back',
                child: Semantics(
                  label: 'Back',
                  child: PressableScale(
                    onPressed: () => Navigator.pop(context),
                    child: LiquidGlass(
                      borderRadius: BorderRadius.circular(AppRadius.capsule),
                      padding: EdgeInsets.zero,
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: colors.labelPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else
              const SizedBox(width: 44),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: AppTypography.headline.copyWith(
                  color: colors.labelPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            trailing ?? const SizedBox(width: 44),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// 1. JOB DETAIL SCREEN
// ──────────────────────────────────────────────
class JobDetailScreen extends ConsumerWidget {
  const JobDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final job = seedJobs.where((j) => j.id == id).firstOrNull ?? seedJobs.first;

    final (badgeBg, badgeFg) = switch (job.badgeTone) {
      'success' => (
        isDark ? const Color(0xFF173323) : const Color(0xFFE8F5E9),
        isDark ? const Color(0xFF9ED5AB) : const Color(0xFF2E7D32),
      ),
      'warning' => (
        isDark ? const Color(0xFF352B15) : const Color(0xFFFFF8E1),
        isDark ? const Color(0xFFE8C578) : const Color(0xFF8A5C13),
      ),
      _ => (colors.paleIndigoSurface, colors.primary),
    };

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const PushedHeader(title: 'Job Detail'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            AdaptiveCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colors.paleIndigoSurface,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          job.company.substring(0, 1),
                          style: TextStyle(
                            color: colors.primary,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.role,
                              style: AppTypography.title2.copyWith(
                                color: colors.labelPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              job.company,
                              style: AppTypography.headline.copyWith(
                                color: colors.labelSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 15,
                            color: colors.labelTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            job.location,
                            style: AppTypography.footnote.copyWith(
                              color: colors.labelSecondary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(
                            AppRadius.capsule,
                          ),
                        ),
                        child: Text(
                          job.badgeText ?? 'Tap to analyze',
                          style: TextStyle(
                            color: badgeFg,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Description',
              style: AppTypography.headline.copyWith(
                color: colors.labelPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            AdaptiveCard(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Join a fast-moving product team building reliable digital tools for customers across the Philippines. You will collaborate with designers, engineers, and support teams to ship thoughtful features.',
                style: AppTypography.body.copyWith(
                  color: colors.labelPrimary,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Requirements',
              style: AppTypography.headline.copyWith(
                color: colors.labelPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            AdaptiveCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _BulletItem(
                    'Fresh graduate or up to 2 years of relevant experience',
                  ),
                  SizedBox(height: 8),
                  _BulletItem(
                    'Strong communication and problem-solving skills',
                  ),
                  SizedBox(height: 8),
                  _BulletItem(
                    'Familiarity with Git, APIs, and modern web tools',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AdaptiveButton.primary(
              isFullWidth: true,
              onPressed: () {
                ref.read(appControllerProvider.notifier).selectForMatch(job.id);
                context.go('/match');
              },
              label: 'Run full analysis',
            ),
            const SizedBox(height: AppSpacing.sm),
            AdaptiveButton.secondary(
              isFullWidth: true,
              onPressed: () {
                ref.read(appControllerProvider.notifier).saveToWishlist(job);
                showGlassToast(
                  context,
                  'Saved to wishlist',
                  icon: Icons.bookmark_added_rounded,
                );
              },
              label: 'Save to wishlist',
            ),
          ],
        ),
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  const _BulletItem(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 7, right: 10),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: colors.primary,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: AppTypography.body.copyWith(
              color: colors.labelPrimary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// 2. MATCH RESULT SCREEN
// ──────────────────────────────────────────────
class MatchResultScreen extends ConsumerStatefulWidget {
  const MatchResultScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<MatchResultScreen> createState() => _MatchResultScreenState();
}

class _MatchResultScreenState extends ConsumerState<MatchResultScreen> {
  bool _matchedSkillsExpanded = true;

  void _openKeywordSheet(BuildContext context, String keyword) {
    showAdaptiveSheet(
      context: context,
      title: 'Add $keyword to your resume',
      builder: (sheetContext) {
        final colors = AppColors.of(context);
        final templateText =
            'Used $keyword in a project to describe your contribution. Achieved add a verified outcome.';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Only add this if it reflects your actual experience.',
                style: AppTypography.body.copyWith(
                  color: colors.labelSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AdaptiveCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BULLET TEMPLATE',
                      style: AppTypography.caption.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      templateText,
                      style: AppTypography.body.copyWith(
                        color: colors.labelPrimary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AdaptiveButton.primary(
                isFullWidth: true,
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: templateText));
                  if (context.mounted) {
                    Navigator.pop(sheetContext);
                    showGlassToast(
                      context,
                      'Copied template to clipboard',
                      icon: Icons.copy_rounded,
                    );
                  }
                },
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: 'Copy template',
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final match = ref.watch(
      appControllerProvider.select(
        (s) => s.matches.where((m) => m.id == widget.id).firstOrNull,
      ),
    );

    if (match == null) {
      return Scaffold(
        backgroundColor: colors.background,
        appBar: const PushedHeader(title: 'Analysis Results'),
        body: const Center(child: Text('Result not found')),
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const PushedHeader(title: 'Analysis Results'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            // Job & Resume header summary
            Text(
              '${match.role} · ${match.company}',
              style: AppTypography.title2.copyWith(
                color: colors.labelPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${match.location} · Resume: ${match.resumeTitle} · Sample results',
              style: AppTypography.footnote.copyWith(
                color: colors.labelSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Solid Score Card
            AdaptiveCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  _ScoreRing(score: match.overall),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          match.summaryTitle,
                          style: AppTypography.title2.copyWith(
                            color: colors.labelPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          match.summaryText,
                          style: AppTypography.footnote.copyWith(
                            color: colors.labelSecondary,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Solid status row: ATS formatting: Passed
            AdaptiveCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: colors.success,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'ATS formatting: Passed',
                      style: AppTypography.headline.copyWith(
                        color: colors.labelPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Missing keywords section
            Text(
              'Missing keywords (${match.missing.length})',
              style: AppTypography.headline.copyWith(
                color: colors.labelPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Add these where they accurately reflect your experience.',
              style: AppTypography.caption.copyWith(
                color: colors.labelSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: match.missing.map((keyword) {
                final errorBg = isDark
                    ? const Color(0xFF3B1F21)
                    : const Color(0xFFFFEBEE);
                final errorFg = isDark
                    ? const Color(0xFFF3A6A1)
                    : const Color(0xFFC62828);

                return PressableScale(
                  onPressed: () => _openKeywordSheet(context, keyword),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: errorBg,
                      borderRadius: BorderRadius.circular(AppRadius.capsule),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, size: 16, color: errorFg),
                        const SizedBox(width: 4),
                        Text(
                          keyword,
                          style: TextStyle(
                            color: errorFg,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Expandable Matched Skills Card
            AdaptiveCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PressableScale(
                    onPressed: () {
                      setState(() {
                        _matchedSkillsExpanded = !_matchedSkillsExpanded;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Matched skills (${match.matched.length})',
                          style: AppTypography.headline.copyWith(
                            color: colors.labelPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Icon(
                          _matchedSkillsExpanded
                              ? Icons.expand_less_rounded
                              : Icons.expand_more_rounded,
                          color: colors.labelSecondary,
                        ),
                      ],
                    ),
                  ),
                  if (_matchedSkillsExpanded) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: match.matched.map((skill) {
                        final successBg = isDark
                            ? const Color(0xFF173323)
                            : const Color(0xFFE8F5E9);
                        final successFg = isDark
                            ? const Color(0xFF9ED5AB)
                            : const Color(0xFF2E7D32);

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: successBg,
                            borderRadius: BorderRadius.circular(
                              AppRadius.capsule,
                            ),
                          ),
                          child: Text(
                            skill,
                            style: TextStyle(
                              color: successFg,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Disclosure
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                'Prototype preview: scores, skills, and ATS checks are sample data, not an assessment of your uploaded file.',
                style: AppTypography.caption.copyWith(
                  color: colors.labelTertiary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Actions
            AdaptiveButton.primary(
              isFullWidth: true,
              onPressed: () => context.push('/rewrites'),
              label: 'View bullet rewrites',
            ),
            const SizedBox(height: AppSpacing.sm),
            AdaptiveButton.secondary(
              isFullWidth: true,
              onPressed: () {
                final job =
                    seedJobs.where((j) => j.id == match.jobId).firstOrNull ??
                    Job(
                      id: 'j_match',
                      role: match.role,
                      company: match.company,
                      location: match.location,
                      mode: WorkMode.hybrid,
                      type: EmploymentType.fullTime,
                      postedDays: 1,
                      skills: match.matched,
                      overview: match.jobLabel,
                      responsibilities: const [],
                      qualifications: const [],
                      matchScore: match.overall,
                      badgeText: '${match.overall}% Match',
                    );
                ref.read(appControllerProvider.notifier).trackJob(job);
                showGlassToast(
                  context,
                  'Added to tracker',
                  icon: Icons.check_circle_rounded,
                );
              },
              label: 'Add to tracker',
            ),
            const SizedBox(height: AppSpacing.sm),
            AdaptiveButton.secondary(
              isFullWidth: true,
              onPressed: () => context.push('/interview'),
              label: 'Practice mock interview',
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: score / 100),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => SizedBox.square(
        dimension: 88,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CircularProgressIndicator(
              value: value,
              strokeWidth: 8,
              strokeCap: StrokeCap.round,
              valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
              backgroundColor: isDark
                  ? const Color(0xFF2C2C2E)
                  : const Color(0xFFE5E5EA),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(value * 100).round()}%',
                    style: AppTypography.title2.copyWith(
                      color: colors.labelPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Match',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: colors.labelSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// 3. BULLET REWRITES SCREEN
// ──────────────────────────────────────────────
class BulletRewritesScreen extends ConsumerWidget {
  const BulletRewritesScreen({super.key});

  static const pairs = [
    (
      'Worked on making the app faster',
      'Reduced app load time by 35% by caching API responses, improving retention for 2,000+ users',
    ),
    (
      'Helped fix bugs in the mobile app',
      'Resolved 40+ Flutter defects and reduced crash reports by 28% across Android devices',
    ),
    (
      'Made APIs for the team',
      'Built 6 REST API endpoints that cut mobile data retrieval time from 3.2s to 1.4s',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final state = ref.watch(appControllerProvider);
    final resumeTitle =
        state.resumes
            .where(
              (r) =>
                  r.id ==
                  (state.selectedMatchResumeId ?? state.defaultResumeId),
            )
            .firstOrNull
            ?.title ??
        'v2_IT_Final';

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const PushedHeader(title: 'Bullet Rewrites'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Text(
              'Rewrite examples for $resumeTitle',
              style: AppTypography.title2.copyWith(
                color: colors.labelPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                'These are sample bullets. Replace every metric with a verified result from your own experience.',
                style: AppTypography.footnote.copyWith(
                  color: colors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ...pairs.indexed.map((pair) {
              final index = pair.$1 + 1;
              final before = pair.$2.$1;
              final after = pair.$2.$2;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pair $index',
                      style: AppTypography.headline.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Before Card
                    AdaptiveCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Before',
                            style: AppTypography.caption.copyWith(
                              color: colors.labelTertiary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            before,
                            style: AppTypography.body.copyWith(
                              color: colors.labelSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // After (STAR) Card with Copy Button
                    AdaptiveCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'After (STAR)',
                                style: AppTypography.caption.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              PressableScale(
                                onPressed: () async {
                                  await Clipboard.setData(
                                    ClipboardData(text: after),
                                  );
                                  if (context.mounted) {
                                    showGlassToast(
                                      context,
                                      'Copied to clipboard',
                                      icon: Icons.copy_rounded,
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.paleIndigoSurface,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.capsule,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.copy_rounded,
                                        size: 14,
                                        color: colors.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Copy',
                                        style: TextStyle(
                                          color: colors.primary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            after,
                            style: AppTypography.body.copyWith(
                              color: colors.labelPrimary,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// 4. MOCK INTERVIEW SCREEN
// ──────────────────────────────────────────────
class MockInterviewScreen extends ConsumerStatefulWidget {
  const MockInterviewScreen({super.key});

  @override
  ConsumerState<MockInterviewScreen> createState() =>
      _MockInterviewScreenState();
}

class _MockInterviewScreenState extends ConsumerState<MockInterviewScreen> {
  bool _inProgress = false;
  String _selectedRole = 'Junior Flutter Developer';
  String _language = 'English'; // English | Taglish
  int _currentQuestionIndex = 0;
  final _answerController = TextEditingController();
  final List<String> _recordedAnswers = [];
  bool _submittedCurrentAnswer = false;

  static const englishQuestions = [
    'Alex, tell me about a time you learned a new technical skill.',
    'How do you approach debugging a slow application?',
    'Tell me about a time you worked through a disagreement in a team.',
    'How would you help a customer with a technical problem you haven’t seen before?',
    'Why are you interested in this role, and what would you like to learn?',
  ];

  static const taglishQuestions = [
    'Alex, kwento mo ang isang time na natuto ka ng bagong technical skill.',
    'Paano mo i-debug ang isang application na mabagal?',
    'Paano mo na-handle ang disagreement sa team?',
    'Paano mo tutulungan ang customer kung bago sa iyo ang technical problem?',
    'Bakit ka interested sa role na ito, at ano ang gusto mong matutunan?',
  ];

  @override
  void initState() {
    super.initState();
    _language = ref.read(appControllerProvider).profile.interviewLanguage;
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _submitAnswer() {
    final text = _answerController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _recordedAnswers.add(text);
      _submittedCurrentAnswer = true;
    });
    AppMotion.selectionHaptic();
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < 4) {
      setState(() {
        _currentQuestionIndex++;
        _submittedCurrentAnswer = false;
        _answerController.clear();
      });
    } else {
      // Completed all 5
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppColors.of(context).surface,
          title: const Text('Interview Complete!'),
          content: const Text(
            'You completed all 5 mock interview questions. Great job practicing your communication and STAR structure.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                setState(() {
                  _inProgress = false;
                  _currentQuestionIndex = 0;
                  _submittedCurrentAnswer = false;
                  _recordedAnswers.clear();
                  _answerController.clear();
                });
              },
              child: const Text('Practice Again'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final questions = _language == 'Taglish'
        ? taglishQuestions
        : englishQuestions;

    if (!_inProgress) {
      // SETUP SCREEN
      return Scaffold(
        backgroundColor: colors.background,
        appBar: const PushedHeader(title: 'Mock Interview'),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              Text(
                'Practice with confidence',
                style: AppTypography.largeTitle.copyWith(
                  color: colors.labelPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Five practice questions. Space to think. A simple tip after each answer.',
                style: AppTypography.body.copyWith(
                  color: colors.labelSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Role selector
              Text(
                'Target Role',
                style: AppTypography.headline.copyWith(
                  color: colors.labelPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Column(
                children: seedJobs.map((j) {
                  final isSelected = j.role == _selectedRole;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: PressableScale(
                      onPressed: () {
                        setState(() => _selectedRole = j.role);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors.paleIndigoSurface
                              : colors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: isSelected
                              ? Border.all(color: colors.primary, width: 1.5)
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              color: isSelected
                                  ? colors.primary
                                  : colors.labelTertiary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${j.role} (${j.company})',
                                style: AppTypography.body.copyWith(
                                  color: colors.labelPrimary,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Language selector
              Text(
                'Language',
                style: AppTypography.headline.copyWith(
                  color: colors.labelPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: ['English', 'Taglish'].map((lang) {
                  final isSelected = lang == _language;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: PressableScale(
                        onPressed: () {
                          setState(() => _language = lang);
                          ref
                              .read(appControllerProvider.notifier)
                              .updateProfile(
                                ref
                                    .read(appControllerProvider)
                                    .profile
                                    .copyWith(interviewLanguage: lang),
                              );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colors.primary
                                : colors.paleIndigoSurface,
                            borderRadius: BorderRadius.circular(
                              AppRadius.capsule,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            lang,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : colors.labelPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Mode selector (Text / Voice)
              Text(
                'Interview Mode',
                style: AppTypography.headline.copyWith(
                  color: colors.labelPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.capsule),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Text',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.capsule),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Voice',
                            style: TextStyle(
                              color: colors.labelTertiary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colors.paleIndigoSurface,
                              borderRadius: BorderRadius.circular(
                                AppRadius.capsule,
                              ),
                            ),
                            child: Text(
                              'Soon',
                              style: TextStyle(
                                color: colors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xxl),

              AdaptiveButton.primary(
                isFullWidth: true,
                onPressed: () {
                  setState(() {
                    _inProgress = true;
                    _currentQuestionIndex = 0;
                    _submittedCurrentAnswer = false;
                    _recordedAnswers.clear();
                  });
                },
                label: 'Start interview',
              ),
            ],
          ),
        ),
      );
    }

    // CHAT IN PROGRESS SCREEN
    final questionText = questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: colors.background,
      appBar: PushedHeader(
        title: 'Mock Interview · $_language',
        trailing: TextButton(
          onPressed: () {
            setState(() => _inProgress = false);
          },
          child: Text(
            'End',
            style: TextStyle(
              color: colors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Company Context Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.paleIndigoSurface,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      'Role: $_selectedRole · Question ${_currentQuestionIndex + 1} of 5',
                      style: AppTypography.footnote.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Solid Question Bubble
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width * 0.85,
                      ),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Interviewer',
                            style: AppTypography.caption.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            questionText,
                            style: AppTypography.body.copyWith(
                              color: colors.labelPrimary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Submitted user answer
                  if (_submittedCurrentAnswer &&
                      _recordedAnswers.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.sizeOf(context).width * 0.85,
                        ),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.paleIndigoSurface,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Alex',
                              style: AppTypography.caption.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _recordedAnswers.last,
                              style: AppTypography.body.copyWith(
                                color: colors.labelPrimary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Feedback card
                    AdaptiveCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: colors.success,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Answer recorded',
                                style: AppTypography.headline.copyWith(
                                  color: colors.labelPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Practice tip: Include the situation, your action, and the result. Keep your example specific.',
                            style: AppTypography.body.copyWith(
                              color: colors.labelPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Sample coaching · Your answer is not AI-scored.',
                            style: AppTypography.caption.copyWith(
                              color: colors.labelTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Bottom input bar or Next Question button
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(top: BorderSide(color: colors.separator)),
              ),
              child: _submittedCurrentAnswer
                  ? AdaptiveButton.primary(
                      isFullWidth: true,
                      onPressed: _nextQuestion,
                      label: _currentQuestionIndex == 4
                          ? 'Finish practice'
                          : 'Next question',
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _answerController,
                            minLines: 1,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Type your answer here...',
                              hintStyle: TextStyle(color: colors.labelTertiary),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.capsule,
                                ),
                                borderSide: BorderSide(color: colors.separator),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _answerController.text.trim().isNotEmpty
                              ? _submitAnswer
                              : null,
                          icon: Icon(
                            Icons.send_rounded,
                            color: _answerController.text.trim().isNotEmpty
                                ? colors.primary
                                : colors.labelTertiary,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// 5. PROFILE & SETTINGS SCREEN
// ──────────────────────────────────────────────
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _privacyExpanded = false;
  bool _termsExpanded = false;
  bool _motionNotesExpanded = false;

  void _confirmDeleteAccount() {
    showAdaptiveConfirmDialog(
      context,
      title: 'Delete account and data?',
      message: 'This will reset your demo session, resumes, tracker records, and quota to initial fixtures. It does not delete a real cloud account.',
      confirmLabel: 'Delete & Reset',
      isDestructive: true,
    ).then((confirmed) async {
      if (confirmed) {
        await ref.read(appControllerProvider.notifier).resetDemoSession();
        if (mounted) {
          showGlassToast(context, 'Demo session reset');
          context.go('/sign-in');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final state = ref.watch(appControllerProvider);
    final profile = state.profile;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const PushedHeader(title: 'Profile & Settings'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          children: [
            // User Header
            AdaptiveCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      profile.name.isNotEmpty
                          ? profile.name[0].toUpperCase()
                          : 'A',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name,
                          style: AppTypography.title2.copyWith(
                            color: colors.labelPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          profile.email,
                          style: AppTypography.footnote.copyWith(
                            color: colors.labelSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Plan Card
            AdaptiveCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Free plan',
                        style: AppTypography.headline.copyWith(
                          color: colors.labelPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: colors.paleIndigoSurface,
                          borderRadius: BorderRadius.circular(
                            AppRadius.capsule,
                          ),
                        ),
                        child: Text(
                          '${profile.scanQuota} scans left',
                          style: TextStyle(
                            color: colors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AdaptiveButton.secondary(
                    isFullWidth: true,
                    onPressed: () {
                      showGlassToast(
                        context,
                        'Upgrade plans are unavailable in this prototype',
                      );
                    },
                    label: 'Upgrade to Pro',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Appearance Section
            Text(
              'Appearance',
              style: AppTypography.headline.copyWith(
                color: colors.labelPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'One design, comfortable in any light.',
              style: AppTypography.caption.copyWith(
                color: colors.labelSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Light / Dark glass segmented control
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppRadius.capsule),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: PressableScale(
                      onPressed: () {
                        AppMotion.selectionHaptic();
                        ref
                            .read(appControllerProvider.notifier)
                            .updateProfile(
                              profile.copyWith(theme: AppTheme.light),
                            );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: profile.theme == AppTheme.light
                              ? colors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(
                            AppRadius.capsule,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Light',
                          style: TextStyle(
                            color: profile.theme == AppTheme.light
                                ? Colors.white
                                : colors.labelPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: PressableScale(
                      onPressed: () {
                        AppMotion.selectionHaptic();
                        ref
                            .read(appControllerProvider.notifier)
                            .updateProfile(
                              profile.copyWith(theme: AppTheme.dark),
                            );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: profile.theme == AppTheme.dark
                              ? colors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(
                            AppRadius.capsule,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Dark',
                          style: TextStyle(
                            color: profile.theme == AppTheme.dark
                                ? Colors.white
                                : colors.labelPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Reduce transparency switch
            AdaptiveCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reduce transparency',
                          style: AppTypography.body.copyWith(
                            color: colors.labelPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Makes navigation and controls solid',
                          style: AppTypography.caption.copyWith(
                            color: colors.labelSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AdaptiveSwitch(
                    value: profile.reduceTransparency,
                    onChanged: (val) {
                      ref
                          .read(appControllerProvider.notifier)
                          .updateProfile(
                            profile.copyWith(reduceTransparency: val),
                          );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Preferences Section
            Text(
              'Preferences',
              style: AppTypography.headline.copyWith(
                color: colors.labelPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            AdaptiveCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Interview language',
                    style: AppTypography.body.copyWith(
                      color: colors.labelPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: ['English', 'Taglish'].map((l) {
                      final isSelected = profile.interviewLanguage == l;
                      return Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: PressableScale(
                          onPressed: () {
                            ref
                                .read(appControllerProvider.notifier)
                                .updateProfile(
                                  profile.copyWith(interviewLanguage: l),
                                );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colors.primary
                                  : colors.paleIndigoSurface,
                              borderRadius: BorderRadius.circular(
                                AppRadius.capsule,
                              ),
                            ),
                            child: Text(
                              l,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : colors.labelPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Data storage & Sync
            Text(
              'Data',
              style: AppTypography.headline.copyWith(
                color: colors.labelPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            AdaptiveCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Data storage',
                        style: AppTypography.headline.copyWith(
                          color: colors.labelPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'This demo session',
                        style: AppTypography.caption.copyWith(
                          color: colors.labelSecondary,
                        ),
                      ),
                    ],
                  ),
                  AdaptiveButton.secondary(
                    onPressed: () {
                      showGlassToast(
                        context,
                        'Cloud sync is not connected in demo',
                      );
                    },
                    label: 'Sync now',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Inline expanders: Privacy & Terms & Prototype motion notes
            AdaptiveCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  PressableScale(
                    onPressed: () {
                      setState(() => _privacyExpanded = !_privacyExpanded);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Privacy policy',
                          style: AppTypography.headline.copyWith(
                            color: colors.labelPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(
                          _privacyExpanded
                              ? Icons.expand_less_rounded
                              : Icons.expand_more_rounded,
                          color: colors.labelSecondary,
                        ),
                      ],
                    ),
                  ),
                  if (_privacyExpanded) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Demo privacy notice: resume files are checked locally. No file contents are uploaded. Your changes last only for the current session and clear when you reload.',
                      style: AppTypography.footnote.copyWith(
                        color: colors.labelSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                  const Divider(height: 24),
                  PressableScale(
                    onPressed: () {
                      setState(() => _termsExpanded = !_termsExpanded);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Terms of service',
                          style: AppTypography.headline.copyWith(
                            color: colors.labelPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(
                          _termsExpanded
                              ? Icons.expand_less_rounded
                              : Icons.expand_more_rounded,
                          color: colors.labelSecondary,
                        ),
                      ],
                    ),
                  ),
                  if (_termsExpanded) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Demo terms: all companies, job listings, match scores, and analysis examples are fictional. This prototype does not submit applications or guarantee employment.',
                      style: AppTypography.footnote.copyWith(
                        color: colors.labelSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                  const Divider(height: 24),
                  PressableScale(
                    onPressed: () {
                      setState(
                        () => _motionNotesExpanded = !_motionNotesExpanded,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Prototype motion notes',
                          style: AppTypography.headline.copyWith(
                            color: colors.labelPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(
                          _motionNotesExpanded
                              ? Icons.expand_less_rounded
                              : Icons.expand_more_rounded,
                          color: colors.labelSecondary,
                        ),
                      ],
                    ),
                  ),
                  if (_motionNotesExpanded) ...[
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• Tabs: 200ms cross-fade',
                          style: AppTypography.caption.copyWith(
                            color: colors.labelSecondary,
                          ),
                        ),
                        Text(
                          '• Push / pop: 300ms slide · ease-out',
                          style: AppTypography.caption.copyWith(
                            color: colors.labelSecondary,
                          ),
                        ),
                        Text(
                          '• Sheets: 300ms spring-style slide-up',
                          style: AppTypography.caption.copyWith(
                            color: colors.labelSecondary,
                          ),
                        ),
                        Text(
                          '• Match score: 0 to value · 800ms',
                          style: AppTypography.caption.copyWith(
                            color: colors.labelSecondary,
                          ),
                        ),
                        Text(
                          '• Toasts: Fade in · hold 2s · fade out',
                          style: AppTypography.caption.copyWith(
                            color: colors.labelSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'System Reduce Motion disables movement. Glass is limited to navigation and controls; content stays solid.',
                          style: AppTypography.caption.copyWith(
                            color: colors.primary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Delete Account and Data button
            AdaptiveButton.destructive(
              isFullWidth: true,
              onPressed: _confirmDeleteAccount,
              label: 'Delete my account and data',
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// 6. SOCIAL SHARE MOCK SCREEN (/share)
// ──────────────────────────────────────────────
class SocialShareScreen extends StatelessWidget {
  const SocialShareScreen({super.key});

  void _openShareSheet(BuildContext context) {
    showAdaptiveSheet(
      context: context,
      title: 'Share with',
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PressableScale(
              onPressed: () {
                Navigator.pop(sheetContext);
                context.go('/match');
                showGlassToast(
                  context,
                  'Shared from Facebook',
                  icon: Icons.bolt_rounded,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.of(context).paleIndigoSurface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.of(context).primary,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Brand.appName,
                            style: AppTypography.headline.copyWith(
                              color: AppColors.of(context).labelPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Analyze this job description',
                            style: AppTypography.footnote.copyWith(
                              color: AppColors.of(context).labelSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const PushedHeader(title: 'Facebook Mock'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Facebook header
            Text(
              'facebook',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1877F2),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Social post card
            AdaptiveCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colors.paleIndigoSurface,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'N',
                          style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Northwind Digital',
                            style: AppTypography.headline.copyWith(
                              color: colors.labelPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Sponsored · Davao City',
                            style: AppTypography.caption.copyWith(
                              color: colors.labelTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Hiring: Junior Flutter Developer',
                    style: AppTypography.title2.copyWith(
                      color: colors.labelPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Northwind Digital is looking for a fresh graduate familiar with Flutter, REST APIs, Git, SQL, and Docker. Join our growing team!',
                    style: AppTypography.body.copyWith(
                      color: colors.labelPrimary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AdaptiveButton.primary(
                    isFullWidth: true,
                    onPressed: () => _openShareSheet(context),
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: 'Share to Job Matcher',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
