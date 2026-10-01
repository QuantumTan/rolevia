import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/brand.dart';
import 'core/theme.dart';
import 'features/auth_screens.dart';
import 'features/detail_screens.dart';
import 'features/shell.dart';
import 'models/models.dart';
import 'state/app_state.dart';

class AppBootstrap extends ConsumerWidget {
  const AppBootstrap({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    if (!state.ready) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: appTheme(Brightness.light),
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              semanticsLabel: 'Loading demo data',
            ),
          ),
        ),
      );
    }
    return const _ReadyApp();
  }
}

class _ReadyApp extends ConsumerStatefulWidget {
  const _ReadyApp();
  @override
  ConsumerState<_ReadyApp> createState() => _ReadyAppState();
}

class _ReadyAppState extends ConsumerState<_ReadyApp> {
  late final GoRouter router;
  @override
  void initState() {
    super.initState();
    final state = ref.read(appControllerProvider);
    router = GoRouter(
      initialLocation: !state.onboardingComplete
          ? '/onboarding'
          : state.authenticated
          ? '/discover'
          : '/entry',
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (_, _) => const OnboardingScreen(),
        ),
        GoRoute(path: '/entry', builder: (_, _) => const EntryScreen()),
        GoRoute(
          path: '/sign-in',
          builder: (_, _) => const AuthFormScreen(signUp: false),
        ),
        GoRoute(
          path: '/sign-up',
          builder: (_, _) => const AuthFormScreen(signUp: true),
        ),
        GoRoute(
          path: '/forgot',
          builder: (_, _) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/discover',
          builder: (_, _) => const AppShell(initialIndex: 0),
        ),
        GoRoute(
          path: '/vault',
          builder: (_, _) => const AppShell(initialIndex: 1),
        ),
        GoRoute(
          path: '/match',
          builder: (_, _) => const AppShell(initialIndex: 2),
        ),
        GoRoute(
          path: '/tracker',
          builder: (_, _) => const AppShell(initialIndex: 3),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (_, _) => const AppShell(initialIndex: 4),
        ),
        GoRoute(
          path: '/jobs/:id',
          builder: (_, s) => JobDetailScreen(id: s.pathParameters['id']!),
        ),
        GoRoute(
          path: '/resumes/:id',
          builder: (_, s) => ResumeDetailScreen(id: s.pathParameters['id']!),
        ),
        GoRoute(
          path: '/matches/:id',
          builder: (_, s) => MatchResultScreen(id: s.pathParameters['id']!),
        ),
        GoRoute(
          path: '/applications/:id',
          builder: (_, s) =>
              ApplicationDetailScreen(id: s.pathParameters['id']!),
        ),
        GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(appControllerProvider.select((s) => s.profile));
    final mode = switch (profile.theme) {
      AppTheme.light => ThemeMode.light,
      AppTheme.dark => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    return MaterialApp.router(
      title: Brand.appName,
      debugShowCheckedModeBanner: false,
      theme: appTheme(Brightness.light),
      darkTheme: appTheme(Brightness.dark),
      themeMode: mode,
      routerConfig: router,
    );
  }
}
