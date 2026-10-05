import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/brand.dart';
import '../core/config/app_config.dart';
import '../data/repositories/auth_repository.dart';
import '../core/design/colors.dart';
import '../core/design/motion.dart';
import '../core/design/radius.dart';
import '../core/design/spacing.dart';
import '../core/design/typography.dart';
import '../core/services/job_text_cleaner.dart';
import '../core/widgets/adaptive_button.dart';
import '../core/widgets/adaptive_card.dart';
import '../core/widgets/adaptive_dialog.dart';
import '../core/widgets/adaptive_sheet.dart';
import '../core/widgets/adaptive_switch.dart';
import '../core/widgets/adaptive_text_field.dart';
import '../core/widgets/adaptive_toast.dart';
import '../core/widgets/pressable.dart';
import '../core/widgets/copy_button.dart';
import '../core/widgets/rewrite_carousel.dart';
import '../core/widgets/job_description_view.dart';
import '../core/widgets/requirement_evidence.dart';
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
                excludeFromSemantics: true,
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
    final state = ref.watch(appControllerProvider);
    final job = state.jobs.where((j) => j.id == id).firstOrNull;
    if (job == null) {
      return const Scaffold(
        appBar: PushedHeader(title: 'Job Detail'),
        body: Center(child: Text('This job is not in your saved catalog.')),
      );
    }

    final (badgeBg, badgeFg) = switch (job.badgeTone) {
      'success' => (
        isDark ? const Color(0xFF173323) : const Color(0xFFE8F5E9),
        isDark ? const Color(0xFF9ED5AB) : const Color(0xFF2E7D32),
      ),
      'warning' => (
        isDark ? const Color(0xFF352B15) : const Color(0xFFFFF8E1),
        isDark ? const Color(0xFFE8C578) : const Color(0xFF8A5C13),
      ),
      _ => (colors.paleIndigoSurface, colors.accent),
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
                      Hero(
                        tag: 'company-${job.id}',
                        child: CompanyAvatar(job.company, size: 48),
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
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
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
            JobDescriptionView(
              result: JobTextCleaner.clean(
                job.originalDescription?.trim().isNotEmpty == true &&
                        job.originalDescription!.trim().length > 150
                    ? job.originalDescription!
                    : (job.responsibilities.isNotEmpty ||
                            job.qualifications.isNotEmpty
                        ? jobText(job)
                        : (job.originalDescription?.trim().isNotEmpty == true
                            ? job.originalDescription!
                            : job.overview)),
              ),
              forceTruncated: job.descriptionTruncated &&
                  (job.originalDescription?.trim().length ?? 0) < 100 &&
                  job.responsibilities.isEmpty &&
                  job.qualifications.isEmpty,
              initiallyExpanded: true,
            ),
            if (job.skills.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Key Skills & Technologies',
                style: AppTypography.headline.copyWith(
                  color: colors.labelPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              AdaptiveCard(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: job.skills
                      .map(
                        (skill) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: colors.paleIndigoSurface,
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                          ),
                          child: Text(
                            skill,
                            style: AppTypography.footnote.copyWith(
                              color: colors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
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
                children: job.qualifications.isNotEmpty
                    ? job.qualifications
                          .map(
                            (q) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _BulletItem(q),
                            ),
                          )
                          .toList()
                    : const [
                        _BulletItem(
                          'Relevant experience or coursework aligned with the role',
                        ),
                        SizedBox(height: 8),
                        _BulletItem(
                          'Strong communication and problem-solving skills',
                        ),
                        SizedBox(height: 8),
                        _BulletItem(
                          'Familiarity with industry-standard development and collaboration tools',
                        ),
                      ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (job.applicationUrl != null &&
                job.applicationUrl!.isNotEmpty) ...[
              AdaptiveButton.primary(
                isFullWidth: true,
                onPressed: () async {
                  final uri = Uri.tryParse(job.applicationUrl!);
                  if (uri != null) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.open_in_new_rounded, size: 20),
                label: 'Apply directly on Jooble / Employer',
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            AdaptiveButton.secondary(
              isFullWidth: true,
              onPressed: () {
                ref.read(appControllerProvider.notifier).selectForMatch(job.id);
                context.go('/match');
              },
              icon: const Icon(Icons.bolt_rounded, size: 20),
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
              icon: const Icon(Icons.bookmark_add_outlined, size: 20),
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
            color: colors.accent,
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
  bool _isTaglish = false;
  int _diffMode = 0; // 0: Diff View, 1: Clean AI
  int _activeDiffPairIndex = 0;
  String? _selectedMissingKeyword;

  Widget _buildMicroBar({
    required BuildContext context,
    required String label,
    required double value,
    required String ratioLabel,
    required Color barColor,
  }) {
    final colors = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: colors.labelSecondary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              ratioLabel,
              style: AppTypography.monoBadge.copyWith(
                color: colors.labelPrimary,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 5,
            backgroundColor: colors.borderSubtle,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }

  String _sampleBulletForKeyword(String keyword, bool isTaglish) {
    if (isTaglish) {
      return 'Ginamit ang $keyword sa pag-develop ng core system modules, nag-improve ng process throughput ng 35% ayon sa project deliverables.';
    }
    return 'Architected production services leveraging $keyword, decreasing deployment latency by 32% while sustaining 99.9% uptime.';
  }

  void _insertBulletIntoActiveResume(BuildContext context, String bullet) {
    final state = ref.read(appControllerProvider);
    final activeResume = state.resumes
        .where((r) => r.id == (state.selectedMatchResumeId ?? state.defaultResumeId))
        .firstOrNull;
    if (activeResume != null) {
      ref.read(appControllerProvider.notifier).updateResume(
        ResumeVersion(
          id: activeResume.id,
          title: activeResume.title,
          filename: activeResume.filename,
          fileType: activeResume.fileType,
          addedAt: DateTime.now(),
          isSample: activeResume.isSample,
          atsStatus: activeResume.atsStatus,
          summary: activeResume.summary,
          experience: [bullet, ...activeResume.experience],
          skills: activeResume.skills,
          education: activeResume.education,
          extractedText: '$bullet\n\n${activeResume.extractedText}',
          atsChecks: activeResume.atsChecks,
        ),
      );
      AppMotion.successHaptic();
      showGlassToast(context, 'Inserted bullet into active resume');
    } else {
      showGlassToast(context, 'No active resume found to update');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

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

    final diffPairs = match.suggestions.isNotEmpty
        ? match.suggestions
        : [
            const BulletSuggestion(
              'Handled customer complaints and technical tickets daily',
              'Resolved 45+ daily technical escalation tickets, maintaining a 96% CSAT across high-volume enterprise queues',
            ),
            const BulletSuggestion(
              'Assisted in writing code and fixing software bugs',
              'Engineered reusable Flutter/Dart UI modules with Riverpod state management, reducing app crash rate by 38%',
            ),
          ];

    final currentPair = diffPairs.isNotEmpty
        ? diffPairs[_activeDiffPairIndex.clamp(0, diffPairs.length - 1)]
        : const BulletSuggestion(
            'Handled customer complaints and tickets daily',
            'Resolved 45+ daily technical escalation tickets, maintaining a 96% CSAT',
          );

    return Scaffold(
      backgroundColor: colors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          bottom: false,
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(bottom: BorderSide(color: colors.borderSubtle)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, size: 20),
                  color: colors.labelPrimary,
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Back',
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${match.role} · ${match.company}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.subheadline.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.labelPrimary,
                        ),
                      ),
                      Text(
                        'Active: ${match.resumeTitle}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                          color: colors.labelSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Sticky Taglish / English toggle switch (EN / TL)
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(AppRadius.capsule),
                    border: Border.all(color: colors.borderSubtle),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          AppMotion.selectionHaptic();
                          setState(() => _isTaglish = false);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: !_isTaglish
                                ? colors.primary
                                : Colors.transparent,
                            borderRadius:
                                BorderRadius.circular(AppRadius.capsule),
                          ),
                          child: Text(
                            'EN',
                            style: AppTypography.monoBadge.copyWith(
                              color: !_isTaglish
                                  ? Colors.white
                                  : colors.labelSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          AppMotion.selectionHaptic();
                          setState(() => _isTaglish = true);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _isTaglish
                                ? colors.primary
                                : Colors.transparent,
                            borderRadius:
                                BorderRadius.circular(AppRadius.capsule),
                          ),
                          child: Text(
                            'TL',
                            style: AppTypography.monoBadge.copyWith(
                              color: _isTaglish
                                  ? Colors.white
                                  : colors.labelSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          children: [
            // 1. Hero Diagnostic Ring (High-Density Gauge with 3 micro-bars)
            RepaintBoundary(
              child: AdaptiveCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Hero(
                          tag: 'match-score-${match.id}',
                          child: ScoreRing(match.overall),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.background,
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.capsule),
                                      border:
                                          Border.all(color: colors.borderSubtle),
                                    ),
                                    child: Text(
                                      match.analysisLabel,
                                      style: AppTypography.monoBadge.copyWith(
                                        color: colors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  if (match.evidenceScore != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colors.background,
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.capsule,
                                        ),
                                        border: Border.all(
                                          color: colors.borderSubtle,
                                        ),
                                      ),
                                      child: Text(
                                        match.evidenceScore!.confidence.label,
                                        style: AppTypography.monoBadge.copyWith(
                                          color: colors.labelSecondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                MatchBand.verdict(match.overall),
                                style: AppTypography.title2.copyWith(
                                  color: colors.labelPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isTaglish
                                    ? (match.overall >= 80
                                        ? 'Magandang match para sa active resume mo. Handa na para sa application.'
                                        : 'May ilang gaps na kailangang i-align bago mag-submit.')
                                    : match.summaryText,
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
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 14),
                    // Micro-bars: Keyword Coverage, Experience Alignment, ATS Format Check
                    _buildMicroBar(
                      context: context,
                      label: 'Keyword Coverage',
                      value: (match.matched.length /
                              ((match.matched.length + match.missing.length)
                                  .clamp(1, 100)))
                          .clamp(0.0, 1.0),
                      ratioLabel:
                          '${match.matched.length}/${match.matched.length + match.missing.length}',
                      barColor: colors.primary,
                    ),
                    const SizedBox(height: 10),
                    _buildMicroBar(
                      context: context,
                      label: 'Experience Alignment',
                      value: ((match.components['Experience'] ??
                                  match.overall) /
                              100.0)
                          .clamp(0.0, 1.0),
                      ratioLabel:
                          '${match.components['Experience'] ?? match.overall}%',
                      barColor: colors.diffAddedText,
                    ),
                    const SizedBox(height: 10),
                    _buildMicroBar(
                      context: context,
                      label: 'ATS Format Compliance',
                      value: match.atsChecks.isEmpty
                          ? 1.0
                          : (match.atsChecks.values.where((v) => v).length /
                                  match.atsChecks.length)
                              .clamp(0.0, 1.0),
                      ratioLabel: match.atsChecks.isEmpty
                          ? 'Passed'
                          : '${match.atsChecks.values.where((v) => v).length}/${match.atsChecks.length} Passed',
                      barColor: (match.atsChecks.isEmpty ||
                              match.atsChecks.values.every((v) => v))
                          ? colors.diffAddedText
                          : colors.diffPrunedText,
                    ),
                  ],
                ),
              ),
            ),

            // Why this score card
            if (match.evidenceScore != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AdaptiveCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.analytics_outlined,
                          size: 20,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Why this score',
                            style: AppTypography.headline.copyWith(
                              color: colors.labelPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colors.background,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(color: colors.borderSubtle),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Must-have score',
                                  style: AppTypography.caption.copyWith(
                                    color: colors.labelSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${match.evidenceScore!.mustHave}/100',
                                  style: AppTypography.title3.copyWith(
                                    color: colors.labelPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colors.background,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(color: colors.borderSubtle),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nice-to-have score',
                                  style: AppTypography.caption.copyWith(
                                    color: colors.labelSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${match.evidenceScore!.niceToHave}/100',
                                  style: AppTypography.title3.copyWith(
                                    color: colors.labelPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: colors.background,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: colors.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            match.evidenceScore!.missingMustHaves == 0
                                ? Icons.check_circle_outline_rounded
                                : Icons.warning_amber_rounded,
                            size: 18,
                            color: match.evidenceScore!.missingMustHaves == 0
                                ? colors.success
                                : colors.warning,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              match.evidenceScore!.missingMustHaves == 0
                                  ? 'All required must-have items demonstrated in resume'
                                  : '${match.evidenceScore!.missingMustHaves} essential requirement(s) missing evidence',
                              style: AppTypography.body.copyWith(
                                color: colors.labelPrimary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: colors.background,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: colors.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            match.evidenceScore!.seniorityMismatch
                                ? Icons.warning_amber_rounded
                                : Icons.verified_user_outlined,
                            size: 18,
                            color: match.evidenceScore!.seniorityMismatch
                                ? colors.warning
                                : colors.success,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              match.evidenceScore!.seniorityMismatch
                                  ? 'Seniority mismatch: Job requires more experience than evidenced'
                                  : 'Seniority level matches position expectations',
                              style: AppTypography.body.copyWith(
                                color: colors.labelPrimary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (match.requirementMatches.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              RequirementEvidenceList(
                requirements: match.requirementMatches,
                onRequirementTap: (m) =>
                    showRequirementEvidenceSheet(context, m),
              ),
            ],

            const SizedBox(height: AppSpacing.lg),

            // 2. Interactive Visual Diff Engine (Inline)
            AdaptiveCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Text(
                        'Visual Diff Engine',
                        style: AppTypography.headline.copyWith(
                          color: colors.labelPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      // Segmented toggle: [Diff View] | [Clean AI]
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: colors.background,
                          borderRadius:
                              BorderRadius.circular(AppRadius.capsule),
                          border: Border.all(color: colors.borderSubtle),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                AppMotion.selectionHaptic();
                                setState(() => _diffMode = 0);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _diffMode == 0
                                      ? colors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.capsule,
                                  ),
                                ),
                                child: Text(
                                  'Diff View',
                                  style: AppTypography.caption.copyWith(
                                    color: _diffMode == 0
                                        ? Colors.white
                                        : colors.labelSecondary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                AppMotion.selectionHaptic();
                                setState(() => _diffMode = 1);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _diffMode == 1
                                      ? colors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.capsule,
                                  ),
                                ),
                                child: Text(
                                  'Clean AI',
                                  style: AppTypography.caption.copyWith(
                                    color: _diffMode == 1
                                        ? Colors.white
                                        : colors.labelSecondary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_diffMode == 0) ...[
                    // GitHub-style Diff View: Strikethrough on passive verb in red, green highlight on quantified metrics
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.background,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: colors.borderSubtle),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colors.diffPrunedBg,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.xs),
                            ),
                            child: Text(
                              '- Passive / Unquantified',
                              style: AppTypography.monoBadge.copyWith(
                                color: colors.diffPrunedText,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            currentPair.original,
                            style: AppTypography.body.copyWith(
                              color: colors.diffPrunedText,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: colors.diffPrunedText,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colors.diffAddedBg,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.xs),
                            ),
                            child: Text(
                              '+ Quantified Impact',
                              style: AppTypography.monoBadge.copyWith(
                                color: colors.diffAddedText,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            currentPair.suggested,
                            style: AppTypography.mono.copyWith(
                              color: colors.diffAddedText,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Clean AI View
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.background,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: colors.borderSubtle),
                      ),
                      child: Text(
                        currentPair.suggested,
                        style: AppTypography.body.copyWith(
                          color: colors.labelPrimary,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  // Pair navigation if multiple
                  if (diffPairs.length > 1) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Bullet ${_activeDiffPairIndex + 1} of ${diffPairs.length}',
                            style: AppTypography.caption.copyWith(
                              color: colors.labelSecondary,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left_rounded),
                              tooltip: 'Previous bullet',
                              onPressed: _activeDiffPairIndex > 0
                                  ? () {
                                      AppMotion.selectionHaptic();
                                      setState(
                                        () => _activeDiffPairIndex--,
                                      );
                                    }
                                  : null,
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right_rounded),
                              tooltip: 'Next bullet',
                              onPressed:
                                  _activeDiffPairIndex < diffPairs.length - 1
                                      ? () {
                                          AppMotion.selectionHaptic();
                                          setState(
                                            () => _activeDiffPairIndex++,
                                          );
                                        }
                                      : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  // Tactile [Copy] and [Insert into Active Resume] action buttons
                  Row(
                    children: [
                      Expanded(
                        child: AdaptiveButton.secondary(
                          icon: const Icon(Icons.copy_rounded, size: 16),
                          label: 'Copy Bullet',
                          onPressed: () async {
                            AppMotion.selectionHaptic();
                            await Clipboard.setData(
                              ClipboardData(text: currentPair.suggested),
                            );
                            if (context.mounted) {
                              showGlassToast(
                                context,
                                'Copied improved bullet to clipboard',
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AdaptiveButton.primary(
                          icon: const Icon(Icons.file_upload_outlined, size: 16),
                          label: 'Insert in Resume',
                          onPressed: () => _insertBulletIntoActiveResume(
                            context,
                            currentPair.suggested,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // 3. Gaps to close section
            if (match.missing.isNotEmpty) ...[
              Text(
                'Gaps to close (${match.missing.length})',
                style: AppTypography.headline.copyWith(
                  color: colors.labelPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Don’t add skills you don’t have. Only include genuine experience with verified outcomes.',
                style: AppTypography.caption.copyWith(
                  color: colors.labelSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: match.missing.map((keyword) {
                  final isSelected = _selectedMissingKeyword == keyword;
                  return PressableScale(
                    onPressed: () {
                      AppMotion.selectionHaptic();
                      final sample = _sampleBulletForKeyword(keyword, _isTaglish);
                      showAdaptiveSheet(
                        context: context,
                        title: 'Insert $keyword',
                        builder: (sheetContext) => Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Suggested addition for $keyword:',
                                style: AppTypography.subheadline.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colors.labelSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colors.paleIndigoSurface,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md),
                                  border: Border.all(color: colors.borderSubtle),
                                ),
                                child: Text(
                                  sample,
                                  style: AppTypography.body.copyWith(
                                    color: colors.labelPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              CopyButton(sample),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.diffPrunedBg
                            : colors.surface,
                        borderRadius:
                            BorderRadius.circular(AppRadius.capsule),
                        border: Border.all(
                          color: isSelected
                              ? colors.diffPrunedText
                              : colors.borderSubtle,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_rounded,
                            size: 14,
                            color: isSelected
                                ? colors.diffPrunedText
                                : colors.labelSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            keyword,
                            style: AppTypography.monoBadge.copyWith(
                              color: isSelected
                                  ? colors.diffPrunedText
                                  : colors.labelPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              // Expandable sample bullet drawer for selected keyword
              if (_selectedMissingKeyword != null) ...[
                const SizedBox(height: 10),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: colors.primary, width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Ethical Insertion: + $_selectedMissingKeyword',
                            style: AppTypography.caption.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 16),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => setState(
                              () => _selectedMissingKeyword = null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _sampleBulletForKeyword(
                          _selectedMissingKeyword!,
                          _isTaglish,
                        ),
                        style: AppTypography.body.copyWith(
                          color: colors.labelPrimary,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 10),
                      AdaptiveButton.secondary(
                        icon: const Icon(Icons.copy_rounded, size: 14),
                        label: 'Copy Suggested Bullet',
                        onPressed: () async {
                          AppMotion.selectionHaptic();
                          await Clipboard.setData(
                            ClipboardData(
                              text: _sampleBulletForKeyword(
                                _selectedMissingKeyword!,
                                _isTaglish,
                              ),
                            ),
                          );
                          if (context.mounted) {
                            showGlassToast(
                              context,
                              'Sample bullet copied to clipboard',
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
            ],

            // 4. Matched Skills Section
            if (match.matched.isNotEmpty) ...[
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
                          Expanded(
                            child: Text(
                              'Matched Skills (${match.matched.length})',
                              style: AppTypography.headline.copyWith(
                                color: colors.labelPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
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
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: colors.diffAddedBg,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.capsule),
                              border: Border.all(
                                color: colors.diffAddedText.withValues(
                                  alpha: 0.35,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              skill,
                              style: AppTypography.monoBadge.copyWith(
                                color: colors.diffAddedText,
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
            ],

            AdaptiveButton.secondary(
              isFullWidth: true,
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: match.markdownReport));
                if (context.mounted) {
                  showGlassToast(
                    context,
                    'Report copied as Markdown',
                  );
                }
              },
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: 'Export Report',
            ),
            const SizedBox(height: AppSpacing.md),

            // Disclosure banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: colors.hairlineBorder, width: 0.5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: colors.labelSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Results are guidance, not a hiring prediction. Scores reflect evidence extracted directly from your resume text and never invent experience.',
                      style: AppTypography.caption.copyWith(
                        color: colors.labelSecondary,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // 5. Pinned Bottom Action Bar
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(top: BorderSide(color: colors.borderSubtle)),
          ),
          child: Row(
            children: [
              Expanded(
                child: AdaptiveButton.secondary(
                  icon: const Icon(
                    Icons.playlist_add_check_rounded,
                    size: 18,
                  ),
                  label: 'Add to Pipeline (Applied)',
                  onPressed: () {
                    AppMotion.selectionHaptic();
                    ref.read(appControllerProvider.notifier).trackJob(
                      Job(
                        id: match.jobId ?? '',
                        role: match.role,
                        company: match.company,
                        location: match.location,
                        overview: match.jobDescription,
                        mode: WorkMode.hybrid,
                        type: EmploymentType.fullTime,
                        postedDays: 0,
                        skills: match.matched,
                        responsibilities: const [],
                        qualifications: const [],
                      ),
                      resumeId: match.resumeId,
                      stage: ApplicationStage.applied,
                    );
                    showGlassToast(
                      context,
                      'Moved ${match.role} to Applied in Pipeline',
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AdaptiveButton.primary(
                  icon: const Icon(Icons.mic_rounded, size: 18),
                  label: 'Practice Interview',
                  onPressed: () {
                    AppMotion.selectionHaptic();
                    context.push('/interview');
                  },
                ),
              ),
            ],
          ),
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
        'your resume';
    final pairs =
        state.matches.firstOrNull?.suggestions
            .map((s) => (s.original, s.suggested))
            .toList() ??
        <(String, String)>[];

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const PushedHeader(title: 'Bullet Rewrites'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Text(
              'Resume wording for $resumeTitle',
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
                'Use an action, the work you did, and an outcome you can verify. Local comparisons do not invent achievements or metrics.',
                style: AppTypography.footnote.copyWith(
                  color: colors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (pairs.isNotEmpty)
              RewriteCarousel(
                children: pairs.indexed.map((pair) {
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
                            color: colors.accent,
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
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xs,
                          ),
                          child: Icon(
                            Icons.arrow_downward_rounded,
                            color: colors.labelSecondary,
                            size: 20,
                          ),
                        ),
                        // After (STAR) Card with Copy Button
                        AdaptiveCard(
                          color: colors.success.withValues(alpha: 0.10),
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'After (STAR)',
                                      style: AppTypography.caption.copyWith(
                                        color: colors.accent,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  CopyButton(after),
                                ],
                              ),
                              const SizedBox(height: 6),
                              BulletText(after),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
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
  final ScrollController _chatScroll = ScrollController();
  final _answerController = TextEditingController();
  final List<String> _recordedAnswers = [];
  bool _submittedCurrentAnswer = false;

  static const englishQuestions = [
    'Tell me about a time you learned a new technical skill.',
    'How do you approach debugging a slow application?',
    'Tell me about a time you worked through a disagreement in a team.',
    'How would you help a customer with a technical problem you haven’t seen before?',
    'Why are you interested in this role, and what would you like to learn?',
  ];

  static const taglishQuestions = [
    'Kwento mo ang isang time na natuto ka ng bagong technical skill.',
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
    _chatScroll.dispose();
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_chatScroll.hasClients) return;
      final end = _chatScroll.position.maxScrollExtent;
      if (MediaQuery.disableAnimationsOf(context)) {
        _chatScroll.jumpTo(end);
      } else {
        _chatScroll.animateTo(
          end,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
        builder: (dialogContext) {
          final dialogColors = AppColors.of(context);
          return Dialog(
            backgroundColor: dialogColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: dialogColors.paleIndigoSurface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.celebration_rounded,
                        color: dialogColors.accent,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Interview complete!',
                      style: AppTypography.title2.copyWith(
                        color: dialogColors.labelPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'You completed all 5 mock interview questions. Great job practicing your communication and STAR structure.',
                      style: AppTypography.body.copyWith(
                        color: dialogColors.labelSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AdaptiveButton.primary(
                      isFullWidth: true,
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        Navigator.pop(context);
                      },
                      label: 'Done',
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    AdaptiveButton.tertiary(
                      isFullWidth: true,
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
                      label: 'Practice again',
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
                children: ref.watch(appControllerProvider).jobs.map((j) {
                  final isSelected = j.role == _selectedRole;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: PressableScale(
                      onPressed: () {
                        setState(() => _selectedRole = j.role);
                      },
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 52),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors.paleIndigoSurface
                              : colors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: isSelected
                              ? Border.all(color: colors.accent, width: 1.5)
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              color: isSelected
                                  ? colors.accent
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
                          constraints: const BoxConstraints(minHeight: 44),
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
                      constraints: const BoxConstraints(minHeight: 44),
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
                      constraints: const BoxConstraints(minHeight: 44),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.capsule),
                      ),
                      alignment: Alignment.center,
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
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
                                color: colors.accent,
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
            style: TextStyle(color: colors.accent, fontWeight: FontWeight.w700),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                controller: _chatScroll,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
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
                        color: colors.accent,
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
                              color: colors.accent,
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
                              'You',
                              style: AppTypography.caption.copyWith(
                                color: colors.accent,
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
                            'Practice guidance · Your answer is not scored.',
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
                              filled: true,
                              fillColor: colors.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.capsule,
                                ),
                                borderSide: BorderSide(color: colors.separator),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.capsule,
                                ),
                                borderSide: BorderSide(color: colors.separator),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.capsule,
                                ),
                                borderSide: BorderSide(
                                  color: colors.accent,
                                  width: 1.5,
                                ),
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
                          constraints: const BoxConstraints(
                            minWidth: 44,
                            minHeight: 44,
                          ),
                          tooltip: 'Send answer',
                          onPressed: _answerController.text.trim().isNotEmpty
                              ? _submitAnswer
                              : null,
                          icon: Icon(
                            Icons.send_rounded,
                            color: _answerController.text.trim().isNotEmpty
                                ? colors.accent
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
  bool _syncing = false;

  Future<void> _pickProfileImage() async {
    try {
      final file = await FilePicker.pickFile(type: FileType.image);
      final path = file?.path;
      if (path != null && path.isNotEmpty) {
        final profile = ref.read(appControllerProvider).profile;
        ref
            .read(appControllerProvider.notifier)
            .updateProfile(profile.copyWith(avatarUrl: path));
        if (mounted) {
          showGlassToast(context, 'Profile picture updated');
        }
      }
    } catch (e) {
      if (mounted) {
        showGlassToast(context, 'Could not select image: $e');
      }
    }
  }

  void _editNameDialog() {
    final profile = ref.read(appControllerProvider).profile;
    final controller = TextEditingController(text: profile.name);
    showAdaptiveSheet<void>(
      context: context,
      title: 'Edit Name',
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdaptiveTextField(
              controller: controller,
              labelText: 'Full Name',
              hintText: 'Enter your name',
              autofocus: true,
            ),
            const SizedBox(height: 16),
            AdaptiveButton.primary(
              onPressed: () {
                final newName = controller.text.trim();
                ref
                    .read(appControllerProvider.notifier)
                    .updateProfile(profile.copyWith(name: newName));
                Navigator.of(sheetContext).pop();
                showGlassToast(context, 'Name updated');
              },
              label: 'Save',
            ),
          ],
        ),
      ),
    );
  }

  void _editHeadlineDialog() {
    final profile = ref.read(appControllerProvider).profile;
    final controller = TextEditingController(text: profile.headline);
    showAdaptiveSheet<void>(
      context: context,
      title: 'Professional Headline',
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdaptiveTextField(
              controller: controller,
              labelText: 'Headline',
              hintText: 'e.g. Senior Flutter Developer, UI/UX Designer',
              autofocus: true,
            ),
            const SizedBox(height: 16),
            AdaptiveButton.primary(
              onPressed: () {
                final text = controller.text.trim();
                ref
                    .read(appControllerProvider.notifier)
                    .updateProfile(profile.copyWith(headline: text));
                Navigator.of(sheetContext).pop();
                showGlassToast(context, 'Headline updated');
              },
              label: 'Save',
            ),
          ],
        ),
      ),
    );
  }

  void _editBioDialog() {
    final profile = ref.read(appControllerProvider).profile;
    final controller = TextEditingController(text: profile.bio);
    showAdaptiveSheet<void>(
      context: context,
      title: 'About Me',
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdaptiveTextField(
              controller: controller,
              labelText: 'Short Bio',
              hintText: 'Brief summary of your professional background...',
              maxLines: 3,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            AdaptiveButton.primary(
              onPressed: () {
                final text = controller.text.trim();
                ref
                    .read(appControllerProvider.notifier)
                    .updateProfile(profile.copyWith(bio: text));
                Navigator.of(sheetContext).pop();
                showGlassToast(context, 'Bio updated');
              },
              label: 'Save',
            ),
          ],
        ),
      ),
    );
  }

  void _editSalaryDialog() {
    final profile = ref.read(appControllerProvider).profile;
    final controller = TextEditingController(
      text: profile.expectedSalary != null
          ? profile.expectedSalary.toString()
          : '',
    );
    showAdaptiveSheet<void>(
      context: context,
      title: 'Target Monthly Salary (PHP)',
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdaptiveTextField(
              controller: controller,
              labelText: 'Monthly Salary in PHP',
              hintText: 'e.g. 50000',
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            AdaptiveButton.primary(
              onPressed: () {
                final text = controller.text.trim();
                final salary = int.tryParse(text);
                ref
                    .read(appControllerProvider.notifier)
                    .updateProfile(profile.copyWith(expectedSalary: salary));
                Navigator.of(sheetContext).pop();
                showGlassToast(context, 'Target salary updated');
              },
              label: 'Save',
            ),
          ],
        ),
      ),
    );
  }

  void _addSkillDialog() {
    final profile = ref.read(appControllerProvider).profile;
    final controller = TextEditingController();
    showAdaptiveSheet<void>(
      context: context,
      title: 'Add Skill',
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdaptiveTextField(
              controller: controller,
              labelText: 'Skill or Tool',
              hintText: 'e.g. Flutter, Dart, TypeScript, SQL',
              autofocus: true,
            ),
            const SizedBox(height: 16),
            AdaptiveButton.primary(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty && !profile.primarySkills.contains(text)) {
                  final updated = List<String>.from(profile.primarySkills)
                    ..add(text);
                  ref
                      .read(appControllerProvider.notifier)
                      .updateProfile(profile.copyWith(primarySkills: updated));
                }
                Navigator.of(sheetContext).pop();
                showGlassToast(context, 'Skill added');
              },
              label: 'Add',
            ),
          ],
        ),
      ),
    );
  }

  void _removeProfilePhoto() {
    final profile = ref.read(appControllerProvider).profile;
    ref
        .read(appControllerProvider.notifier)
        .updateProfile(profile.copyWith(avatarUrl: ''));
    showGlassToast(context, 'Photo removed');
  }

  void _confirmDeleteAccount() {
    showAdaptiveConfirmDialog(
      context,
      title: 'Clear local workspace?',
      message: 'This removes resumes, match history, and applications stored on this device. This cannot be undone.',
      confirmLabel: 'Clear workspace',
      isDestructive: true,
    ).then((confirmed) async {
      if (confirmed) {
        await ref.read(appControllerProvider.notifier).reset();
        if (mounted) {
          showGlassToast(context, 'Workspace reset');
          context.go('/sign-in');
        }
      }
    });
  }

  Widget _buildAccentPicker(AppColors colors, ProfileSettings profile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: AppAccentColor.values.map((accent) {
        final isSelected = profile.accentColor == accent;
        final previewColor = switch (accent) {
          AppAccentColor.indigo => const Color(0xFF3F51B5),
          AppAccentColor.ocean => const Color(0xFF0284C7),
          AppAccentColor.emerald => const Color(0xFF059669),
          AppAccentColor.violet => const Color(0xFF7C3AED),
          AppAccentColor.coral => const Color(0xFFE11D48),
        };
        return PressableScale(
          onPressed: () {
            AppMotion.selectionHaptic();
            ref
                .read(appControllerProvider.notifier)
                .updateProfile(profile.copyWith(accentColor: accent));
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: previewColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? colors.labelPrimary
                        : colors.hairlineBorder,
                    width: isSelected ? 2.5 : 1,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 22,
                      )
                    : null,
              ),
              const SizedBox(height: 6),
              Text(
                accent.label,
                style: AppTypography.caption.copyWith(
                  color: isSelected
                      ? colors.labelPrimary
                      : colors.labelSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDefaultTabPicker(AppColors colors, ProfileSettings profile) {
    const tabs = [
      ('discover', 'Discover'),
      ('vault', 'Vault'),
      ('pipeline', 'Pipeline'),
      ('dashboard', 'Dashboard'),
    ];
    final selectedTab = (profile.defaultTab == 'match' || profile.defaultTab == 'arena')
        ? 'discover'
        : (profile.defaultTab == 'tracker' ? 'pipeline' : profile.defaultTab);
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<String>(
        showSelectedIcon: false,
        style: SegmentedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          textStyle: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
        ),
        segments: tabs.map((t) {
          return ButtonSegment<String>(
            value: t.$1,
            label: Text(t.$2),
          );
        }).toList(),
        selected: {selectedTab},
        onSelectionChanged: (newSelection) {
          AppMotion.selectionHaptic();
          ref
              .read(appControllerProvider.notifier)
              .updateProfile(profile.copyWith(defaultTab: newSelection.first));
        },
      ),
    );
  }

  Widget _buildExperiencePicker(AppColors colors, ProfileSettings profile) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<ExperienceLevel>(
        showSelectedIcon: false,
        style: SegmentedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          textStyle: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
        ),
        segments: ExperienceLevel.values.map((lvl) {
          return ButtonSegment<ExperienceLevel>(
            value: lvl,
            label: Text(lvl.label),
          );
        }).toList(),
        selected: {profile.experienceLevel},
        onSelectionChanged: (newSelection) {
          AppMotion.selectionHaptic();
          ref
              .read(appControllerProvider.notifier)
              .updateProfile(profile.copyWith(experienceLevel: newSelection.first));
        },
      ),
    );
  }

  Widget _buildThemePicker(AppColors colors, ProfileSettings profile) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<AppTheme>(
        showSelectedIcon: false,
        style: SegmentedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          textStyle: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
        ),
        segments: const [
          ButtonSegment<AppTheme>(
            value: AppTheme.system,
            label: Text('System'),
          ),
          ButtonSegment<AppTheme>(
            value: AppTheme.light,
            label: Text('Light'),
          ),
          ButtonSegment<AppTheme>(
            value: AppTheme.dark,
            label: Text('Dark'),
          ),
        ],
        selected: {profile.theme},
        onSelectionChanged: (newSelection) {
          AppMotion.selectionHaptic();
          ref
              .read(appControllerProvider.notifier)
              .updateProfile(profile.copyWith(theme: newSelection.first));
        },
      ),
    );
  }

  Widget _buildLanguagePicker(AppColors colors, ProfileSettings profile) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<String>(
        showSelectedIcon: false,
        style: SegmentedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          textStyle: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
        ),
        segments: const [
          ButtonSegment<String>(
            value: 'English',
            label: Text('English'),
          ),
          ButtonSegment<String>(
            value: 'Taglish',
            label: Text('Taglish'),
          ),
        ],
        selected: {profile.interviewLanguage},
        onSelectionChanged: (newSelection) {
          AppMotion.selectionHaptic();
          ref
              .read(appControllerProvider.notifier)
              .updateProfile(
                profile.copyWith(interviewLanguage: newSelection.first),
              );
        },
      ),
    );
  }

  Widget _buildSkillsEditor(AppColors colors, ProfileSettings profile) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final skill in profile.primarySkills)
          InputChip(
            label: Text(skill),
            deleteIcon: const Icon(Icons.close, size: 14),
            onDeleted: () {
              AppMotion.selectionHaptic();
              final updated = List<String>.from(profile.primarySkills)
                ..remove(skill);
              ref
                  .read(appControllerProvider.notifier)
                  .updateProfile(profile.copyWith(primarySkills: updated));
            },
          ),
        ActionChip(
          avatar: Icon(Icons.add, size: 16, color: colors.accent),
          label: Text('Add skill', style: TextStyle(color: colors.accent)),
          onPressed: _addSkillDialog,
        ),
      ],
    );
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
            // User Header Card
            AdaptiveCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UserAvatar(
                        avatarUrl: profile.avatarUrl,
                        initial: profile.initialLetter,
                        size: 64,
                        showEditBadge: true,
                        onTap: _pickProfileImage,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    profile.displayName,
                                    style: AppTypography.title2.copyWith(
                                      color: colors.labelPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 18,
                                  ),
                                  color: colors.labelSecondary,
                                  tooltip: 'Edit name',
                                  onPressed: _editNameDialog,
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: _editHeadlineDialog,
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Text(
                                  profile.headline.isNotEmpty
                                      ? profile.headline
                                      : '+ Add professional title',
                                  style: AppTypography.footnote.copyWith(
                                    color: profile.headline.isNotEmpty
                                        ? colors.accent
                                        : colors.labelTertiary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              profile.email.isNotEmpty
                                  ? profile.email
                                  : 'Local Workspace',
                              style: AppTypography.caption.copyWith(
                                color: colors.labelSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (profile.bio.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.paleIndigoSurface,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              profile.bio,
                              style: AppTypography.body.copyWith(
                                color: colors.labelPrimary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: _editBioDialog,
                            child: Icon(
                              Icons.edit_outlined,
                              size: 16,
                              color: colors.labelSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 14,
                    runSpacing: 6,
                    children: [
                      GestureDetector(
                        onTap: _pickProfileImage,
                        child: Text(
                          profile.avatarUrl.isNotEmpty
                              ? 'Change photo'
                              : 'Upload photo',
                          style: AppTypography.caption.copyWith(
                            color: colors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (profile.avatarUrl.isNotEmpty)
                        GestureDetector(
                          onTap: _removeProfilePhoto,
                          child: Text(
                            'Remove photo',
                            style: AppTypography.caption.copyWith(
                              color: colors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (profile.bio.isEmpty)
                        GestureDetector(
                          onTap: _editBioDialog,
                          child: Text(
                            '+ Add bio',
                            style: AppTypography.caption.copyWith(
                              color: colors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            if (AppConfig.configured &&
                (ref.watch(authRepositoryProvider).user?.isAnonymous ??
                    false)) ...[
              AdaptiveCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colors.paleIndigoSurface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.cloud_upload_outlined,
                        color: colors.accent,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "You're using a guest account.",
                            style: AppTypography.subheadline.copyWith(
                              color: colors.labelPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Link Google to back up your applications and matches.',
                            style: AppTypography.caption.copyWith(
                              color: colors.labelSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    AdaptiveButton.secondary(
                      onPressed: () async {
                        try {
                          final success = await ref
                              .read(authRepositoryProvider)
                              .linkGoogleAccount();
                          if (context.mounted && !success) {
                            showGlassToast(context, 'Account linking canceled');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            showGlassToast(
                              context,
                              'Account linking error: $e',
                            );
                          }
                        }
                      },
                      label: 'Link Google',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Professional Profile Section
            Text(
              'Professional Profile',
              style: AppTypography.headline.copyWith(
                color: colors.labelPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            AdaptiveCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Experience Level
                  Text(
                    'Seniority & Experience',
                    style: AppTypography.subheadline.copyWith(
                      color: colors.labelPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _buildExperiencePicker(colors, profile),
                  const SizedBox(height: AppSpacing.md),

                  // Target Salary
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Desired Monthly Salary',
                              style: AppTypography.subheadline.copyWith(
                                color: colors.labelPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              profile.expectedSalary != null
                                  ? 'PHP ${profile.expectedSalary} / month'
                                  : 'Not specified',
                              style: AppTypography.caption.copyWith(
                                color: colors.accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      AdaptiveButton.secondary(
                        onPressed: _editSalaryDialog,
                        label: 'Edit',
                        icon: const Icon(Icons.payments_outlined, size: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Core Skills
                  Text(
                    'Core Skills & Tech Stack',
                    style: AppTypography.subheadline.copyWith(
                      color: colors.labelPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _buildSkillsEditor(colors, profile),
                  const SizedBox(height: AppSpacing.md),

                  // Career Preferences Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Target Roles & Feed',
                              style: AppTypography.subheadline.copyWith(
                                color: colors.labelPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${profile.location.isNotEmpty ? profile.location : "Philippines"} · ${profile.preferredWorkMode != null ? profile.preferredWorkMode!.label : "Any Work Mode"}',
                              style: AppTypography.caption.copyWith(
                                color: colors.labelSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AdaptiveButton.secondary(
                        onPressed: () => context.push('/preferences'),
                        label: 'Edit Goals',
                        icon: const Icon(Icons.tune_rounded, size: 16),
                      ),
                    ],
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
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
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
                            color: colors.accent,
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
                        'Upgrade plans are currently unavailable',
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
              'Appearance & Theme',
              style: AppTypography.headline.copyWith(
                color: colors.labelPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            AdaptiveCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme Mode',
                    style: AppTypography.subheadline.copyWith(
                      color: colors.labelPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _buildThemePicker(colors, profile),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Signature Accent Tint',
                    style: AppTypography.subheadline.copyWith(
                      color: colors.labelPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _buildAccentPicker(colors, profile),
                  const SizedBox(height: AppSpacing.md),
                  Row(
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
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // System & Controls Section
            Text(
              'System & Experience',
              style: AppTypography.headline.copyWith(
                color: colors.labelPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            AdaptiveCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Haptic feedback toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Haptic feedback',
                              style: AppTypography.body.copyWith(
                                color: colors.labelPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Tactile vibration on buttons and card actions',
                              style: AppTypography.caption.copyWith(
                                color: colors.labelSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AdaptiveSwitch(
                        value: profile.hapticFeedback,
                        onChanged: (val) {
                          AppMotion.hapticsEnabled = val;
                          ref
                              .read(appControllerProvider.notifier)
                              .updateProfile(
                                profile.copyWith(hapticFeedback: val),
                              );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Default Start Screen
                  Text(
                    'Default Start Screen',
                    style: AppTypography.subheadline.copyWith(
                      color: colors.labelPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _buildDefaultTabPicker(colors, profile),
                  const SizedBox(height: AppSpacing.md),

                  // Interview Language
                  Text(
                    'Interview Practice Language',
                    style: AppTypography.subheadline.copyWith(
                      color: colors.labelPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _buildLanguagePicker(colors, profile),
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
              child: Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.sm,
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
                        AppConfig.configured && ref.watch(authRepositoryProvider).authenticated
                            ? 'Cloud-synced & on this device'
                            : 'On this device',
                        style: AppTypography.caption.copyWith(
                          color: colors.labelSecondary,
                        ),
                      ),
                    ],
                  ),
                  AdaptiveButton.secondary(
                    onPressed: _syncing
                        ? null
                        : () async {
                            setState(() => _syncing = true);
                            AppMotion.selectionHaptic();
                            try {
                              final success = await ref
                                  .read(appControllerProvider.notifier)
                                  .syncNow();
                              if (!context.mounted) return;
                              if (success) {
                                showGlassToast(
                                  context,
                                  'Cloud sync completed successfully',
                                  icon: Icons.cloud_done_rounded,
                                );
                              } else {
                                final authRepo = ref.read(authRepositoryProvider);
                                if (!AppConfig.configured) {
                                  showGlassToast(
                                    context,
                                    'Cloud sync is not configured on this build',
                                    icon: Icons.cloud_off_rounded,
                                  );
                                } else if (!authRepo.authenticated) {
                                  showGlassToast(
                                    context,
                                    'Sign in to sync your data across devices',
                                    icon: Icons.person_outline_rounded,
                                  );
                                } else {
                                  showGlassToast(
                                    context,
                                    'Cloud sync failed. Please check connection.',
                                    icon: Icons.sync_problem_rounded,
                                  );
                                }
                              }
                            } finally {
                              if (mounted) setState(() => _syncing = false);
                            }
                          },
                    label: _syncing ? 'Syncing…' : 'Sync now',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

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
                        Expanded(
                          child: Text(
                            'Privacy policy',
                            style: AppTypography.headline.copyWith(
                              color: colors.labelPrimary,
                              fontWeight: FontWeight.w600,
                            ),
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
                      'Compliant with the Philippine Data Privacy Act of 2012 (RA 10173). Resume parsing and ATS checks execute locally on your device. Resume text is never logged or stored remotely without explicit consent. You maintain full ownership, retention controls, and immediate deletion rights for stored records.',
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
                        Expanded(
                          child: Text(
                            'Terms of service',
                            style: AppTypography.headline.copyWith(
                              color: colors.labelPrimary,
                              fontWeight: FontWeight.w600,
                            ),
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
                      'Listings and comparison content are examples until live services are available. Applications are tracked on this device; they are not submitted to employers.',
                      style: AppTypography.footnote.copyWith(
                        color: colors.labelSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            if (state.authenticated) ...[
              AdaptiveButton.secondary(
                isFullWidth: true,
                onPressed: () async {
                  await ref.read(appControllerProvider.notifier).signOut();
                  if (context.mounted) {
                    showGlassToast(context, 'Signed out');
                    context.go('/sign-in');
                  }
                },
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: 'Sign out',
              ),
              const SizedBox(height: AppSpacing.md),
            ] else ...[
              AdaptiveButton.primary(
                isFullWidth: true,
                onPressed: () => context.go('/sign-in'),
                icon: const Icon(Icons.login_rounded, size: 18),
                label: 'Sign in to account',
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Delete Account and Data button
            AdaptiveButton.destructive(
              isFullWidth: true,
              onPressed: _confirmDeleteAccount,
              label: 'Reset workspace',
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
      appBar: const PushedHeader(title: 'Shared job'),
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
                            color: colors.accent,
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
