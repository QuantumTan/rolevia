import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/brand.dart';
import '../core/design/colors.dart';
import '../core/design/motion.dart';
import '../core/design/radius.dart';
import '../core/design/spacing.dart';
import '../core/design/typography.dart';
import '../core/widgets/adaptive_button.dart';
import '../core/widgets/adaptive_card.dart';
import '../core/widgets/adaptive_toast.dart';
import '../core/widgets/app_top_bar.dart';
import '../core/widgets/pressable.dart';
import '../models/models.dart';
import '../shared/widgets.dart';
import '../state/app_state.dart';

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
    setState(() {
      _checkingPdf = true;
      _error = null;
    });

    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );

      if (file == null) {
        setState(() => _checkingPdf = false);
        return;
      }

      final size = (await file.length()) ?? file.lengthSync() ?? 0;

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

      // Check %PDF- signature
      final bytes = await file.readAsBytes();
      if (bytes.length >= 5) {
        final header = utf8.decode(bytes.sublist(0, 5), allowMalformed: true);
        if (!header.startsWith('%PDF-')) {
          setState(() {
            _checkingPdf = false;
            _error = 'Invalid PDF: File does not have a valid %PDF- signature.';
          });
          return;
        }
      }

      final newResume = ResumeVersion(
        id: 'r_${DateTime.now().microsecondsSinceEpoch}',
        title: file.name.replaceAll('.pdf', ''),
        filename: file.name,
        fileType: 'PDF',
        addedAt: DateTime.now(),
        isSample: false,
        atsStatus: 'Not analyzed',
      );

      ref.read(appControllerProvider.notifier).addResume(newResume);
      setState(() => _checkingPdf = false);
      if (mounted) {
        showGlassToast(context, 'Resume added to Vault');
      }
    } catch (e) {
      setState(() {
        _checkingPdf = false;
        _error = 'Could not load file: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(appControllerProvider);
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedId =
        state.selectedMatchResumeId ?? state.defaultResumeId ?? 'r1';

    return SafeArea(
      bottom: false,
      child: ScenarioState(
        scenario: state.scenario,
        onRetry: () => ref
            .read(appControllerProvider.notifier)
            .setScenario(DemoScenario.normal),
        empty: const EmptyState(
          icon: Icons.description_outlined,
          title: 'No resumes in the vault',
          message: 'Add a PDF to start matching with jobs.',
        ),
        normal: CustomScrollView(
          key: const PageStorageKey('vault-scroll'),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverAppTopBar(
              title: 'Resume Vault',
              subtitle: 'Keep tailored resumes ready for every application.',
              expandedHeight: 96,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Add resume button
                    AdaptiveButton.primary(
                      isFullWidth: true,
                      onPressed: _checkingPdf ? null : _pickAndValidatePdf,
                      icon: _checkingPdf
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.add_rounded, size: 20),
                      label: _checkingPdf ? 'Checking PDF…' : 'Add resume',
                    ),

                    if (_error != null) ...[
                      const SizedBox(height: AppSpacing.sm),
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
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final resume = state.resumes[index];
                  final isSelected = resume.id == selectedId;

                  final (statusBg, statusFg) = switch (resume.atsStatus) {
                    'ATS OK' => (
                      isDark
                          ? const Color(0xFF173323)
                          : const Color(0xFFE8F5E9),
                      isDark
                          ? const Color(0xFF9ED5AB)
                          : const Color(0xFF2E7D32),
                    ),
                    'Complex layout' => (
                      isDark
                          ? const Color(0xFF3B1F21)
                          : const Color(0xFFFFEBEE),
                      isDark
                          ? const Color(0xFFF3A6A1)
                          : const Color(0xFFC62828),
                    ),
                    _ => (colors.paleIndigoSurface, colors.labelSecondary),
                  };

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AdaptiveCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flex(
                            direction:
                                MediaQuery.textScalerOf(context).scale(13) > 18
                                ? Axis.vertical
                                : Axis.horizontal,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                              Flexible(
                                fit: FlexFit.loose,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      resume.title,
                                      style: AppTypography.headline.copyWith(
                                        color: colors.labelPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Created ${shortDate(resume.addedAt)}',
                                      style: AppTypography.caption.copyWith(
                                        color: colors.labelTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
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
                                  resume.atsStatus,
                                  style: TextStyle(
                                    color: statusFg,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (isSelected)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: colors.accent,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        'Selected for matching',
                                        style: AppTypography.footnote.copyWith(
                                          color: colors.accent,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
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
                              if (state.resumes.length > 1)
                                IconButton(
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
                                          .read(appControllerProvider.notifier)
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
                  );
                }, childCount: state.resumes.length),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
