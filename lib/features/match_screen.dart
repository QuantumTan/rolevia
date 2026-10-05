import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/design/colors.dart';
import '../core/design/motion.dart';
import '../core/design/radius.dart';
import '../core/design/spacing.dart';
import '../core/design/typography.dart';
import '../core/services/ad_service.dart';
import '../core/services/job_ingestion.dart';
import '../core/widgets/adaptive_button.dart';
import '../core/widgets/adaptive_sheet.dart';
import '../core/widgets/adaptive_toast.dart';
import '../core/widgets/app_top_bar.dart';
import '../core/widgets/pressable.dart';
import '../core/widgets/scan_sweep.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../data/repositories/auth_repository.dart';

const _sampleJobPost = '''Senior Mobile Engineer (Flutter & iOS)
TechFlow Solutions - Remote / Manila, Philippines

About the Role:
We are looking for an experienced Senior Mobile Engineer to lead the architecture and development of our cross-platform customer app built in Flutter.

Key Responsibilities:
- Design, build, and maintain high-performance, reusable Flutter and Dart code.
- Collaborate with cross-functional teams to define, design, and ship new mobile features.
- Ensure app performance, responsiveness, and state management consistency (Riverpod / BLoC).
- Write clean unit, widget, and integration tests to ensure robust mobile releases.

Requirements:
- 4+ years of professional software engineering experience, with 2+ years in Flutter / Dart.
- Strong proficiency in state management (Riverpod, Provider, or BLoC), REST APIs, and SQLite/Hive.
- Demonstrated experience deploying production apps to Google Play Store and Apple App Store.
- Excellent communication skills, self-driven in an agile, remote team environment.

Nice to Have:
- Native iOS (Swift) or Android (Kotlin) development experience.
- Experience with CI/CD pipelines (Fastlane, GitHub Actions) and app performance profiling.''';

class MatchScreen extends ConsumerStatefulWidget {
  const MatchScreen({super.key, this.initialText, this.sourceLabel});

