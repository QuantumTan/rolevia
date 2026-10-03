import 'dart:async';

import 'package:flutter/material.dart';

import '../core/widgets/offline_banner.dart';

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
import '../core/widgets/adaptive_sheet.dart';
import '../core/widgets/adaptive_toast.dart';
import '../core/widgets/app_top_bar.dart';
import '../core/widgets/pressable.dart';
import '../core/widgets/skeleton.dart';
import '../shared/widgets.dart';
import '../state/app_state.dart';

class MatchScreen extends ConsumerStatefulWidget {
  const MatchScreen({super.key});

  @override
  ConsumerState<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends ConsumerState<MatchScreen>
    with AutomaticKeepAliveClientMixin {
  late final TextEditingController _textController;
  bool _tipsVisible = true;

  Future<void> _pasteText() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (!mounted) return;
      if (data?.text?.isNotEmpty ?? false) {
        _textController.text = data!.text!;
        _onTextChanged(data.text!);
        AppMotion.lightHaptic();
      } else {
        showGlassToast(context, 'Copy a job post first');
      }
    } catch (_) {
      if (mounted) {
        showGlassToast(
          context,
          'Paste unavailable. Paste directly in the text field.',
        );
      }
    }
  }

  static const sampleJobText =
      'Northwind Digital is hiring a Junior Flutter Developer in Davao City. Build mobile features using Flutter, REST APIs, Git, SQL, Docker, and CI/CD.';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final initialText = ref.read(appControllerProvider).matchJobText;
    _textController = TextEditingController(
      text: initialText.isNotEmpty ? initialText : sampleJobText,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    ref.read(appControllerProvider.notifier).setMatchJobText(text);
    setState(() {});
  }

  void _trySample() {
    _textController.text = sampleJobText;
    _onTextChanged(sampleJobText);
    AppMotion.selectionHaptic();
  }

  void _clearText() {
    _textController.clear();
    _onTextChanged('');
    AppMotion.selectionHaptic();
  }

  void _openResumePickerSheet(BuildContext context) {
    final state = ref.read(appControllerProvider);
    final colors = AppColors.of(context);

    showAdaptiveSheet(
      context: context,
      title: 'Choose a resume',
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...state.resumes.map((resume) {
              final isSelected =
                  resume.id ==
                  (state.selectedMatchResumeId ?? state.defaultResumeId);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: PressableScale(
                  onPressed: () {
                    AppMotion.selectionHaptic();
                    ref
                        .read(appControllerProvider.notifier)
                        .setDefaultResume(resume.id);
                    Navigator.pop(sheetContext);
                    showGlassToast(context, 'Resume selected');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
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
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                resume.title,
                                style: AppTypography.headline.copyWith(
                                  color: colors.labelPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${resume.fileType} · ${resume.atsStatus}',
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
                ),
              );
            }),
            const SizedBox(height: 12),
            AdaptiveButton.secondary(
              isFullWidth: true,
              onPressed: () {
                Navigator.pop(sheetContext);
                context.go('/vault');
              },
              label: 'Manage resumes in Vault',
            ),
          ],
        ),
      ),
    );
  }

  void _showLimitSheet() {
    showAdaptiveSheet(
      context: context,
      title: 'Daily limit reached',
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'You have no scans remaining. Additional scans are currently unavailable.',
              style: AppTypography.body.copyWith(
                color: AppColors.of(context).labelSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AdaptiveButton.primary(
              isFullWidth: true,
              onPressed: () {
                Navigator.pop(sheetContext);
                _showRewardedAdModal();
              },
              icon: const Icon(Icons.play_circle_outline_rounded, size: 20),
              label: 'Watch ad for +1 scan',
            ),
            const SizedBox(height: AppSpacing.sm),
            AdaptiveButton.secondary(
              isFullWidth: true,
              onPressed: () {
                Navigator.pop(sheetContext);
                showGlassToast(context, 'Pro plans are currently unavailable');
              },
              label: 'Upgrade to Pro',
            ),
            const SizedBox(height: AppSpacing.xs),
            AdaptiveButton.tertiary(
              isFullWidth: true,
              onPressed: () => Navigator.pop(sheetContext),
              label: 'Not now',
            ),
          ],
        ),
      ),
    );
  }

  void _showRewardedAdModal() {
    showDialog(
      context: context,
      builder: (dialogContext) => const _RewardedAdDialog(),
    );
  }

  void _startAnalysis() {
    final state = ref.read(appControllerProvider);
    final text = _textController.text.trim();

    if (text.isEmpty) {
      showGlassToast(context, 'Please paste a job description');
      return;
    }

    if (state.profile.scanQuota <= 0) {
      _showLimitSheet();
      return;
    }

    if (state.isOffline) {
      final resumeId =
          state.selectedMatchResumeId ?? state.defaultResumeId ?? 'r1';
      ref
          .read(appControllerProvider.notifier)
          .queueOfflineAnalysis(jobText: text, resumeId: resumeId);
      showGlassToast(context, 'Analysis queued for when back online');
      return;
    }

    // Consume 1 scan
    final consumed = ref.read(appControllerProvider.notifier).consumeScan();
    if (!consumed) {
      _showLimitSheet();
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _AnalysisLoadingDialog(
        onCancel: () {
          // Refund scan
          ref.read(appControllerProvider.notifier).refundScan();
        },
        onComplete: () {
          final resumeId =
              state.selectedMatchResumeId ?? state.defaultResumeId ?? 'r1';
          final result = ref
              .read(appControllerProvider.notifier)
              .analyze(
                resumeId: resumeId,
                jobId: state.selectedMatchJobId,
                pasted: text,
              );
          context.push('/matches/${result.id}');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(appControllerProvider);
    final colors = AppColors.of(context);

    final selectedResume =
        state.resumes
            .where(
              (r) =>
                  r.id ==
                  (state.selectedMatchResumeId ?? state.defaultResumeId),
            )
            .firstOrNull ??
        state.resumes.firstOrNull;

    final charCount = _textController.text.length;

    return SafeArea(
      bottom: false,
      child: ScenarioState(
        scenario: state.scenario,
        onRetry: () => ref
            .read(appControllerProvider.notifier)
            .setScenario(DemoScenario.normal),
        normal: CustomScrollView(
          key: const PageStorageKey('match-scroll'),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverAppTopBar(
              title: Brand.appName,
              subtitle: state.profile.name.trim().isEmpty
                  ? 'Ready to match?'
                  : 'Hi ${state.profile.name.trim().split(' ').first}, ready to match?',
              expandedHeight: 96,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 108),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Subtitle & Quota Badge
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Text(
                          'Make your next move count.',
                          style: AppTypography.subheadline.copyWith(
                            color: colors.labelSecondary,
                          ),
                        ),
                        // Solid scan badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: state.profile.scanQuota <= 1
                                ? colors.warning.withValues(alpha: 0.12)
                                : colors.paleIndigoSurface,
                            borderRadius: BorderRadius.circular(
                              AppRadius.capsule,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bolt_rounded,
                                size: 14,
                                color: state.profile.scanQuota <= 1
                                    ? colors.warning
                                    : colors.accent,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  '${state.profile.scanQuota} scans left',
                                  style: AppTypography.caption.copyWith(
                                    color: state.profile.scanQuota <= 1
                                        ? colors.warning
                                        : colors.accent,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (state.profile.scanQuota == 0)
                      AdaptiveButton.tertiary(
                        onPressed: _showRewardedAdModal,
                        label: 'Get another scan',
                      ),

                    OfflineBanner(offline: state.isOffline),

                    const SizedBox(height: AppSpacing.lg),

                    // Step 1: Add a job post
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            '1',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          'Add a job post',
                          style: AppTypography.headline.copyWith(
                            color: colors.labelPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '· Text works best',
                          style: AppTypography.footnote.copyWith(
                            color: colors.labelTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Solid Textarea
                    Container(
                      height: 136,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        controller: _textController,
                        maxLines: null,
                        expands: true,
                        style: AppTypography.body.copyWith(
                          color: colors.labelPrimary,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Paste the role, responsibilities, and requirements here…',
                          hintStyle: AppTypography.body.copyWith(
                            color: colors.labelTertiary,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: _onTextChanged,
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        textInputAction: TextInputAction.newline,
                      ),
                    ),

                    // Helper & Character Counter / Actions
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        AdaptiveButton.tertiary(
                          onPressed: _pasteText,
                          icon: const Icon(
                            Icons.content_paste_rounded,
                            size: 16,
                          ),
                          label: 'Paste',
                        ),
                        if (charCount > 0)
                          Text(
                            '$charCount characters',
                            style: AppTypography.caption.copyWith(
                              color: colors.labelTertiary,
                            ),
                          )
                        else
                          Text(
                            'From any job board or social post',
                            style: AppTypography.caption.copyWith(
                              color: colors.labelTertiary,
                            ),
                          ),
                        PressableScale(
                          onPressed: _trySample,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Text(
                              'Use example',
                              style: AppTypography.footnote.copyWith(
                                color: colors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        if (charCount > 0)
                          PressableScale(
                            onPressed: _clearText,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Text(
                                'Clear',
                                style: AppTypography.footnote.copyWith(
                                  color: colors.labelSecondary,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Step 2: Choose your resume
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            '2',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          'Choose your resume',
                          style: AppTypography.headline.copyWith(
                            color: colors.labelPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Solid selectable resume card
                    PressableScale(
                      onPressed: () => _openResumePickerSheet(context),
                      child: AdaptiveCard(
                        padding: const EdgeInsets.all(16),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth < 100) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.description_rounded,
                                    color: colors.accent,
                                    size: 20,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    selectedResume?.title ?? 'Choose a resume',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.caption.copyWith(
                                      color: colors.labelPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              );
                            }
                            if (constraints.maxWidth < 240) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: colors.paleIndigoSurface,
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.md,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.description_rounded,
                                          color: colors.accent,
                                          size: 20,
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        color: colors.labelTertiary,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    selectedResume?.title ?? 'Choose a resume',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.headline.copyWith(
                                      color: colors.labelPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    selectedResume == null
                                        ? 'Add a resume in Vault to compare'
                                        : 'Ready to compare · Change resume',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.footnote.copyWith(
                                      color: colors.labelSecondary,
                                    ),
                                  ),
                                ],
                              );
                            }
                            return Row(
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
                                        selectedResume?.title ??
                                            'Choose a resume',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.headline.copyWith(
                                          color: colors.labelPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        selectedResume == null
                                            ? 'Add a resume in Vault to compare'
                                            : 'Ready to compare · Change resume',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.footnote.copyWith(
                                          color: colors.labelSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: colors.labelTertiary,
                                  size: 22,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Primary Action: Find my match
                    AdaptiveButton.primary(
                      isFullWidth: true,
                      onPressed: charCount > 0 && selectedResume != null
                          ? _startAnalysis
                          : null,
                      label: state.isOffline
                          ? 'Save for later'
                          : 'Run Analysis',
                    ),

                    const SizedBox(height: AppSpacing.md),

                    if (_tipsVisible) ...[
                      AdaptiveCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    'A better comparison',
                                    style: AppTypography.headline.copyWith(
                                      color: colors.labelPrimary,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Dismiss quick tip',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () =>
                                      setState(() => _tipsVisible = false),
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              'Include responsibilities and required skills. Choose the resume you plan to send.',
                              style: AppTypography.footnote.copyWith(
                                color: colors.labelSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // Disclosure Below Action
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 14,
                          color: colors.labelTertiary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Only include information you want to compare',
                          textAlign: TextAlign.center,
                          style: AppTypography.caption.copyWith(
                            color: colors.labelTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Center(
                      child: Text(
                        'A match score is guidance, not a guarantee.',
                        textAlign: TextAlign.center,
                        style: AppTypography.caption.copyWith(
                          color: colors.labelTertiary,
                        ),
                      ),
                    ),
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

class _AnalysisLoadingDialog extends StatefulWidget {
  const _AnalysisLoadingDialog({
    required this.onCancel,
    required this.onComplete,
  });

  final VoidCallback onCancel;
  final VoidCallback onComplete;

  @override
  State<_AnalysisLoadingDialog> createState() => _AnalysisLoadingDialogState();
}

class _AnalysisLoadingDialogState extends State<_AnalysisLoadingDialog> {
  int currentStep = 0;
  Timer? timer1;
  Timer? timer2;
  Timer? timer3;

  static const steps = ['Reading job post', 'Matching skills', 'Checking ATS'];

  @override
  void initState() {
    super.initState();
    timer1 = Timer(const Duration(milliseconds: 650), () {
      if (mounted) setState(() => currentStep = 1);
    });
    timer2 = Timer(const Duration(milliseconds: 1300), () {
      if (mounted) setState(() => currentStep = 2);
    });
    timer3 = Timer(const Duration(milliseconds: 2000), () {
      if (mounted) {
        Navigator.pop(context);
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    timer1?.cancel();
    timer2?.cancel();
    timer3?.cancel();
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Analysis',
                style: AppTypography.title2.copyWith(
                  color: colors.labelPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: 52,
                height: 52,
                child: CircularProgressIndicator(
                  strokeWidth: 3.5,
                  valueColor: AlwaysStoppedAnimation(colors.accent),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Comparing your resume to the job...',
                style: AppTypography.headline.copyWith(
                  color: colors.labelPrimary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              // Steps indicator
              Column(
                children: List.generate(steps.length, (i) {
                  final isDone = i < currentStep;
                  final isCurrent = i == currentStep;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          isDone
                              ? Icons.check_circle_rounded
                              : (isCurrent
                                    ? Icons.radio_button_checked_rounded
                                    : Icons.radio_button_off_rounded),
                          color: isDone || isCurrent
                              ? colors.primary
                              : colors.labelTertiary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          steps[i],
                          style: AppTypography.footnote.copyWith(
                            color: isDone || isCurrent
                                ? colors.labelPrimary
                                : colors.labelTertiary,
                            fontWeight: isCurrent
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.lg),
              AdaptiveButton.tertiary(
                onPressed: () {
                  timer1?.cancel();
                  timer2?.cancel();
                  timer3?.cancel();
                  Navigator.pop(context);
                  widget.onCancel();
                },
                label: 'Cancel',
              ),
              const SizedBox(height: AppSpacing.sm),
              const SkeletonBox(height: 12),
              const SizedBox(height: AppSpacing.xs),
              const SkeletonBox(width: 140, height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _RewardedAdDialog extends StatelessWidget {
  const _RewardedAdDialog();

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
                      'Rewarded ad',
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
                'No ads available',
                style: AppTypography.title2.copyWith(
                  color: colors.labelPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Rewarded ads are currently unavailable. Please try again later.',
                style: AppTypography.body.copyWith(
                  color: colors.labelSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              AdaptiveButton.primary(
                isFullWidth: true,
                onPressed: () => Navigator.pop(context),
                label: 'Close',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
