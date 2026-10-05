import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../core/services/pdf_extractor_service.dart';

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
import '../core/widgets/adaptive_text_field.dart';
import '../core/widgets/adaptive_toast.dart';
import '../core/widgets/app_top_bar.dart';
import '../core/widgets/pressable.dart';
import '../core/widgets/dashed_frame.dart';
import '../core/widgets/resume_actions.dart';
import '../models/models.dart';
import '../shared/widgets.dart';
import '../state/app_state.dart';
import 'resume_parse_preview_screen.dart';

class VaultScreen extends ConsumerStatefulWidget {
  const VaultScreen({super.key, this.initialTab = 0});
  final int initialTab;

  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends ConsumerState<VaultScreen>
    with AutomaticKeepAliveClientMixin {
  bool _checkingPdf = false;
  String? _error;

  @override
  bool get wantKeepAlive => true;

  void _showManualPasteSheet() {
    final textController = TextEditingController();
    final titleController = TextEditingController(
      text:
          'IT_Frontend_v${ref.read(appControllerProvider).resumes.length + 1}',
    );

    showAdaptiveSheet(
      context: context,
      title: 'Paste Resume Manually',
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdaptiveTextField(
              controller: titleController,
              hintText: 'Resume title (e.g. IT_Frontend_v2)',
            ),
            const SizedBox(height: 12),
            AdaptiveTextField(
              controller: textController,
              hintText: 'Paste full resume text here...',
              maxLines: 6,
            ),
            const SizedBox(height: 16),
            AdaptiveButton.primary(
              label: 'Save to Vault',
              onPressed: () {
                final text = textController.text.trim();
                if (text.isEmpty) {
                  showGlassToast(context, 'Please paste some resume text');
                  return;
                }
                final newResume = ResumeVersion(
                  id: const Uuid().v4(),
                  title: titleController.text.trim().isNotEmpty
                      ? titleController.text.trim()
                      : 'Manual_Resume',
                  filename: 'manual_entry.txt',
                  fileType: 'TXT',
                  addedAt: DateTime.now(),
                  isSample: false,
                  atsStatus: 'ATS OK',
                  extractedText: text,
                  atsChecks: const {
                    'single_column': true,
                    'standard_fonts': true,
                  },
                );
                ref.read(appControllerProvider.notifier).addResume(newResume);
                Navigator.pop(sheetContext);
                showGlassToast(context, 'Resume saved to Vault');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameResumeSheet(ResumeVersion resume) {
    AppMotion.selectionHaptic();
    final controller = TextEditingController(text: resume.title);

    showAdaptiveSheet(
      context: context,
      title: 'Rename resume',
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdaptiveTextField(controller: controller, hintText: 'Resume title'),
            const SizedBox(height: 16),
            AdaptiveButton.primary(
              label: 'Save',
              onPressed: () {
                final newTitle = controller.text.trim();
                if (newTitle.isNotEmpty) {
                  ref
                      .read(appControllerProvider.notifier)
                      .updateResume(resume.copyWith(title: newTitle));
                  Navigator.pop(sheetContext);
                  showGlassToast(context, 'Resume renamed');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPrivacyConsentDialog() async {
    final confirmed = await showAdaptiveConfirmDialog(
      context,
      title: 'Cloud sync of parsed text',
      message: 'Raw PDFs stay on device. Parsed text syncs only after your explicit consent under RA 10173 so you can analyze matches across devices.\n\nResume text is never used to train public AI models.',
      confirmLabel: 'Consent to sync',
      cancelLabel: 'Keep local only',
    );
    if (confirmed && mounted) {
      showGlassToast(context, 'Sync consent saved');
    }
  }

  Widget _buildResumeCarousel(List<ResumeVersion> resumes, String? selectedId) {
    final colors = AppColors.of(context);
    final textScaler = MediaQuery.textScalerOf(context);
    final cardHeight = textScaler.scale(120.0).clamp(120.0, 220.0);
    final cardWidth = textScaler.scale(220.0).clamp(220.0, 320.0);

    return SizedBox(
      height: cardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: resumes.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final resume = resumes[index];
          final isActive = resume.id == selectedId;
          return PressableScale(
            onPressed: () {
              AppMotion.selectionHaptic();
              ref
                  .read(appControllerProvider.notifier)
                  .setDefaultResume(resume.id);
              _showResumeViewerSheet(resume);
            },
            child: Container(
              width: cardWidth,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isActive ? colors.surface : colors.background,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: isActive ? colors.primary : colors.borderSubtle,
                  width: isActive ? 1.8 : 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? colors.primary
                                : colors.paleIndigoSurface,
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                          ),
                          child: Text(
                            isActive ? 'ACTIVE' : 'STANDBY',
                            style: AppTypography.monoBadge.copyWith(
                              color: isActive
                                  ? Colors.white
                                  : colors.labelSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        shortDate(resume.addedAt),
                        style: AppTypography.caption.copyWith(
                          color: colors.labelTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      resume.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headline.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.labelPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.text_snippet_outlined,
                        size: 13,
                        color: colors.labelSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${resume.extractedText.length} chars · ${resume.fileType}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: colors.labelSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAtsHealthCard(ResumeVersion activeResume) {
    final colors = AppColors.of(context);
    final isMultiColumn = activeResume.atsChecks['single_column'] == false;
    final isLowDensity = activeResume.extractedText.trim().length < 250;
    final charCount = activeResume.extractedText.length;
    final hasContactInfo =
        RegExp(r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}')
            .hasMatch(activeResume.extractedText) ||
        RegExp(r'(?:\+?63|0)9\d{9}').hasMatch(activeResume.extractedText);
    final commonSections = [
      'experience',
      'education',
      'skills',
      'summary',
      'projects',
      'certifications',
      'objective',
    ];
    final sectionCount = commonSections
        .where((s) => activeResume.extractedText.toLowerCase().contains(s))
        .length;
    final hasStandardDates =
        RegExp(r'\b(?:19|20)\d{2}\b').hasMatch(activeResume.extractedText) ||
        RegExp(
          r'\b(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+\d{4}\b',
          caseSensitive: false,
        ).hasMatch(activeResume.extractedText);

    final hasWarning =
        isMultiColumn ||
        isLowDensity ||
        charCount > 25000 ||
        !hasContactInfo ||
        sectionCount < 2;

    final checks = [
      (
        'Layout columns',
        isMultiColumn
            ? Icons.warning_amber_rounded
            : Icons.check_circle_outline_rounded,
        isMultiColumn ? colors.warning : colors.diffAddedText,
        isMultiColumn ? 'Multi-column' : 'Single column',
      ),
      (
        'Text density',
        isLowDensity
            ? Icons.warning_amber_rounded
            : Icons.check_circle_outline_rounded,
        isLowDensity ? colors.warning : colors.diffAddedText,
        isLowDensity ? 'Low density' : 'Optimal',
      ),
      (
        'Payload capacity',
        charCount > 25000
            ? Icons.warning_amber_rounded
            : Icons.check_circle_outline_rounded,
        charCount > 25000 ? colors.warning : colors.diffAddedText,
        '$charCount / 25,000',
      ),
      (
        'Contact info detected',
        hasContactInfo
            ? Icons.check_circle_outline_rounded
            : Icons.warning_amber_rounded,
        hasContactInfo ? colors.diffAddedText : colors.warning,
        hasContactInfo ? 'Detected' : 'Missing contact details',
      ),
      (
        'Section headings found',
        sectionCount >= 2
            ? Icons.check_circle_outline_rounded
            : Icons.warning_amber_rounded,
        sectionCount >= 2 ? colors.diffAddedText : colors.warning,
        '$sectionCount standard sections',
      ),
      (
        'Date formats',
        hasStandardDates
            ? Icons.check_circle_outline_rounded
            : Icons.info_outline_rounded,
        hasStandardDates ? colors.diffAddedText : colors.labelSecondary,
        hasStandardDates ? 'Standard' : 'Unrecognized',
      ),
    ];

    return AdaptiveCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'ATS Structural Health',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.headline.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.labelPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: hasWarning
                      ? colors.warning.withValues(alpha: 0.12)
                      : colors.diffAddedBg,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Text(
                  hasWarning ? 'Warnings' : 'Health OK',
                  style: AppTypography.monoBadge.copyWith(
                    color: hasWarning ? colors.warning : colors.diffAddedText,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Table(
            columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(3)},
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: checks.map((c) {
              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      c.$1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.footnote.copyWith(
                        color: colors.labelSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(c.$2, size: 14, color: c.$3),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            c.$4,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.monoData.copyWith(
                              color: colors.labelPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          if (isLowDensity) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.xs),
                border: Border.all(color: colors.warning, width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: colors.warning,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Low text density: This file may be a scanned image or non-selectable PDF.',
                      style: AppTypography.caption.copyWith(
                        color: colors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          PressableScale(
            onPressed: () => _previewExtractedText(activeResume),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: colors.paleIndigoSurface,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: colors.borderSubtle),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    size: 16,
                    color: colors.accent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'What we read (extracted text preview)',
                      style: AppTypography.footnote.copyWith(
                        color: colors.labelPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: colors.labelTertiary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndValidatePdf() async {
    AppMotion.selectionHaptic();
    setState(() {
      _checkingPdf = true;
      _error = null;
    });

    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );
      if (!mounted) return;

      if (file == null) {
        setState(() => _checkingPdf = false);
        return;
      }

      final size = (await file.length()) ?? file.lengthSync() ?? 0;
      if (!mounted) return;

      if (size > Brand.maxResumeBytes) {
        setState(() {
          _checkingPdf = false;
          _error = 'File exceeds 10 MB limit. Please choose a smaller PDF.';
        });
        return;
      }

      final ext = (file.extension ?? '').toLowerCase();
      if (ext != 'pdf') {
        setState(() {
          _checkingPdf = false;
          _error = 'Only PDF files are supported.';
        });
        return;
      }

      final bytes = await file.readAsBytes();
      final extracted = await PdfExtractorService().extract(bytes);
      if (!mounted) return;
      final reviewed = await Navigator.of(context).push<ExtractedResume>(
        MaterialPageRoute(
          builder: (_) => ResumeParsePreviewScreen(
            fileName: file.name,
            extracted: extracted,
          ),
        ),
      );
      if (!mounted) return;
      if (reviewed == null) {
        setState(() => _checkingPdf = false);
        return;
      }

      final newResume = ResumeVersion(
        id: const Uuid().v4(),
        title: file.name.replaceAll('.pdf', ''),
        filename: file.name,
        fileType: 'PDF',
        addedAt: DateTime.now(),
        isSample: false,
        atsStatus: reviewed.report.status == 'ATS OK'
            ? 'ATS Ready'
            : 'Layout Warnings',
        extractedText: reviewed.sanitizedText,
        atsChecks: reviewed.report.checks,
      );

      ref.read(appControllerProvider.notifier).addResume(newResume);
      setState(() => _checkingPdf = false);
      if (mounted) {
        showGlassToast(context, 'Resume added to Vault');
        _showPrivacyConsentDialog();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _checkingPdf = false;
        _error = 'Could not load file: $e';
      });
    }
  }

  int _detectSkillsCount(ResumeVersion resume) {
    if (resume.skills.isNotEmpty) return resume.skills.length;
    final text = resume.extractedText.toLowerCase();
    if (text.isEmpty) return 0;
    const commonSkills = [
      'flutter',
      'dart',
      'react',
      'javascript',
      'typescript',
      'html',
      'css',
      'sql',
      'sqlite',
      'docker',
      'git',
      'rest',
      'api',
      'python',
      'java',
      'c++',
      'php',
      'node',
      'linux',
      'aws',
      'firebase',
      'supabase',
      'figma',
      'agile',
      'ci/cd',
      'communication',
      'troubleshooting',
      'networking',
    ];
    final count = commonSkills.where((s) => text.contains(s)).length;
    return count > 0
        ? count
        : (text.split(RegExp(r'\s+')).length / 30).round().clamp(1, 15);
  }

  void _previewExtractedText(ResumeVersion resume) {
    AppMotion.selectionHaptic();
    showAdaptiveSheet<void>(
      context: context,
      title: 'Extracted text: ${resume.filename}',
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              constraints: const BoxConstraints(maxHeight: 360),
              child: SingleChildScrollView(
                child: Text(
                  resume.extractedText.trim().isEmpty
                      ? 'No text extracted. Re-import this resume to inspect.'
                      : resume.extractedText,
                  style: AppTypography.body.copyWith(
                    color: AppColors.of(context).labelPrimary,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AdaptiveButton.secondary(
              label: 'Close',
              onPressed: () => Navigator.pop(sheetContext),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportPlainText(ResumeVersion resume) async {
    AppMotion.selectionHaptic();
    await Clipboard.setData(ClipboardData(text: resume.extractedText));
    if (mounted) {
      showGlassToast(context, 'Plain text copied to clipboard');
    }
  }

  List<String> _getDetectedSkills(ResumeVersion resume) {
    if (resume.skills.isNotEmpty) return resume.skills;
    final text = resume.extractedText.toLowerCase();
    if (text.isEmpty) return const [];
    const commonSkills = [
      'Flutter',
      'Dart',
      'React',
      'JavaScript',
      'TypeScript',
      'HTML',
      'CSS',
      'SQL',
      'SQLite',
      'PostgreSQL',
      'Docker',
      'Git',
      'REST APIs',
      'Python',
      'Java',
      'C++',
      'Node.js',
      'Linux',
      'AWS',
      'Firebase',
      'Supabase',
      'Figma',
      'Agile',
      'CI/CD',
      'Communication',
      'Troubleshooting',
      'Networking',
    ];
    return commonSkills.where((s) => text.contains(s.toLowerCase())).toList();
  }

  void _showResumeViewerSheet(ResumeVersion resume) {
    AppMotion.selectionHaptic();
    final state = ref.read(appControllerProvider);
    final selectedId = state.selectedMatchResumeId ?? state.defaultResumeId;
    final isActive = resume.id == selectedId;
    final colors = AppColors.of(context);
    final skills = _getDetectedSkills(resume);
    final charCount = resume.extractedText.length;

    showAdaptiveSheet<void>(
      context: context,
      title: resume.title,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status and Active badges
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color:
                        resume.atsStatus.contains('OK') ||
                            resume.atsStatus.contains('Ready')
                        ? colors.diffAddedBg
                        : colors.diffPrunedBg,
                    borderRadius: BorderRadius.circular(AppRadius.capsule),
                  ),
                  child: Text(
                    resume.atsStatus,
                    style: TextStyle(
                      color:
                          resume.atsStatus.contains('OK') ||
                              resume.atsStatus.contains('Ready')
                          ? colors.diffAddedText
                          : colors.diffPrunedText,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: colors.paleIndigoSurface,
                      borderRadius: BorderRadius.circular(AppRadius.capsule),
                      border: Border.all(
                        color: colors.accent.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      'ACTIVE RESUME',
                      style: AppTypography.monoBadge.copyWith(
                        color: colors.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                const Spacer(),
                Text(
                  '${resume.fileType} · ${shortDate(resume.addedAt)}',
                  style: AppTypography.caption.copyWith(
                    color: colors.labelTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Action Buttons Row
            Row(
              children: [
                if (!isActive) ...[
                  Expanded(
                    child: AdaptiveButton.secondary(
                      label: 'Set as Active',
                      icon: const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 16,
                      ),
                      onPressed: () {
                        ref
                            .read(appControllerProvider.notifier)
                            .setDefaultResume(resume.id);
                        Navigator.pop(sheetContext);
                        AppMotion.selectionHaptic();
                        showGlassToast(
                          context,
                          'Set as active resume: ${resume.title}',
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: AdaptiveButton.primary(
                    label: 'Analyze',
                    icon: const Icon(Icons.bolt_rounded, size: 16),
                    onPressed: () {
                      ref
                          .read(appControllerProvider.notifier)
                          .setDefaultResume(resume.id);
                      Navigator.pop(sheetContext);
                      AppMotion.selectionHaptic();
                      context.push('/match');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            AdaptiveButton.secondary(
              isFullWidth: true,
              label: 'Copy Full Resume Text',
              icon: const Icon(Icons.copy_rounded, size: 16),
              onPressed: () {
                _exportPlainText(resume);
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            // ATS Health Diagnostic
            _buildAtsHealthCard(resume),

            const SizedBox(height: AppSpacing.md),

            // Extracted Skills Section
            if (skills.isNotEmpty) ...[
              Text(
                'Detected Skills (${skills.length})',
                style: AppTypography.headline.copyWith(
                  color: colors.labelPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: skills.map((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colors.paleIndigoSurface,
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                      border: Border.all(color: colors.borderSubtle),
                    ),
                    child: Text(
                      skill,
                      style: AppTypography.caption.copyWith(
                        color: colors.labelPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Extracted Text View
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Extracted Resume Text',
                  style: AppTypography.headline.copyWith(
                    color: colors.labelPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '$charCount chars',
                  style: AppTypography.monoScore.copyWith(
                    fontSize: 11,
                    color: colors.labelTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 280),
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: colors.borderSubtle),
              ),
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                child: SelectableText(
                  resume.extractedText.trim().isEmpty
                      ? 'No extracted text found for this resume.'
                      : resume.extractedText.trim(),
                  style: AppTypography.body.copyWith(
                    color: colors.labelPrimary,
                    fontSize: 13,
                    height: 1.5,
                  ),
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
    super.build(context);
    final state = ref.watch(appControllerProvider);
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  'Resume Vault is Locked',
                  style: AppTypography.title2.copyWith(
                    color: colors.labelPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Please sign in to view and manage your uploaded resumes and ATS scans.',
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

    final visibleResumes = state.resumes.where((r) => !r.isSample).toList();
    final selectedId = state.selectedMatchResumeId ?? state.defaultResumeId;

    return SafeArea(
      bottom: false,
      child: ContentState(
        isLoading: !state.ready,
        onRetry: () => ref.invalidate(appControllerProvider),
        empty: EmptyState(
          icon: Icons.description_outlined,
          title: 'No resumes in the vault',
          message: 'Add a PDF to start matching with jobs.',
          action: AdaptiveButton.primary(
            icon: const Icon(Icons.upload_file_rounded, size: 20),
            label: 'Upload PDF',
            onPressed: _checkingPdf ? null : _pickAndValidatePdf,
          ),
        ),
        normal: Stack(
          children: [
            CustomScrollView(
              key: const PageStorageKey('vault-scroll'),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverAppTopBar(
                  title: 'Resume Vault',
                  avatarLetter: state.profile.initialLetter,
                  avatarUrl: state.profile.avatarUrl,
                  expandedHeight: 64,
                ),
                if (visibleResumes.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: AdaptiveCard(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Expanded(
                              child: AdaptiveButton.primary(
                                onPressed: _checkingPdf
                                    ? null
                                    : _pickAndValidatePdf,
                                icon: const Icon(
                                  Icons.upload_file_outlined,
                                  size: 18,
                                ),
                                label: _checkingPdf
                                    ? 'Checking PDF'
                                    : 'Upload PDF',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AdaptiveButton.secondary(
                                onPressed: _showManualPasteSheet,
                                icon: const Icon(
                                  Icons.paste_outlined,
                                  size: 18,
                                ),
                                label: 'Paste text',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_error != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colors.error.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              _error!,
                              style: AppTypography.caption.copyWith(
                                color: colors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ],

                        if (visibleResumes.isEmpty) ...[
                          DashedFrame(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 32,
                              ),
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.lg,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: colors.paleIndigoSurface,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.upload_file_rounded,
                                      size: 28,
                                      color: colors.accent,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  Text(
                                    'No resumes uploaded yet',
                                    style: AppTypography.headline.copyWith(
                                      color: colors.labelPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Upload a searchable PDF resume or paste text manually to inspect ATS layout health and run instant matches.',
                                    style: AppTypography.body.copyWith(
                                      color: colors.labelSecondary,
                                      height: 1.4,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: AdaptiveButton.primary(
                                          onPressed: _checkingPdf
                                              ? null
                                              : _pickAndValidatePdf,
                                          icon: _checkingPdf
                                              ? SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        const AlwaysStoppedAnimation(
                                                          Colors.white,
                                                        ),
                                                  ),
                                                )
                                              : const Icon(
                                                  Icons.add_rounded,
                                                  size: 20,
                                                ),
                                          label: _checkingPdf
                                              ? 'Checking PDF…'
                                              : 'Upload PDF',
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: AdaptiveButton.secondary(
                                          icon: const Icon(
                                            Icons.paste_rounded,
                                            size: 18,
                                          ),
                                          label: 'Paste text',
                                          onPressed: _showManualPasteSheet,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ] else ...[
                          // Active Resume Switcher Carousel
                          Text(
                            'Active Resume Versions',
                            style: AppTypography.headline.copyWith(
                              color: colors.labelPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildResumeCarousel(visibleResumes, selectedId),
                          const SizedBox(height: AppSpacing.md),

                          // On-Device ATS Structural Health Diagnostic Card
                          () {
                            final activeResume =
                                visibleResumes
                                    .where((r) => r.id == selectedId)
                                    .firstOrNull ??
                                visibleResumes.first;
                            return _buildAtsHealthCard(activeResume);
                          }(),
                        ],

                        const SizedBox(height: AppSpacing.sm),

                        // Honest Privacy Banner
                        PressableScale(
                          onPressed: _showPrivacyConsentDialog,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              border: Border.all(color: colors.borderSubtle),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.security_rounded,
                                  size: 16,
                                  color: colors.labelSecondary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'PDFs are parsed locally under RA 10173. Raw PDFs stay on device. Parsed text syncs only after consent. Tap to review consent.',
                                    style: AppTypography.caption.copyWith(
                                      color: colors.labelSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.md),
                        if (visibleResumes.isNotEmpty) ...[
                          Text(
                            'Stored Resumes (${visibleResumes.length})',
                            style: AppTypography.headline.copyWith(
                              color: colors.labelPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                        ],
                      ],
                    ),
                  ),
                ),

                // Resumes list
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 108),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final resume = visibleResumes[index];
                      final isSelected = resume.id == selectedId;
                      final skillsCount = _detectSkillsCount(resume);

                      final (statusBg, statusFg) = switch (resume.atsStatus) {
                        'ATS OK' || 'ATS Ready' => (
                          isDark
                              ? const Color(0xFF173323)
                              : const Color(0xFFE8F5E9),
                          isDark
                              ? const Color(0xFF9ED5AB)
                              : const Color(0xFF2E7D32),
                        ),
                        'Complex layout' || 'Layout Warnings' => (
                          isDark
                              ? const Color(0xFF3B1F21)
                              : const Color(0xFFFFEBEE),
                          isDark
                              ? const Color(0xFFF3A6A1)
                              : const Color(0xFFC62828),
                        ),
                        _ => (colors.paleIndigoSurface, colors.labelSecondary),
                      };

                      final atsDisplayStatus = switch (resume.atsStatus) {
                        'ATS OK' || 'ATS Ready' => 'ATS OK',
                        'Complex layout' ||
                        'Layout Warnings' => 'Complex layout',
                        _ => resume.atsStatus,
                      };

                      final isNarrow =
                          MediaQuery.textScalerOf(context).scale(13) > 16 ||
                          MediaQuery.sizeOf(context).width < 340;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ResumeActions(
                          id: resume.id,
                          canRemove: visibleResumes.length > 1,
                          onActivate: () {
                            ref
                                .read(appControllerProvider.notifier)
                                .setDefaultResume(resume.id);
                            AppMotion.selectionHaptic();
                            showGlassToast(context, 'Active resume updated');
                          },
                          onPreviewText: () => _previewExtractedText(resume),
                          onExportText: () => _exportPlainText(resume),
                          onRemove: () async {
                            if (await confirmAction(
                              context,
                              title: 'Remove resume?',
                              message:
                                  'This will remove ${resume.title} from your vault.',
                              confirmLabel: 'Remove',
                            )) {
                              ref
                                  .read(appControllerProvider.notifier)
                                  .deleteResume(resume.id);
                              if (context.mounted) {
                                showGlassToast(context, 'Resume removed');
                              }
                            }
                          },
                          child: PressableScale(
                            onPressed: () => _showResumeViewerSheet(resume),
                            child: AdaptiveCard(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (isNarrow) ...[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: colors.paleIndigoSurface,
                                            borderRadius: BorderRadius.circular(
                                              AppRadius.md,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.description_rounded,
                                            color: colors.accent,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: statusBg,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    AppRadius.capsule,
                                                  ),
                                            ),
                                            child: Text(
                                              atsDisplayStatus,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: statusFg,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      resume.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.headline.copyWith(
                                        color: colors.labelPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Added ${shortDate(resume.addedAt)}',
                                      style: AppTypography.caption.copyWith(
                                        color: colors.labelTertiary,
                                      ),
                                    ),
                                  ] else ...[
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: colors.paleIndigoSurface,
                                            borderRadius: BorderRadius.circular(
                                              AppRadius.md,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.description_rounded,
                                            color: colors.accent,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                resume.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: AppTypography.headline
                                                    .copyWith(
                                                      color:
                                                          colors.labelPrimary,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Added ${shortDate(resume.addedAt)}',
                                                style: AppTypography.caption
                                                    .copyWith(
                                                      color:
                                                          colors.labelTertiary,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: statusBg,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    AppRadius.capsule,
                                                  ),
                                            ),
                                            child: Text(
                                              atsDisplayStatus,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: statusFg,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: AppSpacing.sm),
                                  // Skills count tag
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colors.surface,
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.xs,
                                        ),
                                        border: Border.all(
                                          color: colors.separator.withValues(
                                            alpha: 0.5,
                                          ),
                                        ),
                                      ),
                                      child: Text.rich(
                                        TextSpan(
                                          children: [
                                            WidgetSpan(
                                              alignment:
                                                  PlaceholderAlignment.middle,
                                              child: Icon(
                                                Icons.code_rounded,
                                                size: 14,
                                                color: colors.accent,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  ' $skillsCount skills detected',
                                              style: AppTypography.caption
                                                  .copyWith(
                                                    color:
                                                        colors.labelSecondary,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 11,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  Wrap(
                                    alignment: WrapAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: [
                                          PressableScale(
                                            onPressed: () {
                                              AppMotion.selectionHaptic();
                                              _showResumeViewerSheet(resume);
                                            },
                                            child: Container(
                                              constraints: const BoxConstraints(
                                                minHeight: 36,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: colors.paleIndigoSurface,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppRadius.capsule,
                                                    ),
                                                border: Border.all(
                                                  color: colors.borderSubtle,
                                                ),
                                              ),
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.visibility_outlined,
                                                      size: 14,
                                                      color:
                                                          colors.labelPrimary,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'View Resume',
                                                      style: TextStyle(
                                                        color:
                                                            colors.labelPrimary,
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          PressableScale(
                                            onPressed: () {
                                              AppMotion.selectionHaptic();
                                              ref
                                                  .read(
                                                    appControllerProvider
                                                        .notifier,
                                                  )
                                                  .setDefaultResume(resume.id);
                                              context.push('/match');
                                            },
                                            child: Container(
                                              constraints: const BoxConstraints(
                                                minHeight: 36,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: colors.paleIndigoSurface,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppRadius.capsule,
                                                    ),
                                                border: Border.all(
                                                  color: colors.accent
                                                      .withValues(alpha: 0.35),
                                                ),
                                              ),
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.bolt_rounded,
                                                      size: 14,
                                                      color: colors.accent,
                                                    ),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                      'Analyze',
                                                      style: TextStyle(
                                                        color: colors.accent,
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (isSelected)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .check_circle_rounded,
                                                      color: colors.accent,
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'Active',
                                                      style: AppTypography
                                                          .footnote
                                                          .copyWith(
                                                            color:
                                                                colors.accent,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 12,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            else
                                              PressableScale(
                                                onPressed: () {
                                                  AppMotion.selectionHaptic();
                                                  ref
                                                      .read(
                                                        appControllerProvider
                                                            .notifier,
                                                      )
                                                      .setDefaultResume(
                                                        resume.id,
                                                      );
                                                  showGlassToast(
                                                    context,
                                                    'Resume selected',
                                                    icon: Icons
                                                        .check_circle_rounded,
                                                  );
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: colors.surface,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          AppRadius.capsule,
                                                        ),
                                                    border: Border.all(
                                                      color:
                                                          colors.borderSubtle,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'Set Active',
                                                    style: TextStyle(
                                                      color:
                                                          colors.labelSecondary,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            IconButton(
                                              constraints: const BoxConstraints(
                                                minWidth: 36,
                                                minHeight: 36,
                                              ),
                                              icon: const Icon(
                                                Icons.edit_outlined,
                                                size: 17,
                                              ),
                                              color: colors.labelTertiary,
                                              tooltip: 'Rename resume',
                                              onPressed: () =>
                                                  _showRenameResumeSheet(
                                                    resume,
                                                  ),
                                            ),
                                            if (visibleResumes.length > 1)
                                              IconButton(
                                                constraints:
                                                    const BoxConstraints(
                                                      minWidth: 36,
                                                      minHeight: 36,
                                                    ),
                                                icon: const Icon(
                                                  Icons.delete_outline_rounded,
                                                  size: 17,
                                                ),
                                                color: colors.labelTertiary,
                                                tooltip: 'Delete resume',
                                                onPressed: () async {
                                                  if (await confirmAction(
                                                    context,
                                                    title: 'Remove resume?',
                                                    message:
                                                        'This will remove ${resume.title} from your vault.',
                                                    confirmLabel: 'Remove',
                                                  )) {
                                                    ref
                                                        .read(
                                                          appControllerProvider
                                                              .notifier,
                                                        )
                                                        .deleteResume(
                                                          resume.id,
                                                        );
                                                    if (context.mounted) {
                                                      showGlassToast(
                                                        context,
                                                        'Resume removed',
                                                      );
                                                    }
                                                  }
                                                },
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }, childCount: visibleResumes.length),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
