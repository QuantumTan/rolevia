import 'package:flutter/material.dart';

import '../core/design/colors.dart';
import '../core/design/radius.dart';
import '../core/design/spacing.dart';
import '../core/design/typography.dart';
import '../core/services/pdf_extractor_service.dart';
import '../core/services/resume_text_parser.dart';
import '../core/widgets/adaptive_button.dart';
import '../core/widgets/adaptive_card.dart';

class ResumeParsePreviewScreen extends StatefulWidget {
  const ResumeParsePreviewScreen({
    super.key,
    required this.fileName,
    required this.extracted,
  });

  final String fileName;
  final ExtractedResume extracted;

  @override
  State<ResumeParsePreviewScreen> createState() =>
      _ResumeParsePreviewScreenState();
}

class _EditableResumeSection {
  _EditableResumeSection({required this.title, required String content})
    : controller = TextEditingController(text: content);

  final String title;
  final TextEditingController controller;

  void dispose() => controller.dispose();
}

class _ResumeParsePreviewScreenState extends State<ResumeParsePreviewScreen> {
  late final List<_EditableResumeSection> _sections;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _sections = [
      for (final section in widget.extracted.parse.sections)
        _EditableResumeSection(title: section.title, content: section.content),
    ];
    if (_sections.isEmpty) {
      _sections.add(
        _EditableResumeSection(
          title: 'Resume text',
          content: widget.extracted.sanitizedText,
        ),
      );
    }
  }

  @override
  void dispose() {
    for (final section in _sections) {
      section.dispose();
    }
    super.dispose();
  }

  void _confirm() {
    final text = ResumeTextParser.fromSections([
      for (final section in _sections)
        ResumeParsedSection(
          title: section.title,
          content: section.controller.text,
        ),
    ]);
    if (text.length < 80) {
      setState(() {
        _validationError = 'Add at least 80 characters of readable resume content before continuing.';
      });
      return;
    }
    Navigator.of(context).pop(widget.extracted.reviewed(text));
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final quality = widget.extracted.parse.quality;
    final qualityLabel = switch (quality) {
      ResumeParseQuality.high => 'High confidence',
      ResumeParseQuality.medium => 'Review suggested',
      ResumeParseQuality.low => 'Needs review',
    };
    final qualityColor = switch (quality) {
      ResumeParseQuality.high => colors.success,
      ResumeParseQuality.medium => colors.warning,
      ResumeParseQuality.low => colors.error,
    };

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colors.labelPrimary,
        title: const Text('Review resume text'),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.xl,
                ),
                children: [
                  Text(
                    'What we read from your resume',
                    style: AppTypography.title2.copyWith(
                      color: colors.labelPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Check each section before matching. Fix missing words, reading order, or dates here.',
                    style: AppTypography.body.copyWith(
                      color: colors.labelSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AdaptiveCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: qualityColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.extracted.usedOcr
                                ? Icons.document_scanner_outlined
                                : Icons.text_snippet_outlined,
                            color: qualityColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                qualityLabel,
                                style: AppTypography.headline.copyWith(
                                  color: colors.labelPrimary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                widget.extracted.usedOcr
                                    ? 'Read on this device with OCR from ${widget.fileName}'
                                    : 'Read from the text layer in ${widget.fileName}',
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
                  if (widget.extracted.parse.warnings.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    AdaptiveCard(
                      color: colors.warning.withValues(alpha: 0.09),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Check these items',
                            style: AppTypography.headline.copyWith(
                              color: colors.labelPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          for (final warning in widget.extracted.parse.warnings)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.xs,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    size: 18,
                                    color: colors.warning,
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Expanded(
                                    child: Text(
                                      warning,
                                      style: AppTypography.footnote.copyWith(
                                        color: colors.labelSecondary,
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
                  const SizedBox(height: AppSpacing.lg),
                  for (final section in _sections) ...[
                    Text(
                      section.title.toUpperCase(),
                      style: AppTypography.caption.copyWith(
                        color: colors.labelSecondary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.7,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: section.controller,
                      minLines: 3,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      style: AppTypography.body.copyWith(
                        color: colors.labelPrimary,
                        height: 1.4,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: colors.surface,
                        hintText: 'Add ${section.title.toLowerCase()} details',
                        hintStyle: AppTypography.body.copyWith(
                          color: colors.labelTertiary,
                        ),
                        contentPadding: const EdgeInsets.all(AppSpacing.md),
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.cardRadius,
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppRadius.cardRadius,
                          borderSide: BorderSide(color: colors.separator),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppRadius.cardRadius,
                          borderSide: BorderSide(
                            color: colors.accent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  if (_validationError != null)
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        _validationError!,
                        style: AppTypography.footnote.copyWith(
                          color: colors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              decoration: BoxDecoration(
                color: colors.background,
                border: Border(top: BorderSide(color: colors.separator)),
              ),
              child: AdaptiveButton.primary(
                label: 'Use this text',
                isFullWidth: true,
                onPressed: _confirm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
