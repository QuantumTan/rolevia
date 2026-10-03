import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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
import '../core/widgets/adaptive_text_field.dart';
import '../core/widgets/adaptive_toast.dart';
import '../core/widgets/pressable.dart';
import '../core/widgets/product_illustration.dart';
import '../models/models.dart';
import '../state/app_state.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      final state = ref.read(appControllerProvider);
      if (!state.onboardingComplete) {
        context.go('/onboarding');
      } else if (state.authenticated) {
        context.go('/match');
      } else {
        context.go('/sign-in');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
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
              child: Icon(Icons.bolt_rounded, size: 40, color: colors.accent),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              Brand.appName,
              style: AppTypography.largeTitle.copyWith(
                color: colors.labelPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  int page = 0;

  static const pages = [
    (
      Icons.content_paste_rounded,
      'Paste any job post',
      'Bring in a role from any job board or social post.',
    ),
    (
      Icons.troubleshoot_rounded,
      'See your match and gaps',
      'Know which skills match and what keywords are missing.',
    ),
    (
      Icons.edit_note_rounded,
      'Rewrite your bullets and track applications',
      'Improve your resume, then keep every application organized.',
    ),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16, top: 8),
                child: AdaptiveButton.tertiary(
                  onPressed: () => context.go('/sign-in'),
                  label: 'Skip',
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: pages.length,
                onPageChanged: (v) {
                  AppMotion.selectionHaptic();
                  setState(() => page = v);
                },
                itemBuilder: (_, i) {
                  final p = pages[i];
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ProductIllustration(
                                [
                                  'onboarding_paste',
                                  'onboarding_match',
                                  'onboarding_track',
                                ][i],
                                height: MediaQuery.sizeOf(context).height < 700
                                    ? 100
                                    : 180,
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              Text(
                                p.$2,
                                style: AppTypography.largeTitle.copyWith(
                                  color: colors.labelPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                p.$3,
                                style: AppTypography.body.copyWith(
                                  color: colors.labelSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          pages.length,
                          (i) => AnimatedContainer(
                            duration: MediaQuery.disableAnimationsOf(context)
                                ? Duration.zero
                                : const Duration(milliseconds: 220),
                            curve: AppMotion.springCurve,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: i == page ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color:
                                  i == page ? colors.accent : colors.separator,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AdaptiveButton.primary(
                        isFullWidth: true,
                        onPressed: () {
                          if (page < pages.length - 1) {
                            controller.nextPage(
                              duration: MediaQuery.disableAnimationsOf(context)
                                  ? Duration.zero
                                  : const Duration(milliseconds: 260),
                              curve: AppMotion.springCurve,
                            );
                          } else {
                            context.go('/sign-in');
                          }
                        },
                        label: page == pages.length - 1 ? 'Get started' : 'Next',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailController = TextEditingController(text: 'alex@example.com');
  final _passwordController = TextEditingController();
  bool _connectingGoogle = false;
  bool _showForgotNote = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _connectingGoogle = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 750));
    if (!mounted) return;

    ref.read(appControllerProvider.notifier).completeOnboarding();
    ref.read(appControllerProvider.notifier).signIn();
    context.go('/match');
  }

  void _handleEmailSignIn() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _errorMessage = 'Please enter a valid email format.');
      return;
    }
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Please enter a password.');
      return;
    }

    ref.read(appControllerProvider.notifier).completeOnboarding();
    ref.read(appControllerProvider.notifier).signIn();
    context.go('/match');
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: colors.paleIndigoSurface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.bolt_rounded,
                        size: 34,
                        color: colors.accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    Brand.appName,
                    style: AppTypography.title2.copyWith(
                      color: colors.labelSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Welcome back.',
                    style: AppTypography.largeTitle.copyWith(
                      color: colors.labelPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Sign in to save your matches and applications.',
                    style: AppTypography.body.copyWith(
                      color: colors.labelSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PressableScale(
                    onPressed: _connectingGoogle ? null : _handleGoogleSignIn,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.capsule),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_connectingGoogle) ...[
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  colors.accent,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Connecting...',
                              style: AppTypography.body.copyWith(
                                color: colors.labelPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ] else ...[
                            Icon(
                              Icons.login_rounded,
                              size: 28,
                              color: colors.accent,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Continue with Google',
                              style: AppTypography.body.copyWith(
                                color: colors.labelPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(child: Divider(color: colors.separator)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'or',
                          style: AppTypography.footnote.copyWith(
                            color: colors.labelTertiary,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: colors.separator)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AdaptiveTextField(
                    controller: _emailController,
                    labelText: 'Email',
                    hintText: 'alex@example.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AdaptiveTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    obscureText: true,
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _errorMessage!,
                      style: AppTypography.footnote.copyWith(
                        color: colors.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  Align(
                    alignment: Alignment.centerRight,
                    child: PressableScale(
                      onPressed: () {
                        setState(() => _showForgotNote = !_showForgotNote);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'Forgot password?',
                          style: AppTypography.footnote.copyWith(
                            color: colors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_showForgotNote) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        'Password recovery is not connected in this prototype session. Use any password or Continue with Google.',
                        style: AppTypography.caption.copyWith(
                          color: colors.labelSecondary,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  AdaptiveButton.primary(
                    isFullWidth: true,
                    onPressed: _handleEmailSignIn,
                    label: 'Sign in',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Center(
                    child: PressableScale(
                      onPressed: () => context.push('/resume-setup'),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          'New to Job Matcher? Create account',
                          style: AppTypography.footnote.copyWith(
                            color: colors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Interactive prototype · Sign-in is simulated.\nPlease don\'t use your real password.',
                    textAlign: TextAlign.center,
                    style: AppTypography.caption.copyWith(
                      color: colors.labelTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FirstResumeSetupScreen extends ConsumerStatefulWidget {
  const FirstResumeSetupScreen({super.key});

  @override
  ConsumerState<FirstResumeSetupScreen> createState() =>
      _FirstResumeSetupScreenState();
}

class _FirstResumeSetupScreenState
    extends ConsumerState<FirstResumeSetupScreen> {
  bool _validating = false;
  String? _selectedFileName;
  String? _validationError;

  Future<void> _pickFile() async {
    setState(() {
      _validating = true;
      _validationError = null;
    });

    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );

      if (file == null) {
        setState(() => _validating = false);
        return;
      }

      final size = (await file.length()) ?? file.lengthSync() ?? 0;

      if (size > Brand.maxResumeBytes) {
        setState(() {
          _validating = false;
          _selectedFileName = null;
          _validationError =
              'File exceeds 10 MB limit. Please select a smaller PDF.';
        });
        return;
      }

      final ext = (file.extension ?? '').toLowerCase();
      if (ext != 'pdf') {
        setState(() {
          _validating = false;
          _selectedFileName = null;
          _validationError = 'Only PDF files are supported.';
        });
        return;
      }

      // Check %PDF- signature if bytes are available
      final bytes = await file.readAsBytes();
      if (bytes.length >= 5) {
        final header = utf8.decode(bytes.sublist(0, 5), allowMalformed: true);
        if (!header.startsWith('%PDF-')) {
          setState(() {
            _validating = false;
            _selectedFileName = null;
            _validationError =
                'Invalid PDF format: file lacks %PDF- signature.';
          });
          return;
        }
      }

      setState(() {
        _validating = false;
        _selectedFileName = file.name;
        _validationError = null;
      });
    } catch (e) {
      setState(() {
        _validating = false;
        _validationError = 'Could not read file: $e';
      });
    }
  }

  void _finishWithSelected() {
    if (_selectedFileName == null) return;

    final newResume = ResumeVersion(
      id: 'r_${DateTime.now().microsecondsSinceEpoch}',
      title: _selectedFileName!.replaceAll('.pdf', ''),
      filename: _selectedFileName!,
      fileType: 'PDF',
      addedAt: DateTime.now(),
      isSample: false,
      atsStatus: 'Not analyzed',
    );

    ref.read(appControllerProvider.notifier).addResume(newResume);
    ref.read(appControllerProvider.notifier).completeOnboarding();
    ref.read(appControllerProvider.notifier).signIn();
    showGlassToast(context, 'Resume added to Vault');
    context.go('/match');
  }

  void _skipForNow() {
    ref.read(appControllerProvider.notifier).completeOnboarding();
    ref.read(appControllerProvider.notifier).signIn();
    context.go('/match');
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'ONE LAST STEP',
                style: AppTypography.caption.copyWith(
                  color: colors.accent,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Add your resume',
                style: AppTypography.largeTitle.copyWith(
                  color: colors.labelPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Keep your resume ready for matching. A simple, one-column PDF helps your experience stand out.',
                style: AppTypography.body.copyWith(
                  color: colors.labelSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AdaptiveCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: colors.paleIndigoSurface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.description_rounded,
                        size: 30,
                        color: colors.accent,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _selectedFileName ?? 'Start with your latest resume',
                      style: AppTypography.headline.copyWith(
                        color: colors.labelPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'PDF only · Up to 10 MB · Use selectable text, not a scan.',
                      style: AppTypography.caption.copyWith(
                        color: colors.labelTertiary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AdaptiveButton.secondary(
                      onPressed: _validating ? null : _pickFile,
                      label: _validating
                          ? 'Checking PDF…'
                          : (_selectedFileName == null
                                ? 'Choose a PDF'
                                : 'Change PDF'),
                    ),
                    if (_validationError != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _validationError!,
                        style: AppTypography.caption.copyWith(
                          color: colors.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AdaptiveButton.primary(
                isFullWidth: true,
                onPressed: _selectedFileName != null
                    ? _finishWithSelected
                    : null,
                label: 'Continue',
              ),
              const SizedBox(height: AppSpacing.sm),
              AdaptiveButton.tertiary(
                isFullWidth: true,
                onPressed: _skipForNow,
                label: 'Skip for now',
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No resume yet? Skip this step to explore with Alex’s sample resumes. You can add yours in the Vault later.',
                style: AppTypography.caption.copyWith(
                  color: colors.labelTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);
  }
}