  final String? initialText;
  final String? sourceLabel;

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
  late String _originalText;
  String? _source;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(appControllerProvider).matchJobText;
    final initial =
        (widget.initialText != null && widget.initialText!.isNotEmpty)
        ? widget.initialText!
        : draft;
    _text = TextEditingController(text: initial);
    _originalText = _text.text;
    _source = widget.sourceLabel;
    if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(appControllerProvider.notifier).setMatchJobText(initial);
      });
    }
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

  Future<void> _saveForLater() async {
    AppMotion.selectionHaptic();
    final state = ref.read(appControllerProvider);
    final resumeId = state.selectedMatchResumeId ?? state.defaultResumeId;
    if (resumeId == null) {
      showGlassToast(context, 'Select a resume first');
      return;
    }
    try {
      final result = ref
          .read(appControllerProvider.notifier)
          .analyze(
            resumeId: resumeId,
            jobId: state.selectedMatchJobId,
            pasted: _originalText,
          );
      showGlassToast(
        context,
        'Saved for later. Full cloud analysis will run when connected.',
      );
      if (mounted) context.push('/matches/${result.id}');
    } catch (_) {
      if (mounted) {
        showGlassToast(context, 'Draft saved for later.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ref.listen(appControllerProvider.select((s) => s.matchJobText), (_, value) {
      if (_text.text != value &&
          !(value.isEmpty &&
              widget.initialText != null &&
              widget.initialText!.isNotEmpty)) {
        _originalText = value;
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

    final cardHeight = (MediaQuery.sizeOf(context).height * 0.36).clamp(
      220.0,
      360.0,
    );

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: Focus(
          onFocusChange: (focused) {
            if (focused) _checkClipboard();
          },
          child: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  key: const PageStorageKey('match-scroll'),
                  slivers: [
                    SliverAppTopBar(
                      title: 'Match Studio',
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
                            if (_source != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Chip(
                                    avatar: Icon(
                                      Icons.share_rounded,
                                      size: 14,
                                      color: colors.accent,
                                    ),
                                    label: Text(_source!),
                                    onDeleted: () =>
                                        setState(() => _source = null),
                                    deleteIcon: const Icon(
                                      Icons.close_rounded,
                                      size: 14,
                                    ),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                              ),
                            PressableScale(
                              onPressed: _chooseResume,
                              child: Container(
                                constraints: const BoxConstraints(
                                  minHeight: 44,
                                ),
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
                                            ? 'Analyzing with: No resume (Switch)'
                                            : 'Analyzing with: ${resume.filename} (Switch)',
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
                            const SizedBox(height: AppSpacing.md),
                            // Large input card (min height 220, grows to 360)
                            Container(
                              height: cardHeight,
                              decoration: BoxDecoration(
                                color: colors.elevatedSurface,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                                border: Border.all(color: colors.borderSubtle),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        14,
                                        12,
                                        14,
                                        6,
                                      ),
                                      child: TextField(
                                        controller: _text,
                                        style: AppTypography.monoData.copyWith(
                                          color: colors.labelPrimary,
                                          fontSize: 14,
                                          height: 1.45,
                                        ),
                                        maxLines: null,
                                        expands: true,
                                        textAlignVertical:
                                            TextAlignVertical.top,
                                        keyboardType: TextInputType.multiline,
                                        onChanged: _changed,
                                        onTap: _checkClipboard,
                                        decoration: const InputDecoration(
                                          hintText: 'Paste job description, requirements, or qualifications here...',
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        onTapOutside: (_) => FocusManager
                                            .instance
                                            .primaryFocus
                                            ?.unfocus(),
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    height: 1,
                                    color: colors.separator.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                  Container(
                                    color: colors.surface.withValues(
                                      alpha: 0.4,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                AdaptiveButton.tertiary(
                                                  onPressed: _paste,
                                                  icon: const Icon(
                                                    Icons.content_paste,
                                                    size: 16,
                                                  ),
                                                  label: _clipboardAvailable
                                                      ? 'Paste from clipboard'
                                                      : 'Paste',
                                                ),
                                                if (_text.text.isNotEmpty) ...[
                                                  const SizedBox(width: 4),
                                                  AdaptiveButton.tertiary(
                                                    label: 'Clear',
                                                    onPressed: () {
                                                      AppMotion.selectionHaptic();
                                                      _text.clear();
                                                      _changed('');
                                                    },
                                                  ),
                                                ],
                                                const SizedBox(width: 4),
                                                AdaptiveButton.tertiary(
                                                  label: 'Load sample',
                                                  onPressed: () {
                                                    AppMotion.selectionHaptic();
                                                    _text.text = _sampleJobPost;
                                                    _changed(_sampleJobPost);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${_text.text.length} chars',
                                          style: AppTypography.caption.copyWith(
                                            color: _text.text.length < 50
                                                ? colors.labelTertiary
                                                : colors.labelSecondary,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (input.text.isNotEmpty &&
                                _originalText.trim() != input.text.trim()) ...[
                              const SizedBox(height: AppSpacing.xs),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  key: const Key('match-view-original'),
                                  onPressed: _showOriginalText,
                                  style: TextButton.styleFrom(
                                    foregroundColor: colors.accent,
                                    minimumSize: const Size(44, 44),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                  ),
                                  child: const Text('View original'),
                                ),
                              ),
                            ],
                            if (input.isLikelyTruncated) ...[
                              const SizedBox(height: AppSpacing.sm),
                              Semantics(
                                liveRegion: true,
                                child: Container(
                                  key: const Key(
                                    'match-job-truncation-warning',
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colors.warning.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.sm,
                                    ),
                                    border: Border.all(
                                      color: colors.warning.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        color: colors.warning,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'This looks cut off. Paste the full job description for a more accurate result.',
                                          style: AppTypography.footnote
                                              .copyWith(
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
                            if (input.title != null ||
                                input.company != null) ...[
                              const SizedBox(height: AppSpacing.sm),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.paleIndigoSurface,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.md,
                                  ),
                                  border: Border.all(
                                    color: colors.separator.withValues(
                                      alpha: 0.4,
                                    ),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (input.title != null)
                                            Text(
                                              input.title!,
                                              style: AppTypography.subheadline
                                                  .copyWith(
                                                    color: colors.labelPrimary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          if (input.company != null)
                                            Text(
                                              input.company!,
                                              style: AppTypography.caption
                                                  .copyWith(
                                                    color:
                                                        colors.labelSecondary,
                                                  ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (_busy) ...[
                              const SizedBox(height: AppSpacing.md),
                              const ScanSweep(
                                height: 140,
                                label: 'Analyzing job post against resume…',
                              ),
                            ],
                            if (_error != null) ...[
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                _error!,
                                style: AppTypography.body.copyWith(
                                  color: colors.error,
                                ),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Text(
                                  '${state.profile.scanQuota} scans left',
                                  style: AppTypography.caption.copyWith(
                                    color: colors.labelSecondary,
                                  ),
                                ),
                                const Spacer(),
                                AdaptiveButton.tertiary(
                                  label: _adLoading
                                      ? 'Loading ad…'
                                      : 'Watch ad for +1 scan',
                                  onPressed: _adLoading ? null : _reward,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildStickyBottom(context, colors, state, resume),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStickyBottom(
    BuildContext context,
    AppColors colors,
    AppState state,
    ResumeVersion? resume,
  ) {
    final count = _text.text.trim().length;
    final hasEnoughChars = count >= 50;
    final canSubmit = hasEnoughChars && resume != null && !_busy;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    return AnimatedContainer(
      duration: AppMotion.standard,
      curve: AppMotion.curveStandard,
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        bottomInset > 0 ? 8 : (safeBottom > 0 ? safeBottom : 12),
      ),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        border: Border(
          top: BorderSide(
            color: colors.hairlineBorder,
            width: AppRadius.hairline,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        bottom: bottomInset == 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdaptiveButton.primary(
              isFullWidth: true,
              onPressed: canSubmit
                  ? (state.isOffline ? _saveForLater : _analyze)
                  : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.isOffline
                        ? 'Save for later'
                        : (_error == null ? 'Run analysis' : 'Retry analysis'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 42,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        minHeight: 3,
                        value: (count / 50).clamp(0.0, 1.0),
                        color: colors.onAccent,
                        backgroundColor: colors.onAccent.withValues(
                          alpha: 0.24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${count.clamp(0, 50)}/50',
                    style: AppTypography.monoBadge.copyWith(
                      color: colors.onAccent,
                      fontSize: 11,
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
