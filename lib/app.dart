import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/brand.dart';
import 'core/theme.dart';
import 'core/widgets/branch_container.dart';
import 'core/widgets/app_page.dart';
import 'features/arena_screen.dart';
import 'features/auth_screens.dart';
import 'features/career_preferences_screen.dart';
import 'features/dashboard_screen.dart';
import 'features/detail_screens.dart';
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
        themeAnimationDuration: Duration.zero,
        theme: appTheme(Brightness.light),
        builder: (_, _) => const Scaffold(
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
          ? (state.profile.defaultTab == 'discover' ||
                  state.profile.defaultTab == 'tracker' ||
                  state.profile.defaultTab == 'vault' ||
                  state.profile.defaultTab == 'dashboard'
              ? '/${state.profile.defaultTab}'
              : '/discover')
          : '/sign-in',
      redirect: (BuildContext context, GoRouterState routerState) {
        final current = ref.read(appControllerProvider);
        final loc = routerState.matchedLocation;
        final isOnboarded = current.onboardingComplete;
        final isAuth = current.authenticated;

        // Allow public/auth routes
        final isAuthRoute = loc == '/sign-in' ||
            loc == '/onboarding' ||
            loc == '/splash' ||
            loc == '/resume-setup' ||
            loc == '/preferences-setup';

        // If onboarding is incomplete, keep the user in onboarding/setup
        if (!isOnboarded && !isAuthRoute) {
          return '/onboarding';
        }

        if (!isAuth && !isAuthRoute) {
          return '/sign-in';
        }

        if (isAuth && (loc == '/sign-in' || loc == '/onboarding')) {
          final defaultTab = current.profile.defaultTab.isNotEmpty
              ? (current.profile.defaultTab == 'match'
                  ? 'vault'
                  : current.profile.defaultTab == 'arena'
                      ? 'discover'
                      : current.profile.defaultTab)
              : 'discover';
          return '/$defaultTab';
        }

        return null;
      },
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
        GoRoute(
          path: '/preferences-setup',
          builder: (_, _) => const CareerPreferencesScreen(isOnboarding: true),
        ),
        GoRoute(
          path: '/preferences',
          builder: (_, _) => const CareerPreferencesScreen(),
        ),
        StatefulShellRoute(
          navigatorContainerBuilder: (_, shell, children) =>
              BranchContainer(index: shell.currentIndex, children: children),
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
                GoRoute(
                  path: '/tracker',
                  builder: (_, _) => const TrackerScreen(),
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
                GoRoute(
                  path: '/dashboard',
                  builder: (_, _) => const DashboardScreen(),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/arena',
          pageBuilder: (context, s) =>
              appPage(context, s, const ArenaScreen()),
        ),
        GoRoute(
          path: '/match',
          pageBuilder: (context, s) =>
              appPage(context, s, const MatchScreen()),
        ),
        GoRoute(
          path: '/jobs/:id',
          pageBuilder: (context, s) =>
              appPage(context, s, JobDetailScreen(id: s.pathParameters['id']!)),
        ),
        GoRoute(
          path: '/matches/:id',
          pageBuilder: (context, s) => appPage(
            context,
            s,
            MatchResultScreen(id: s.pathParameters['id']!),
          ),
        ),
        GoRoute(
          path: '/rewrites',
          pageBuilder: (context, s) =>
              appPage(context, s, const BulletRewritesScreen()),
        ),
        GoRoute(
          path: '/interview',
          redirect: (_, _) => '/arena',
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, s) =>
              appPage(context, s, const ProfileScreen()),
        ),
        GoRoute(path: '/share', builder: (_, _) => const SocialShareScreen()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(
      appControllerProvider.select((s) => s.authenticated),
      (previous, next) {
        if (previous != null && previous != next) {
          if (next) {
            final defaultTab =
                ref.read(appControllerProvider).profile.defaultTab;
            router.go(
              defaultTab.isNotEmpty && defaultTab != 'match'
                  ? '/$defaultTab'
                  : '/discover',
            );
          } else {
            router.go('/sign-in');
          }
        }
      },
    );

    final profile = ref.watch(appControllerProvider.select((s) => s.profile));
    AppMotion.hapticsEnabled = profile.hapticFeedback;
    final mode = switch (profile.theme) {
      AppTheme.light => ThemeMode.light,
      AppTheme.dark => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    return MaterialApp.router(
      title: Brand.appName,
      debugShowCheckedModeBanner: false,
      themeAnimationDuration: Duration.zero,
      theme: appTheme(
        Brightness.light,
        reduceTransparency: profile.reduceTransparency,
        accentColor: profile.accentColor,
      ),
      darkTheme: appTheme(
        Brightness.dark,
        reduceTransparency: profile.reduceTransparency,
        accentColor: profile.accentColor,
      ),
      themeMode: mode,
      routerConfig: router,
    );
  }
}
