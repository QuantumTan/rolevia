import 'package:flutter/material.dart';

import '../design/colors.dart';
import '../design/radius.dart';
import '../design/spacing.dart';
import '../design/typography.dart';
import '../services/job_text_cleaner.dart';
import 'adaptive_card.dart';
import 'adaptive_sheet.dart';

class JobDescriptionView extends StatefulWidget {
  const JobDescriptionView({
    super.key,
    required this.result,
    this.forceTruncated = false,
    this.showStatus = true,
  });

  final JobTextCleanResult result;
  final bool forceTruncated;
  final bool showStatus;

  @override
  State<JobDescriptionView> createState() => _JobDescriptionViewState();
}

class _JobDescriptionViewState extends State<JobDescriptionView> {
  bool _expanded = false;

  bool get _canCollapse => widget.result.estimatedLines > 8;

  void _showOriginal() {
    showAdaptiveSheet<void>(
      context: context,
      title: 'Original job text',
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: SelectableText(
          widget.result.original.trim(),
          style: AppTypography.body.copyWith(
            color: AppColors.of(sheetContext).labelPrimary,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final truncated = widget.forceTruncated || widget.result.isLikelyTruncated;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (truncated) ...[
          Semantics(
            liveRegion: true,
            child: Container(
              key: const Key('job-text-truncation-warning'),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(
                  color: colors.warning.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, color: colors.warning),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'This looks cut off. Paste the full job description for a more accurate result.',
                      style: AppTypography.footnote.copyWith(
                        color: colors.labelPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        AdaptiveCard(
          padding: const EdgeInsets.all(16),
          child: AnimatedSize(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 180),
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!_expanded && _canCollapse)
                  Text(
                    widget.result.cleaned,
                    key: const Key('job-description-collapsed'),
                    maxLines: 8,
                    overflow: TextOverflow.fade,
                    style: AppTypography.body.copyWith(
                      color: colors.labelPrimary,
                      height: 1.5,
                    ),
                  )
                else
                  _SectionedJobText(result: widget.result),
                if (_canCollapse) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      key: const Key('job-description-toggle'),
                      onPressed: () => setState(() => _expanded = !_expanded),
                      style: TextButton.styleFrom(
                        foregroundColor: colors.accent,
                        minimumSize: const Size(44, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                      child: Text(_expanded ? 'Show less' : 'Show more'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (widget.showStatus) ...[
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Full text used · ${widget.result.characters} characters',
                style: AppTypography.caption.copyWith(
                  color: colors.labelSecondary,
                ),
              ),
              if (widget.result.changed)
                TextButton(
                  key: const Key('view-original-job-text'),
                  onPressed: _showOriginal,
                  style: TextButton.styleFrom(
                    foregroundColor: colors.accent,
                    minimumSize: const Size(44, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  child: const Text('View original'),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SectionedJobText extends StatelessWidget {
  const _SectionedJobText({required this.result});

  final JobTextCleanResult result;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    if (result.sections.isEmpty) {
      return Text(
        result.cleaned,
        key: const Key('job-description-expanded'),
        style: AppTypography.body.copyWith(
          color: colors.labelPrimary,
          height: 1.5,
        ),
      );
    }

    return Column(
      key: const Key('job-description-expanded'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < result.sections.length; index++) ...[
          if (index > 0) const SizedBox(height: AppSpacing.md),
          Text(
            result.sections[index].heading,
            style: AppTypography.headline.copyWith(
              color: colors.labelPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            result.sections[index].body,
            style: AppTypography.body.copyWith(
              color: colors.labelPrimary,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}
