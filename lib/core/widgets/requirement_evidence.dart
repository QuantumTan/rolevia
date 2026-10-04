import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/matching_models.dart';
import '../design/colors.dart';
import '../design/radius.dart';
import '../design/spacing.dart';
import '../design/typography.dart';
import 'adaptive_button.dart';
import 'adaptive_card.dart';
import 'adaptive_sheet.dart';
import 'adaptive_toast.dart';
import 'pressable.dart';

/// Semantic chips displaying requirement match verdicts with high contrast
class EvidenceVerdictChip extends StatelessWidget {
  const EvidenceVerdictChip({
    super.key,
    required this.verdict,
    this.compact = false,
  });

  final EvidenceVerdict verdict;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final (Color bg, Color fg, IconData icon) = switch (verdict) {
      EvidenceVerdict.strong => (
        isDark ? const Color(0x332E7D32) : const Color(0x1F2E7D32),
        colors.success,
        Icons.check_circle_rounded,
      ),
      EvidenceVerdict.partial => (
        isDark ? const Color(0x331976D2) : const Color(0x1F1976D2),
        colors.info,
        Icons.timelapse_rounded,
      ),
      EvidenceVerdict.transferable => (
        isDark ? const Color(0x335C6BC0) : const Color(0x1F5C6BC0),
        colors.secondary,
        Icons.swap_horiz_rounded,
      ),
      EvidenceVerdict.mentionOnly => (
        isDark ? const Color(0x338A5C13) : const Color(0x1F8A5C13),
        colors.warning,
        Icons.label_outline_rounded,
      ),
      EvidenceVerdict.missing => (
        isDark ? const Color(0x33C62828) : const Color(0x1FC62828),
        colors.error,
        Icons.close_rounded,
      ),
    };

