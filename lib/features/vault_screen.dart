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
import '../core/widgets/adaptive_sheet.dart';
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
  const VaultScreen({super.key});

  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends ConsumerState<VaultScreen>
    with AutomaticKeepAliveClientMixin {
  bool _checkingPdf = false;
  String? _error;

  @override
  bool get wantKeepAlive => true;

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
            icon: const Icon(Icons.add_rounded, size: 20),
            label: 'Add resume',
            onPressed: _checkingPdf ? null : _pickAndValidatePdf,
          ),
        ),
        normal: CustomScrollView(
          key: const PageStorageKey('vault-scroll'),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverAppTopBar(
              title: 'Resume Vault',
              subtitle: 'Keep tailored resumes ready for every application.',
              avatarLetter: state.profile.initialLetter,
              avatarUrl: state.profile.avatarUrl,
              expandedHeight: 96,
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
                            borderRadius: BorderRadius.circular(AppRadius.lg),
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
                                'Upload a searchable PDF resume to check ATS formatting, detect key skills, and run instant job matches.',
                                style: AppTypography.body.copyWith(
                                  color: colors.labelSecondary,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              AdaptiveButton.primary(
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
                                    : const Icon(Icons.add_rounded, size: 20),
                                label: _checkingPdf
                                    ? 'Checking PDF…'
                                    : 'Upload Resume (PDF)',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      // Add resume button
                      DashedFrame(
                        child: AdaptiveButton.secondary(
                          isFullWidth: true,
                          onPressed: _checkingPdf ? null : _pickAndValidatePdf,
                          icon: _checkingPdf
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      colors.accent,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.add_rounded, size: 20),
                          label: _checkingPdf
                              ? 'Checking PDF…'
                              : 'Upload Resume (PDF)',
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.sm),

                    // Honest Privacy Banner
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                          color: colors.separator.withValues(alpha: 0.5),
                        ),
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
                              'PDFs are validated locally on your device. No file data is sent to a server.',
                              style: AppTypography.caption.copyWith(
                                color: colors.labelSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),
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
                    'Complex layout' || 'Layout Warnings' => 'Complex layout',
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
                                        borderRadius: BorderRadius.circular(
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
                                crossAxisAlignment: CrossAxisAlignment.center,
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
                                        borderRadius: BorderRadius.circular(
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
                                        alignment: PlaceholderAlignment.middle,
                                        child: Icon(
                                          Icons.psychology_outlined,
                                          size: 14,
                                          color: colors.accent,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' $skillsCount skills detected',
                                        style: AppTypography.caption.copyWith(
                                          color: colors.labelSecondary,
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
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (isSelected)
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      minHeight: 44,
                                    ),
                                    child: Center(
                                      child: Text.rich(
                                        TextSpan(
                                          children: [
                                            WidgetSpan(
                                              alignment:
                                                  PlaceholderAlignment.middle,
                                              child: Icon(
                                                Icons.check_circle_rounded,
                                                color: colors.accent,
                                                size: 18,
                                              ),
                                            ),
                                            TextSpan(
                                              text: ' Active resume',
                                              style: AppTypography.footnote
                                                  .copyWith(
                                                    color: colors.accent,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                else
                                  PressableScale(
                                    onPressed: () {
                                      AppMotion.selectionHaptic();
                                      ref
                                          .read(appControllerProvider.notifier)
                                          .setDefaultResume(resume.id);
                                      showGlassToast(
                                        context,
                                        'Resume selected',
                                        icon: Icons.check_circle_rounded,
                                      );
                                    },
                                    child: Container(
                                      constraints: const BoxConstraints(
                                        minHeight: 44,
                                      ),
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colors.paleIndigoSurface,
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.capsule,
                                        ),
                                      ),
                                      child: Text(
                                        'Use this resume',
                                        style: TextStyle(
                                          color: colors.accent,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                if (visibleResumes.length > 1)
                                  IconButton(
                                    constraints: const BoxConstraints(
                                      minWidth: 44,
                                      minHeight: 44,
                                    ),
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      size: 18,
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
                                              appControllerProvider.notifier,
                                            )
                                            .deleteResume(resume.id);
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
                          ],
                        ),
                      ),
                    ),
                  );
                }, childCount: visibleResumes.length),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
