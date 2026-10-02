import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/brand.dart';
import 'core/theme.dart';
import 'features/auth_screens.dart';
import 'features/detail_screens.dart';
import 'features/dashboard_screen.dart';
import 'features/discover_screen.dart';
import 'features/match_screen.dart';
import 'features/shell.dart';
import 'features/tracker_screen.dart';
import 'features/vault_screen.dart';
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
              semanticsLabel: 'Loading Job Matcher',
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
  void dispose() {
    router.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final state = ref.read(appControllerProvider);

    router = GoRouter(
      initialLocation: !state.onboardingComplete
          ? '/onboarding'
          : state.authenticated
          ? '/match'
          : '/sign-in',
      routes: [
        GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
        GoRoute(
          path: '/onboarding',
          builder: (_, _) => const OnboardingScreen(),
        ),
        GoRoute(path: '/sign-in', builder: (_, _) => const SignInScreen()),
        GoRoute(
          path: '/resume-setup',
          builder: (_, _) => const FirstResumeSetupScreen(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (_, _, shell) => AppShell(navigationShell: shell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/discover',
                  builder: (_, _) => const DiscoverScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(path: '/vault', builder: (_, _) => const VaultScreen()),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(path: '/match', builder: (_, _) => const MatchScreen()),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/tracker',
                  builder: (_, _) => const TrackerScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/dashboard',
                  builder: (_, _) => const DashboardScreen(),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/jobs/:id',
          builder: (_, s) => JobDetailScreen(id: s.pathParameters['id']!),
        ),
        GoRoute(
          path: '/matches/:id',
          builder: (_, s) => MatchResultScreen(id: s.pathParameters['id']!),
        ),
        GoRoute(
          path: '/rewrites',
          builder: (_, _) => const BulletRewritesScreen(),
        ),
        GoRoute(
          path: '/interview',
          builder: (_, _) => const MockInterviewScreen(),
        ),
        GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
        GoRoute(path: '/share', builder: (_, _) => const SocialShareScreen()),
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
      theme: appTheme(
        Brightness.light,
        reduceTransparency: profile.reduceTransparency,
      ),
      darkTheme: appTheme(
        Brightness.dark,
        reduceTransparency: profile.reduceTransparency,
      ),
      themeMode: mode,
      routerConfig: router,
    );
  }
}
