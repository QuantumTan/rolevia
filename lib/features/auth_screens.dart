import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../core/brand.dart';
import '../core/config/app_config.dart';
import '../core/services/pdf_extractor_service.dart';
import '../data/repositories/auth_repository.dart';
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
import 'resume_parse_preview_screen.dart';

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

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
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

  void _finishOnboarding() {
    ref.read(appControllerProvider.notifier).completeOnboarding();
    context.go('/sign-in');
  }

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
                  onPressed: _finishOnboarding,
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
                              color: i == page
                                  ? colors.accent
                                  : colors.separator,
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
                            _finishOnboarding();
                          }
                        },
                        label: page == pages.length - 1
                            ? 'Get started'
                            : 'Next',
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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSignUp = false;
  bool _showForgotNote = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  bool _isLoading = false;
  bool _showVerificationNotice = false;
  String? _unverifiedEmail;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    final authRepo = ref.read(authRepositoryProvider);
    _authSub = authRepo.onAuthStateChange.listen((data) async {
      final user = data.session?.user;
      if (user != null && mounted) {
        final fullName =
            user.userMetadata?['full_name'] as String? ??
            user.userMetadata?['name'] as String?;
        final avatarUrl =
            user.userMetadata?['avatar_url'] as String? ??
            user.userMetadata?['picture'] as String?;
        await ref
            .read(appControllerProvider.notifier)
            .signIn(email: user.email, name: fullName, avatarUrl: avatarUrl);
        if (mounted) context.go('/match');
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    if (!AppConfig.configured) {
      setState(() {
        _errorMessage = 'Google sign-in is currently unavailable.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final started = await authRepo.signInWithGoogle();
      if (!started && mounted) {
        showGlassToast(context, 'Google sign-in was canceled.');
      }
    } catch (e) {
      if (mounted) {
        showGlassToast(context, 'Google sign-in failed. Please try again.');
        setState(() => _errorMessage = e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleEmailAuth() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    if (_isSignUp) {
      final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
      if (!emailRegex.hasMatch(email)) {
        setState(() => _errorMessage = 'Please enter a valid email address.');
        return;
      }

      if (password.length < 6) {
        setState(
          () => _errorMessage = 'Password must be at least 6 characters.',
        );
        return;
      }

      final confirm = _confirmPasswordController.text;
      if (password != confirm) {
        setState(() => _errorMessage = 'Passwords do not match.');
        return;
      }

      if (!AppConfig.configured) {
        _passwordController.clear();
        _confirmPasswordController.clear();
        setState(
          () =>
              _errorMessage = 'Account registration is currently unavailable.',
        );
        return;
      }
    } else {
      if (!AppConfig.configured) {
        _passwordController.clear();
        _confirmPasswordController.clear();
        setState(
          () => _errorMessage = 'Email sign-in is currently unavailable.',
        );
        return;
      }

      final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
      if (!emailRegex.hasMatch(email)) {
        setState(() => _errorMessage = 'Please enter a valid email address.');
        return;
      }

      if (password.length < 6) {
        setState(
          () => _errorMessage = 'Password must be at least 6 characters.',
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _showVerificationNotice = false;
    });

    final authRepo = ref.read(authRepositoryProvider);

    try {
      if (!_isSignUp) {
        final res = await authRepo.signInWithEmail(email, password);
        if (res.user != null) {
          if (res.user!.emailConfirmedAt == null && !res.user!.isAnonymous) {
            setState(() {
              _showVerificationNotice = true;
              _unverifiedEmail = email;
              _errorMessage = 'Your email is not verified yet. Check your inbox or tap here to resend the verification email.';
            });
            return;
          }
          await ref.read(appControllerProvider.notifier).signIn(email: email);
          if (mounted) context.go('/match');
          return;
        }
      } else {
        final signUpRes = await authRepo.signUpWithEmail(email, password);
        if (signUpRes.user != null) {
          if (signUpRes.session == null) {
            _showVerificationSentModal(email);
            return;
          } else {
            await ref.read(appControllerProvider.notifier).signIn(email: email);
            if (mounted) context.go('/match');
            return;
          }
        }
      }
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('email not confirmed')) {
        setState(() {
          _showVerificationNotice = true;
          _unverifiedEmail = email;
          _errorMessage = 'Your email is not verified yet. Check your inbox or tap here to resend the verification email.';
        });
        return;
      }

      if (!_isSignUp &&
          (msg.contains('invalid login credentials') ||
              msg.contains('user not found'))) {
        setState(
          () =>
              _errorMessage = 'Incorrect email or password. Please try again.',
        );
        return;
      }

      if (_isSignUp &&
          (e.message == AuthRepository.duplicateEmail ||
              e.code == 'user_already_exists' ||
              e.code == 'email_exists')) {
        setState(() => _errorMessage = AuthRepository.duplicateEmail);
        return;
      }

      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showVerificationSentModal(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Check your inbox'),
        content: Text(
          'Verification email sent! Please check your inbox at $email and click the confirmation link to activate your account.',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                await ref
                    .read(authRepositoryProvider)
                    .resendVerificationEmail(email);
                if (mounted) {
                  showGlassToast(context, 'Verification email resent.');
                }
              } catch (e) {
                if (mounted) {
                  showGlassToast(context, 'Could not resend email: $e');
                }
              }
            },
            child: const Text('Resend Link'),
          ),
          AdaptiveButton.primary(
            onPressed: () => Navigator.of(ctx).pop(),
            label: 'OK',
          ),
        ],
      ),
    );
  }

  Future<void> _handleGuestSignIn() async {
    if (AppConfig.configured) {
      try {
        final authRepo = ref.read(authRepositoryProvider);
        await authRepo.signInAnonymously();
      } catch (e) {
        debugPrint('Guest sign-in error: $e');
      }
    }
    if (mounted) context.push('/resume-setup');
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

                  // Auth Mode Segmented Control
                  Container(
                    height: 44,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colors.paleIndigoSurface,
                      borderRadius: BorderRadius.circular(AppRadius.capsule),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: PressableScale(
                            onPressed: () {
                              if (_isSignUp) {
                                AppMotion.selectionHaptic();
                                setState(() {
                                  _isSignUp = false;
                                  _errorMessage = null;
                                });
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: !_isSignUp
                                    ? colors.surface
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.capsule,
                                ),
                                boxShadow: !_isSignUp
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.06,
                                          ),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                'Sign In',
                                style: AppTypography.footnote.copyWith(
                                  color: !_isSignUp
                                      ? colors.labelPrimary
                                      : colors.labelSecondary,
                                  fontWeight: !_isSignUp
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: PressableScale(
                            onPressed: () {
                              if (!_isSignUp) {
                                AppMotion.selectionHaptic();
                                setState(() {
                                  _isSignUp = true;
                                  _errorMessage = null;
                                });
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _isSignUp
                                    ? colors.surface
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.capsule,
                                ),
                                boxShadow: _isSignUp
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.06,
                                          ),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                'Create Account',
                                style: AppTypography.footnote.copyWith(
                                  color: _isSignUp
                                      ? colors.labelPrimary
                                      : colors.labelSecondary,
                                  fontWeight: _isSignUp
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    _isSignUp ? 'Create account.' : 'Welcome back.',
                    style: AppTypography.largeTitle.copyWith(
                      color: colors.labelPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _isSignUp
                        ? 'Set up your career copilot and start matching jobs.'
                        : 'Sign in to save your matches and applications.',
                    style: AppTypography.body.copyWith(
                      color: colors.labelSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PressableScale(
                    onPressed: _isLoading ? null : _handleGoogleSignIn,
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
                    hintText: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AdaptiveTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    hintText: _isSignUp
                        ? 'At least 6 characters'
                        : 'Enter your password',
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                        color: colors.labelSecondary,
                      ),
                      tooltip: _obscurePassword
                          ? 'Show password'
                          : 'Hide password',
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  if (_isSignUp) ...[
                    const SizedBox(height: AppSpacing.sm),
                    AdaptiveTextField(
                      controller: _confirmPasswordController,
                      labelText: 'Confirm Password',
                      hintText: 'Re-enter your password',
                      obscureText: _obscureConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                          color: colors.labelSecondary,
                        ),
                        tooltip: _obscureConfirmPassword
                            ? 'Show password'
                            : 'Hide password',
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                  ],
                  if (_errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _errorMessage!,
                      style: AppTypography.footnote.copyWith(
                        color: colors.error,
                      ),
                    ),
                  ],
                  if (_showVerificationNotice && _unverifiedEmail != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Center(
                      child: AdaptiveButton.secondary(
                        onPressed: () async {
                          try {
                            await ref
                                .read(authRepositoryProvider)
                                .resendVerificationEmail(_unverifiedEmail!);
                            if (context.mounted) {
                              showGlassToast(
                                context,
                                'Verification email resent.',
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              showGlassToast(context, 'Could not resend: $e');
                            }
                          }
                        },
                        label: 'Resend Verification Email',
                      ),
                    ),
                  ],
                  if (!_isSignUp) ...[
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
                          'Password recovery is currently unavailable. Please try again later.',
                          style: AppTypography.caption.copyWith(
                            color: colors.labelSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  AdaptiveButton.primary(
                    isFullWidth: true,
                    onPressed: _isLoading ? null : _handleEmailAuth,
                    label: _isLoading
                        ? (_isSignUp ? 'Creating account…' : 'Signing in…')
                        : (_isSignUp ? 'Create account' : 'Sign in'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Center(
                    child: PressableScale(
                      onPressed: () {
                        AppMotion.selectionHaptic();
                        setState(() {
                          _isSignUp = !_isSignUp;
                          _errorMessage = null;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          _isSignUp
                              ? 'Already have an account? Sign in'
                              : "Don't have an account? Create one",
                          style: AppTypography.footnote.copyWith(
                            color: colors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Center(
                    child: PressableScale(
                      onPressed: _handleGuestSignIn,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          'Continue on this device',
                          style: AppTypography.footnote.copyWith(
                            color: colors.labelSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    AppConfig.configured
                        ? 'By continuing, you agree to local data processing and privacy terms.'
                        : 'Cloud services not configured. Continue on this device to use your offline workspace.',
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
  ExtractedResume? _extractedResume;

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

      final bytes = await file.readAsBytes();
      try {
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
          setState(() => _validating = false);
          return;
        }
        _extractedResume = reviewed;
      } catch (err) {
        setState(() {
          _validating = false;
          _selectedFileName = null;
          _validationError = 'PDF analysis failed: $err';
        });
        return;
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

  Future<void> _finishWithSelected() async {
    if (_selectedFileName == null) return;

    final newResume = ResumeVersion(
      id: const Uuid().v4(),
      title: _selectedFileName!.replaceAll('.pdf', ''),
      filename: _selectedFileName!,
      fileType: 'PDF',
      addedAt: DateTime.now(),
      isSample: false,
      atsStatus: _extractedResume?.report.status ?? 'Not analyzed',
      extractedText: _extractedResume?.sanitizedText ?? '',
      atsChecks: _extractedResume?.report.checks ?? const {},
    );

    ref.read(appControllerProvider.notifier).addResume(newResume);
    ref.read(appControllerProvider.notifier).completeOnboarding();
    await ref.read(appControllerProvider.notifier).signIn();
    if (mounted) {
      showGlassToast(context, 'Resume added to Vault');
      context.go('/match');
    }
  }

  Future<void> _skipForNow() async {
    ref.read(appControllerProvider.notifier).completeOnboarding();
    await ref.read(appControllerProvider.notifier).signIn();
    if (mounted) context.go('/match');
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
                    'No resume yet? You can add one in the Vault later.',
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