    return Container(
      constraints: BoxConstraints(minHeight: compact ? 26 : 30),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.capsule),
        border: Border.all(color: fg.withValues(alpha: 0.35), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: compact ? 13 : 15, color: fg),
          const SizedBox(width: 4),
          Text(
            verdict.label,
            style: AppTypography.caption.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 11 : 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Single requirement row presenting verdict and evidence link
class RequirementEvidenceRow extends StatelessWidget {
  const RequirementEvidenceRow({
    super.key,
    required this.match,
    required this.onTap,
  });

  final RequirementEvidenceMatch match;
  final VoidCallback onTap;

  String _categoryTitle(RequirementCategory cat) => switch (cat) {
    RequirementCategory.hardSkill => 'Hard skill',
    RequirementCategory.tool => 'Tool',
    RequirementCategory.responsibility => 'Responsibility',
    RequirementCategory.domainKnowledge => 'Domain knowledge',
    RequirementCategory.softSkill => 'Soft skill',
    RequirementCategory.education => 'Education',
    RequirementCategory.certification => 'Certification',
    RequirementCategory.language => 'Language',
    RequirementCategory.yearsExperience => 'Experience',
    RequirementCategory.locationSchedule => 'Location / schedule',
  };

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final req = match.requirement;
    final hasEvidence =
        match.evidence != null && match.evidence!.quote.trim().isNotEmpty;

    return Semantics(
      button: true,
      label: '${req.text}, verdict ${match.verdict.label}',
      child: PressableScale(
        onPressed: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      req.text,
                      style: AppTypography.body.copyWith(
                        color: colors.labelPrimary,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Text(
                          _categoryTitle(req.category),
                          style: AppTypography.caption.copyWith(
                            color: colors.labelSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (req.minimumYears != null) ...[
                          Text(
                            '·',
                            style: AppTypography.caption.copyWith(
                              color: colors.labelTertiary,
                            ),
                          ),
                          Text(
                            '${req.minimumYears!.toStringAsFixed(0)}+ yrs required',
                            style: AppTypography.caption.copyWith(
                              color: colors.labelSecondary,
                            ),
                          ),
                        ],
                        if (hasEvidence) ...[
                          Text(
                            '·',
                            style: AppTypography.caption.copyWith(
                              color: colors.labelTertiary,
                            ),
                          ),
                          Text(
                            'Resume evidence: ${match.evidence!.section}',
                            style: AppTypography.caption.copyWith(
                              color: colors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              EvidenceVerdictChip(verdict: match.verdict, compact: true),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: colors.labelTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Detailed bottom sheet showing exact resume quotes, reason, and truthful suggestions
class RequirementEvidenceSheetContent extends StatelessWidget {
  const RequirementEvidenceSheetContent({super.key, required this.match});

  final RequirementEvidenceMatch match;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final req = match.requirement;
    final evidence = match.evidence;
    final hasQuote = evidence != null && evidence.quote.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Requirement Title
          Text(
            req.text,
            style: AppTypography.title3.copyWith(
              color: colors.labelPrimary,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Badges row: verdict + confidence + priority
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              EvidenceVerdictChip(verdict: match.verdict),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: colors.secondaryBackground,
                  borderRadius: BorderRadius.circular(AppRadius.capsule),
                  border: Border.all(
                    color: colors.separator.withValues(alpha: 0.5),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  match.confidence.label,
                  style: AppTypography.caption.copyWith(
                    color: colors.labelSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: colors.secondaryBackground,
                  borderRadius: BorderRadius.circular(AppRadius.capsule),
                  border: Border.all(
                    color: colors.separator.withValues(alpha: 0.5),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  req.priority.label,
                  style: AppTypography.caption.copyWith(
                    color: colors.labelSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Section 1: Exact Resume Evidence Quote
          Text(
            'Resume evidence',
            style: AppTypography.headline.copyWith(
              color: colors.labelPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          AdaptiveCard(
            padding: const EdgeInsets.all(16),
            child: hasQuote
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.format_quote_rounded,
                            size: 20,
                            color: colors.accent,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '"${evidence.quote.trim()}"',
                              style: AppTypography.body.copyWith(
                                color: colors.labelPrimary,
                                fontStyle: FontStyle.italic,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colors.secondaryBackground,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Found in section: ${evidence.section}',
                              style: AppTypography.caption.copyWith(
                                color: colors.labelSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (evidence.role.trim().isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Role: ${evidence.role}',
                                style: AppTypography.caption.copyWith(
                                  color: colors.labelSecondary,
                                ),
                              ),
                            ],
                            if (evidence.recencyYears != null ||
                                evidence.durationYears != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                [
                                  if (evidence.recencyYears != null)
                                    'Recency: ${evidence.recencyYears!.toStringAsFixed(1)} yrs ago',
                                  if (evidence.durationYears != null)
                                    'Duration: ${evidence.durationYears!.toStringAsFixed(1)} yrs',
                                ].join(' · '),
                                style: AppTypography.caption.copyWith(
                                  color: colors.labelSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 20,
                        color: colors.labelSecondary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'No direct evidence quote was found in your resume for this requirement.',
                          style: AppTypography.body.copyWith(
                            color: colors.labelSecondary,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Section 2: Why this verdict
          Text(
            'Verdict explanation',
            style: AppTypography.headline.copyWith(
              color: colors.labelPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          AdaptiveCard(
            padding: const EdgeInsets.all(16),
            child: Text(
              match.reason.trim().isNotEmpty
                  ? match.reason
                  : switch (match.verdict) {
                      EvidenceVerdict.strong => 'Resume demonstrates direct experience with verified outcomes for this requirement.',
                      EvidenceVerdict.partial => 'Resume demonstrates relevant skills or partial responsibilities without full coverage.',
                      EvidenceVerdict.transferable => 'Resume demonstrates related competencies that transfer to this requirement.',
                      EvidenceVerdict.mentionOnly => 'Keyword appears in your resume without verified context or demonstrated impact.',
                      EvidenceVerdict.missing => 'Requirement was not identified in the parsed resume text.',
                    },
              style: AppTypography.body.copyWith(
                color: colors.labelPrimary,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Section 3: Truthful suggestion
          Text(
            'Actionable suggestion',
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
              children: [
                Text(
                  match.suggestion.trim().isNotEmpty
                      ? match.suggestion
                      : 'Review your past roles and projects. If you have genuine experience with ${req.text}, describe the outcome truthfully.',
                  style: AppTypography.body.copyWith(
                    color: colors.labelPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colors.secondaryBackground,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 16,
                        color: colors.labelSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Don’t add skills you don’t have. Only include genuine experience with verified outcomes.',
                          style: AppTypography.caption.copyWith(
                            color: colors.labelSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (match.suggestion.trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  AdaptiveButton.secondary(
                    isFullWidth: true,
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: match.suggestion),
                      );
                      if (context.mounted) {
                        showGlassToast(
                          context,
                          'Suggestion copied to clipboard',
                          icon: Icons.check_circle_rounded,
                        );
                      }
                    },
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: 'Copy suggestion',
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

/// Helper opening the evidence bottom sheet using Rolevia adaptive design system
Future<void> showRequirementEvidenceSheet(
  BuildContext context,
  RequirementEvidenceMatch match,
) {
  return showAdaptiveSheet<void>(
    context: context,
    title: 'Requirement Evidence',
    builder: (sheetContext) => RequirementEvidenceSheetContent(match: match),
  );
}

/// Groups requirements into Must-have and Nice-to-have sections
class RequirementEvidenceList extends StatelessWidget {
  const RequirementEvidenceList({
    super.key,
    required this.requirements,
    this.onRequirementTap,
  });

  final List<RequirementEvidenceMatch> requirements;
  final void Function(RequirementEvidenceMatch match)? onRequirementTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final mustHaves = requirements
        .where((m) => m.requirement.priority == RequirementPriority.mustHave)
        .toList();
    final niceToHaves = requirements
        .where((m) => m.requirement.priority == RequirementPriority.niceToHave)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (mustHaves.isNotEmpty) ...[
          Text(
            'Must-have requirements (${mustHaves.length})',
            style: AppTypography.headline.copyWith(
              color: colors.labelPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Core qualifications required for the role',
            style: AppTypography.caption.copyWith(color: colors.labelSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final match in mustHaves) ...[
            RequirementEvidenceRow(
              match: match,
              onTap: () {
                if (onRequirementTap != null) {
                  onRequirementTap!(match);
                } else {
                  showRequirementEvidenceSheet(context, match);
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ],
        if (niceToHaves.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            'Nice-to-have requirements (${niceToHaves.length})',
            style: AppTypography.headline.copyWith(
              color: colors.labelPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Preferred skills and bonus competencies',
            style: AppTypography.caption.copyWith(color: colors.labelSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final match in niceToHaves) ...[
            RequirementEvidenceRow(
              match: match,
              onTap: () {
                if (onRequirementTap != null) {
                  onRequirementTap!(match);
                } else {
                  showRequirementEvidenceSheet(context, match);
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ],
      ],
    );
  }
}
