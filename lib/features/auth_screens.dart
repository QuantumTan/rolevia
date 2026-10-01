import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/brand.dart';
import '../state/app_state.dart';

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
      Icons.travel_explore,
      'Find work worth reading',
      'Search a focused set of software and IT roles, then save the ones that fit.',
    ),
    (
      Icons.compare_arrows,
      'See where your resume fits',
      'Run clearly labeled demo comparisons before a future AI service is connected.',
    ),
    (
      Icons.view_kanban_outlined,
      'Keep every application moving',
      'Track stages, notes, and follow-up dates from one calm workspace.',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.go('/entry'),
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: pages.length,
                onPageChanged: (v) => setState(() => page = v),
                itemBuilder: (_, i) {
                  final p = pages[i];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 104,
                          height: 104,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primaryContainer,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Icon(
                            p.$1,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          p.$2,
                          style: Theme.of(context).textTheme.displaySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          p.$3,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      children: List.generate(
                        pages.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: i == page ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == page
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: () => page < 2
                        ? controller.nextPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                          )
                        : context.go('/entry'),
                    child: Text(page == 2 ? 'Continue to demo' : 'Next'),
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

class EntryScreen extends ConsumerWidget {
  const EntryScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.work_outline,
                    size: 46,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 26),
                  Text(
                    Brand.appName,
                    style: Theme.of(context).textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'A private, local demo for job discovery, resume organization, and application tracking.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 34),
                  FilledButton(
                    onPressed: () {
                      ref
                          .read(appControllerProvider.notifier)
                          .completeOnboarding();
                      ref.read(appControllerProvider.notifier).signIn();
                      context.go('/discover');
                    },
                    child: const Text('Open demo workspace'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context.push('/sign-in'),
                    child: const Text('Sign in to demo'),
                  ),
                  TextButton(
                    onPressed: () => context.push('/sign-up'),
                    child: const Text('Create a demo profile'),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Demo only. Credentials are never sent or stored, and no real account is created.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
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

class AuthFormScreen extends ConsumerStatefulWidget {
  const AuthFormScreen({super.key, required this.signUp});
  final bool signUp;
  @override
  ConsumerState<AuthFormScreen> createState() => _AuthFormScreenState();
}

class _AuthFormScreenState extends ConsumerState<AuthFormScreen> {
  final formKey = GlobalKey<FormState>();
  bool hidden = true;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.signUp ? 'Create demo profile' : 'Demo sign in'),
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.signUp ? 'Set up your local demo' : 'Welcome back',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 24),
              if (widget.signUp) ...[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) =>
                      (v ?? '').trim().length < 2 ? 'Enter your name.' : null,
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => !(v ?? '').contains('@')
                    ? 'Enter a valid email address.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                obscureText: hidden,
                decoration: InputDecoration(
                  labelText: 'Password',
                  helperText: 'Not saved in this demo',
                  suffixIcon: IconButton(
                    tooltip: hidden ? 'Show password' : 'Hide password',
                    onPressed: () => setState(() => hidden = !hidden),
                    icon: Icon(
                      hidden
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: (v) =>
                    (v ?? '').length < 8 ? 'Use at least 8 characters.' : null,
              ),
              if (!widget.signUp)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot'),
                    child: const Text('Forgot password?'),
                  ),
                ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    ref
                        .read(appControllerProvider.notifier)
                        .completeOnboarding();
                    ref.read(appControllerProvider.notifier).signIn();
                    context.go('/discover');
                  }
                },
                child: Text(
                  widget.signUp ? 'Create local profile' : 'Enter demo',
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool sent = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Reset demo password')),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: sent
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mark_email_read_outlined, size: 52),
                  SizedBox(height: 16),
                  Text(
                    'Demo reset confirmed. No email was sent.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const TextField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => setState(() => sent = true),
                  child: const Text('Simulate reset'),
                ),
              ],
            ),
    ),
  );
}
