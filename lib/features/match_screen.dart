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
import '../core/services/ad_service.dart';
import '../core/services/job_ingestion.dart';
import '../core/widgets/adaptive_button.dart';
import '../core/widgets/adaptive_card.dart';
import '../core/widgets/adaptive_sheet.dart';
import '../core/widgets/adaptive_toast.dart';
import '../core/widgets/app_top_bar.dart';
import '../core/widgets/pressable.dart';
import '../core/widgets/skeleton.dart';
import '../state/app_state.dart';
import '../data/repositories/auth_repository.dart';

class MatchScreen extends ConsumerStatefulWidget {
  const MatchScreen({super.key});
  @override
  ConsumerState<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends ConsumerState<MatchScreen>
    with AutomaticKeepAliveClientMixin {
  late final TextEditingController _text;
  String? _error;
  bool _busy = false;
  bool _adLoading = false;
  bool _clipboardAvailable = false;
  bool _inputExpanded = true;
  late String _originalText;
  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    _text = TextEditingController(
      text: ref.read(appControllerProvider).matchJobText,
    );
    _originalText = _text.text;
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _checkClipboard() async {
    try {
      final available = await Clipboard.hasStrings();
      if (mounted) setState(() => _clipboardAvailable = available);
    } catch (_) {
      /* Clipboard access may be denied by the platform. */
    }
  }

  Future<void> _paste() async {
    AppMotion.selectionHaptic();
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (!mounted) return;
      final input = JobIngestion(data?.text ?? '');
      if (input.text.isEmpty) {
        showGlassToast(context, 'Copy a job post first');
        return;
      }
      _text.text = input.text;
      _changed(input.text, original: input.original);
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              _error = 'Clipboard unavailable. Paste directly into the field.',
        );
      }
    }
  }

  void _changed(String value, {String? original}) {
    _originalText = original ?? value;
    ref.read(appControllerProvider.notifier).setMatchJobText(value);
    setState(() => _error = null);
  }

  void _showOriginalText() {
    showAdaptiveSheet<void>(
      context: context,
      title: 'Original job text',
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: SelectableText(
          _originalText.trim(),
          style: AppTypography.body.copyWith(
            color: AppColors.of(sheetContext).labelPrimary,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  void _chooseResume() {
    AppMotion.selectionHaptic();
    final state = ref.read(appControllerProvider);
    showAdaptiveSheet<void>(
      context: context,
      title: 'Choose a resume',
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final resume in state.resumes)
            ListTile(
              title: Text(resume.filename),
              subtitle: Text(resume.atsStatus),
              selected:
                  resume.id ==
                  (state.selectedMatchResumeId ?? state.defaultResumeId),
              onTap: () {
                AppMotion.selectionHaptic();
                ref
                    .read(appControllerProvider.notifier)
                    .selectMatchInputs(resumeId: resume.id);
                Navigator.pop(sheetContext);
              },
            ),
          AdaptiveButton.secondary(
            label: 'Upload Resume (PDF)',
            onPressed: () {
              Navigator.pop(sheetContext);
              context.go('/vault');
            },
          ),
        ],
      ),
    );
  }

  Future<void> _reward() async {
    if (_adLoading) return;
    setState(() => _adLoading = true);
    AppMotion.selectionHaptic();
    try {
      final ads = ref.read(adServiceProvider);
      await ads.watchRewardedAdOrFallback(
        context: context,
        userId: ref.read(authRepositoryProvider).user?.id,
        onRewardEarned: () {
          if (mounted) {
            ref.read(appControllerProvider.notifier).unlockRewardedScan();
          }
        },
      );
    } catch (_) {
      if (mounted) {
        showGlassToast(context, 'Unable to load ad. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _adLoading = false);
    }
  }

  Future<void> _analyze() async {
    if (_busy) return;
    AppMotion.selectionHaptic();
    final state = ref.read(appControllerProvider);
    final resumeId = state.selectedMatchResumeId ?? state.defaultResumeId;
    if (resumeId == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await Future<void>.delayed(Duration.zero);
      if (!mounted) return;
      final result = ref
          .read(appControllerProvider.notifier)
          .analyzeFull(
            resumeId: resumeId,
            jobId: state.selectedMatchJobId,
            pasted: _originalText,
          );
      final completed = await result;
      if (mounted) context.push('/matches/${completed.id}');
    } on FormatException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Could not complete the comparison. Retry with your resume and job post.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ref.listen(appControllerProvider.select((s) => s.matchJobText), (_, value) {
      if (_text.text != value) {
        _originalText = value;
        _inputExpanded = true;
        _text.value = TextEditingValue(
          text: value,
          selection: TextSelection.collapsed(offset: value.length),
        );
      }
    });
    final state = ref.watch(appControllerProvider);
    final colors = AppColors.of(context);
    final input = JobIngestion(_text.text);
    final resume = state.resumes
        .where(
          (r) => r.id == (state.selectedMatchResumeId ?? state.defaultResumeId),
        )
        .firstOrNull;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: Focus(
          onFocusChange: (focused) {
            if (focused) _checkClipboard();
          },
          child: CustomScrollView(
            key: const PageStorageKey('match-scroll'),
            slivers: [
            SliverAppTopBar(
              title: Brand.appName,
              avatarLetter: state.profile.initialLetter,
              avatarUrl: state.profile.avatarUrl,
              expandedHeight: 64,
            ),
            SliverPadding(
              padding: AppSpacing.edgeInsetsScreen,
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Job match',
                      style: AppTypography.title2.copyWith(
                        color: colors.labelPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Quick estimates work offline. When connected, Rolevia also requests a full evidence analysis.',
                      style: AppTypography.footnote.copyWith(
                        color: colors.labelSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: PressableScale(
                            onPressed: _chooseResume,
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 44),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: colors.paleIndigoSurface,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.capsule,
                                ),
                                border: Border.all(
                                  color: colors.separator.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.description_outlined,
                                    size: 18,
                                    color: colors.accent,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      resume == null
                                          ? 'Choose a resume'
                                          : 'Using: ${resume.filename}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.footnote.copyWith(
                                        color: colors.labelPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down_rounded,
                                    size: 18,
                                    color: colors.labelSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Tooltip(
                          message: 'Upload PDF / Select from Vault',
                          child: PressableScale(
                            onPressed: () {
                              AppMotion.selectionHaptic();
                              context.go('/vault');
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: colors.paleIndigoSurface,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.capsule,
                                ),
                                border: Border.all(
                                  color: colors.separator.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                              child: Icon(
                                Icons.upload_file_rounded,
                                size: 20,
                                color: colors.accent,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AdaptiveCard(
                      child: TextField(
                        controller: _text,
                        minLines: 6,
                        maxLines: _inputExpanded ? null : 8,
                        onChanged: _changed,
                        onTap: _checkClipboard,
                        decoration: const InputDecoration(
                          hintText: 'Paste job description, requirements, or qualifications here...',
                          border: InputBorder.none,
                        ),
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                    ),
                    if (input.result.estimatedLines > 8)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          key: const Key('match-job-text-toggle'),
                          onPressed: () =>
                              setState(() => _inputExpanded = !_inputExpanded),
                          style: TextButton.styleFrom(
                            foregroundColor: colors.accent,
                            minimumSize: const Size(44, 44),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                          child: Text(
                            _inputExpanded ? 'Show less' : 'Show more',
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      children: [
                        AdaptiveButton.tertiary(
                          onPressed: _paste,
                          icon: const Icon(Icons.content_paste),
                          label: _clipboardAvailable
                              ? 'Paste from clipboard'
                              : 'Paste',
                        ),
                        if (_text.text.isNotEmpty)
                          AdaptiveButton.tertiary(
                            label: 'Clear',
                            onPressed: () {
                              AppMotion.selectionHaptic();
                              _text.clear();
                              _changed('');
                            },
                          ),
                      ],
                    ),
                    Text(
                      input.text.isEmpty
                          ? 'Ready to analyze your fit. Paste a job post or import from clipboard.'
                          : '${input.text.length} characters · ${input.words} words · ${input.readingMinutes} min read · Full text used',
                      style: AppTypography.footnote.copyWith(
                        color: colors.labelSecondary,
                      ),
                    ),
                    if (input.text.isNotEmpty &&
                        _originalText.trim() != input.text.trim())
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          key: const Key('match-view-original'),
                          onPressed: _showOriginalText,
                          style: TextButton.styleFrom(
                            foregroundColor: colors.accent,
                            minimumSize: const Size(44, 44),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                          child: const Text('View original'),
                        ),
                      ),
                    if (input.isLikelyTruncated && input.text.length < 160) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Semantics(
                        liveRegion: true,
                        child: Container(
                          key: const Key('match-job-truncation-warning'),
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
                              Icon(
                                Icons.warning_amber_rounded,
                                color: colors.warning,
                              ),
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
                    ],
                    if (input.title != null || input.company != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: colors.paleIndigoSurface,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: colors.separator.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.business_center_outlined,
                              size: 18,
                              color: colors.accent,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (input.title != null)
                                    Text(
                                      input.title!,
                                      style: AppTypography.subheadline.copyWith(
                                        color: colors.labelPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  if (input.company != null)
                                    Text(
                                      input.company!,
                                      style: AppTypography.caption.copyWith(
                                        color: colors.labelSecondary,
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
                    if (_error != null) ...[
                      Text(
                        _error!,
                        style: AppTypography.body.copyWith(color: colors.error),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    if (_busy)
                      const SkeletonBox(height: 48)
                    else
                      AdaptiveButton.primary(
                        isFullWidth: true,
                        label: _error == null
                            ? 'Run Analysis'
                            : 'Retry analysis',
                        onPressed: input.words >= 5 && resume != null
                            ? _analyze
                            : null,
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      '${state.profile.scanQuota} scans left',
                      style: AppTypography.caption.copyWith(
                        color: colors.labelSecondary,
                      ),
                    ),
                    AdaptiveButton.tertiary(
                      label: _adLoading
                          ? 'Loading ad…'
                          : 'Watch ad for +1 scan',
                      onPressed: _adLoading ? null : _reward,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
