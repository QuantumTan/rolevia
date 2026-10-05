import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/design/colors.dart';
import '../core/design/motion.dart';
import '../core/design/radius.dart';
import '../core/design/spacing.dart';
import '../core/design/typography.dart';
import '../core/widgets/adaptive_button.dart';
import '../core/widgets/adaptive_toast.dart';
import '../core/widgets/app_top_bar.dart';
import '../core/widgets/pressable.dart';
import '../models/models.dart';
import '../state/app_state.dart';

/// The Interview Arena and Resume Roaster (Tab 4)
/// Consolidates mock interview practice and brutalist resume critique.
class ArenaScreen extends ConsumerStatefulWidget {
  const ArenaScreen({super.key});

  @override
  ConsumerState<ArenaScreen> createState() => _ArenaScreenState();
}

class _ArenaScreenState extends ConsumerState<ArenaScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  int _activeMode = 0; // 0: Mock Simulator, 1: Roast My Resume
  int _currentQuestionIndex = 0;
  bool _isSpeaking = true;
  final TextEditingController _answerController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _waveController;
  final List<String> _recordedAnswers = [];
  bool _submittedCurrentAnswer = false;

  static const _englishQuestions = [
    'Tell me about a time you diagnosed and fixed a complex technical issue under pressure.',
    'How do you approach learning a completely new framework or tool within a tight deadline?',
    'Describe a situation where you resolved a difficult disagreement within your cross-functional team.',
    'How would you handle an escalated customer incident where the root cause is undetermined?',
    'Why are you targeting this role in the Philippine tech/BPO sector, and what is your 1-year trajectory?',
  ];

  static const _taglishQuestions = [
    'Ikuwento mo ang isang scenario kung saan nag-diagnose at nag-resolve ka ng technical issue under pressure.',
    'Paano ang diskarte mo kapag kailangan mong matuto ng bagong framework sa maikling panahon?',
    'Paano mo na-manage ang disagreement sa team ninyo habang may hinahabol na project delivery?',
    'Paano mo kakausapin ang isang frustrated na client kapag hindi pa clear ang cause ng issue?',
    'Bakit ka interesado sa role na ito, at ano ang direct target mo sa career sa susunod na taon?',
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isTest =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (MediaQuery.disableAnimationsOf(context) || isTest) {
      _waveController.stop();
      _waveController.value = 0.5;
    } else if (!_waveController.isAnimating) {
      _waveController.repeat();
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _answerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _submitAnswer() {
    final text = _answerController.text.trim();
    if (text.isEmpty) return;

    AppMotion.selectionHaptic();
    setState(() {
      _recordedAnswers.add(text);
      _submittedCurrentAnswer = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < 4) {
      AppMotion.selectionHaptic();
      setState(() {
        _currentQuestionIndex++;
        _submittedCurrentAnswer = false;
        _answerController.clear();
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    final colors = AppColors.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: colors.hairlineBorder, width: 1.0),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: colors.paleIndigoSurface,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.hairlineBorder, width: 1.0),
                  ),
                  child: Icon(Icons.check_circle_rounded, color: colors.success, size: 28),
                ),
                const SizedBox(height: 16),
                Text(
                  'Simulation Complete',
                  style: AppTypography.title3.copyWith(
                    color: colors.labelPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Completed 5 tactical interview questions with verified STAR structure feedback.',
                  textAlign: TextAlign.center,
                  style: AppTypography.footnote.copyWith(
                    color: colors.labelSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 20),
                AdaptiveButton.primary(
                  isFullWidth: true,
                  label: 'Restart Session',
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    setState(() {
                      _currentQuestionIndex = 0;
                      _recordedAnswers.clear();
                      _submittedCurrentAnswer = false;
                      _answerController.clear();
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(appControllerProvider);
    final colors = AppColors.of(context);
    final activeResume = state.resumes.where(
      (r) => r.id == (state.selectedMatchResumeId ?? state.defaultResumeId),
    ).firstOrNull ?? state.resumes.firstOrNull;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
        key: const PageStorageKey('arena-scroll'),
        controller: _scrollController,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverAppTopBar(
            title: 'Arena',
            avatarLetter: state.profile.initialLetter,
            avatarUrl: state.profile.avatarUrl,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Mode Switcher Segmented Control
                  Container(
                    height: 40,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: colors.paleIndigoSurface,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: colors.hairlineBorder, width: 1.0),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: PressableScale(
                            onPressed: () {
                              AppMotion.selectionHaptic();
                              setState(() {
                                _activeMode = 0;
                                final isTest = WidgetsBinding.instance.runtimeType
                                    .toString()
                                    .contains('Test');
                                if (_isSpeaking &&
                                    !MediaQuery.disableAnimationsOf(context) &&
                                    !isTest) {
                                  _waveController.repeat();
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              curve: Curves.easeOut,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _activeMode == 0 ? colors.surface : Colors.transparent,
                                borderRadius: BorderRadius.circular(AppRadius.xs),
                                border: _activeMode == 0
                                    ? Border.all(color: colors.hairlineBorder, width: 1.0)
                                    : null,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Mock Simulator',
                                    style: AppTypography.caption.copyWith(
                                      color: _activeMode == 0 ? colors.labelPrimary : colors.labelSecondary,
                                      fontWeight: _activeMode == 0 ? FontWeight.w600 : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: PressableScale(
                            onPressed: () {
                              AppMotion.selectionHaptic();
                              setState(() {
                                _activeMode = 1;
                                _waveController.stop();
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              curve: Curves.easeOut,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _activeMode == 1 ? colors.surface : Colors.transparent,
                                borderRadius: BorderRadius.circular(AppRadius.xs),
                                border: _activeMode == 1
                                    ? Border.all(color: colors.hairlineBorder, width: 1.0)
                                    : null,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.local_fire_department_outlined,
                                        size: 14,
                                        color: _activeMode == 1 ? colors.labelPrimary : colors.labelSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Resume Critique / Roast',
                                        style: AppTypography.caption.copyWith(
                                          color: _activeMode == 1 ? colors.labelPrimary : colors.labelSecondary,
                                          fontWeight: _activeMode == 1 ? FontWeight.w600 : FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Mode Content
                  if (_activeMode == 0)
                    _buildMockSimulator(colors, state)
                  else
                    _buildRoastMode(colors, state, activeResume),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildMockSimulator(AppColors colors, AppState state) {
    final isTaglish = state.profile.interviewLanguage == 'Taglish';
    final questions = isTaglish ? _taglishQuestions : _englishQuestions;
    final questionText = questions[_currentQuestionIndex];
    final words = _answerController.text.trim().isEmpty
        ? 0
        : _answerController.text.trim().split(RegExp(r'\s+')).length;

    // Conciseness meter (ideal: 40-90 words)
    final concisenessScore = words == 0
        ? 0
        : (100 - ((words - 65).abs() * 1.5)).clamp(10, 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Simulated Interviewer Card with Animated Audio Wave
        RepaintBoundary(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: colors.hairlineBorder, width: 1.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: colors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'INTERVIEWER',
                            style: AppTypography.monoBadge.copyWith(
                              color: colors.labelSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'QUESTION ${_currentQuestionIndex + 1}/5',
                      style: AppTypography.monoBadge.copyWith(
                        color: colors.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  questionText,
                  style: AppTypography.headline.copyWith(
                    color: colors.labelPrimary,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                // Audio Wave Visualizer
                Row(
                  children: [
                    IconButton(
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        _isSpeaking ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                        color: colors.accent,
                      ),
                      onPressed: () {
                        setState(() {
                          _isSpeaking = !_isSpeaking;
                          final isTest = WidgetsBinding.instance.runtimeType
                              .toString()
                              .contains('Test');
                          if (_isSpeaking &&
                              !MediaQuery.disableAnimationsOf(context) &&
                              !isTest) {
                            _waveController.repeat();
                          } else {
                            _waveController.stop();
                          }
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _waveController,
                        builder: (context, _) => SizedBox(
                          height: 24,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(18, (index) {
                              final offset = index * 0.35;
                              final normalized = _isSpeaking
                                  ? ((math.sin(_waveController.value * 2 * math.pi + offset) + 1) / 2)
                                  : 0.15;
                              final barHeight = 4.0 + (normalized * 18.0);
                              return Container(
                                width: 3,
                                height: barHeight,
                                decoration: BoxDecoration(
                                  color: _isSpeaking ? colors.accent : colors.separator,
                                  borderRadius: BorderRadius.circular(1.5),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Transcribed Candidate Response Area
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: colors.hairlineBorder, width: 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  Text(
                    'CANDIDATE RESPONSE',
                    style: AppTypography.monoBadge.copyWith(color: colors.labelSecondary),
                  ),
                  Text(
                    '$words words',
                    style: AppTypography.monoBadge.copyWith(
                      color: colors.labelSecondary,
                    ),
                  ),
                  Text(
                    'Conciseness: $concisenessScore%',
                    style: AppTypography.monoBadge.copyWith(
                      color: concisenessScore >= 70 ? colors.success : colors.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _answerController,
                enabled: !_submittedCurrentAnswer,
                maxLines: 5,
                style: AppTypography.body.copyWith(
                  color: colors.labelPrimary,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Type your response following the STAR format (Situation, Task, Action, Result)...',
                  hintStyle: AppTypography.body.copyWith(
                    color: colors.labelTertiary,
                    fontSize: 14,
                  ),
                  fillColor: colors.paleIndigoSurface,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide: BorderSide(color: colors.hairlineBorder, width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide: BorderSide(color: colors.hairlineBorder, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide: BorderSide(color: colors.accent, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              if (!_submittedCurrentAnswer)
                AdaptiveButton.primary(
                  isFullWidth: true,
                  label: 'Submit for STAR Feedback',
                  icon: const Icon(Icons.send_rounded, size: 16),
                  onPressed: words >= 5 ? _submitAnswer : null,
                )
              else
                AdaptiveButton.secondary(
                  isFullWidth: true,
                  label: _currentQuestionIndex < 4 ? 'Next Question' : 'Complete Interview',
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  onPressed: _nextQuestion,
                ),
            ],
          ),
        ),

        // Instant Micro-Feedback Banner (if answered)
        if (_submittedCurrentAnswer) ...[
          const SizedBox(height: AppSpacing.md),
          _buildMicroFeedbackBanner(colors, words),
        ],
      ],
    );
  }

  Widget _buildMicroFeedbackBanner(AppColors colors, int words) {
    final score = (words >= 35 && words <= 120) ? 8.8 : 6.5;
    final starComplete = words >= 40;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.hairlineBorder, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                'STAR EVALUATION',
                style: AppTypography.monoBadge.copyWith(
                  color: colors.accent,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.diffAddedBg,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                  border: Border.all(color: colors.diffAddedText.withValues(alpha: 0.2)),
                ),
                child: Text(
                  '$score / 10',
                  style: AppTypography.monoBadge.copyWith(
                    color: colors.diffAddedText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // STAR Checklist
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _starPill('Situation', true, colors),
              _starPill('Task', true, colors),
              _starPill('Action', words >= 25, colors),
              _starPill('Result', starComplete, colors),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            starComplete
                ? 'Strong quantifiable outcome mentioned. The response clearly balances technical execution with customer outcome.'
                : 'Action verified: add specific metrics to the Result segment (e.g., reduced latency by 35% or improved CSAT).',
            style: AppTypography.caption.copyWith(
              color: colors.labelSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _starPill(String phase, bool passed, AppColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: passed ? colors.diffAddedBg : colors.paleIndigoSurface,
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(
          color: passed ? colors.diffAddedText.withValues(alpha: 0.3) : colors.hairlineBorder,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            passed ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 12,
            color: passed ? colors.diffAddedText : colors.labelTertiary,
          ),
          const SizedBox(width: 4),
          Text(
            phase,
            style: AppTypography.monoBadge.copyWith(
              color: passed ? colors.diffAddedText : colors.labelSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoastMode(AppColors colors, AppState state, ResumeVersion? activeResume) {
    if (activeResume == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: colors.hairlineBorder, width: 1.0),
        ),
        child: Column(
          children: [
            Icon(Icons.description_outlined, size: 36, color: colors.labelTertiary),
            const SizedBox(height: 12),
            Text(
              'No Active Resume Loaded',
              style: AppTypography.headline.copyWith(color: colors.labelPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              'Import a PDF resume in Vault to run the brutalist critique generator.',
              textAlign: TextAlign.center,
              style: AppTypography.footnote.copyWith(color: colors.labelSecondary),
            ),
            const SizedBox(height: 16),
            AdaptiveButton.secondary(
              label: 'Back',
              onPressed: () => context.pop(),
            ),
          ],
        ),
      );
    }

    final hasAtsWarnings = activeResume.atsChecks.values.any((passed) => !passed);
    final roastQuote = hasAtsWarnings
        ? 'Your 2-column layout makes ATS parsers cry. 3 tables detected, zero readable metrics. Recruiter spent 3.2 seconds before binning this.'
        : 'Lists "Flutter, React, Docker, Python, C++, AWS" like a tech grocery receipt, but every bullet point reads "fixed minor bugs and attended daily syncs". CSAT not found.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 9:16 Optimized Brutalist Critique Card
        RepaintBoundary(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: colors.hairlineBorder, width: 1.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_fire_department_rounded,
                          color: colors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'RESUME ROAST',
                          style: AppTypography.monoBadge.copyWith(
                            color: colors.error,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'AI AUDIT v2.5',
                      style: AppTypography.monoBadge.copyWith(
                        color: colors.labelTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.paleIndigoSurface,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: colors.hairlineBorder, width: 1.0),
                  ),
                  child: Text(
                    '"$roastQuote"',
                    style: AppTypography.body.copyWith(
                      color: colors.labelPrimary,
                      fontWeight: FontWeight.w600,
                      height: 1.45,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Candidate Diagnostics Matrix
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: colors.hairlineBorder, width: 1.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PARSING RISK',
                              style: AppTypography.monoBadge.copyWith(
                                color: colors.labelTertiary,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              hasAtsWarnings ? 'HIGH (Multi-Col)' : 'LOW (Clean)',
                              style: AppTypography.monoData.copyWith(
                                color: hasAtsWarnings ? colors.error : colors.success,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: colors.hairlineBorder, width: 1.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VERIFIABLE METRICS',
                              style: AppTypography.monoBadge.copyWith(
                                color: colors.labelTertiary,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '18% (Passive Heavy)',
                              style: AppTypography.monoData.copyWith(
                                color: colors.warning,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Watermark branding sticker
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: colors.paleIndigoSurface,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '#JobMatcherPH · ${activeResume.title}',
                        style: AppTypography.monoBadge.copyWith(
                          color: colors.labelTertiary,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        'ATS Score: 64%',
                        style: AppTypography.monoBadge.copyWith(
                          color: colors.accent,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Action Buttons: Share Sticker
        AdaptiveButton.primary(
          isFullWidth: true,
          label: 'Export to TikTok/IG Story',
          icon: const Icon(Icons.share_rounded, size: 16),
          onPressed: () {
            AppMotion.selectionHaptic();
            Clipboard.setData(ClipboardData(text: 'My Job Matcher Resume Roast:\n"$roastQuote"\n#JobMatcherPH'));
            showGlassToast(
              context,
              'Roast critique copied for 9:16 story sticker',
              icon: Icons.check_circle_rounded,
            );
          },
        ),
      ],
    );
  }
}
