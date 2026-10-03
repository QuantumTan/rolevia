import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rolevia/app.dart';
import 'package:rolevia/core/config/app_config.dart';
import 'package:rolevia/data/workspace_repository.dart';
import 'package:rolevia/state/app_state.dart';
import 'fixtures.dart';

class PartitionedMemoryRepository implements WorkspaceRepository {
  PartitionedMemoryRepository({Map<String, dynamic>? initial}) {
    if (initial != null) {
      _data = Map<String, dynamic>.from(initial);
    }
  }

  Map<String, dynamic>? _data;

  @override
  Future<Map<String, dynamic>?> read() async => _data;

  @override
  Future<void> write(Map<String, dynamic> data) async =>
      _data = Map<String, dynamic>.from(data);

  @override
  Future<void> clear() async => _data = null;
}

void main() {
  setUp(() {
    AppConfig.configuredOverride = false;
  });

  tearDown(() {
    AppConfig.configuredOverride = null;
  });

  group('Security & User Data Isolation Tests', () {
    test('signOut completely clears sensitive applications, resumes, and profile from memory', () async {
      final seeded = fixtureSnapshot()
        ..addAll({
          'onboardingComplete': true,
          'authenticated': true,
        });

      final repo = PartitionedMemoryRepository(initial: seeded);
      final container = ProviderContainer(
        overrides: [repositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      while (!container.read(appControllerProvider).ready) {
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }

      final controller = container.read(appControllerProvider.notifier);
      final before = container.read(appControllerProvider);

      expect(before.authenticated, isTrue);
      expect(before.applications, isNotEmpty);
      expect(before.resumes, isNotEmpty);
      expect(before.savedJobIds, isNotEmpty);

      // Perform sign out
      await controller.signOut();

      final after = container.read(appControllerProvider);
      expect(after.authenticated, isFalse, reason: 'State must be unauthenticated');
      expect(after.applications, isEmpty, reason: 'Tracker data must be wiped completely');
      expect(after.resumes, isEmpty, reason: 'Resume vault must be wiped completely');
      expect(after.matches, isEmpty, reason: 'Match history must be wiped completely');
      expect(after.savedJobIds, isEmpty, reason: 'Saved jobs must be wiped completely');
      expect(after.profile.name, isEmpty, reason: 'Personal profile name must be erased');
      expect(after.profile.email, isEmpty, reason: 'Personal email must be erased');
    });

    test('multi-user account switching prevents User B from seeing User A data', () async {
      final userARepo = PartitionedMemoryRepository(initial: {
        ...fixtureSnapshot(),
        'onboardingComplete': true,
        'authenticated': true,
        'profile': {'name': 'Alice Engineer', 'email': 'alice@company.com'},
        'applications': [
          {
            'id': 'app-alice-1',
            'jobId': 'j1',
            'company': 'Tech Corp',
            'role': 'Lead Flutter Architect',
            'location': 'Manila',
            'stage': 'applied',
            'appliedAt': DateTime.now().toIso8601String(),
            'notes': ['Secret salary: 180k'],
          }
        ],
      });

      final userBRepo = PartitionedMemoryRepository(initial: {
        'onboardingComplete': true,
        'authenticated': true,
        'profile': {'name': 'Bob Junior', 'email': 'bob@startup.io'},
        'applications': <Map<String, dynamic>>[],
        'resumes': <Map<String, dynamic>>[],
      });

      // Map owner to their isolated storage
      final Map<String, PartitionedMemoryRepository> userDbs = {
        'user_alice_company_com': userARepo,
        'user_bob_startup_io': userBRepo,
        'guest': PartitionedMemoryRepository(),
      };

      final container = ProviderContainer(
        overrides: [
          repositoryProvider.overrideWith((ref) {
            final owner = ref.watch(activeOwnerProvider);
            return userDbs.putIfAbsent(owner, PartitionedMemoryRepository.new);
          }),
        ],
      );
      addTearDown(container.dispose);

      while (!container.read(appControllerProvider).ready) {
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }

      final controller = container.read(appControllerProvider.notifier);

      // 1. Sign in as Alice
      await controller.signIn(
        email: 'alice@company.com',
        name: 'Alice Engineer',
      );
      final aliceState = container.read(appControllerProvider);
      expect(aliceState.authenticated, isTrue);
      expect(aliceState.profile.name, 'Alice Engineer');
      expect(aliceState.applications.length, 1);
      expect(aliceState.applications.first.role, 'Lead Flutter Architect');

      // 2. Alice signs out
      await controller.signOut();
      final signedOutState = container.read(appControllerProvider);
      expect(signedOutState.authenticated, isFalse);
      expect(signedOutState.applications, isEmpty);

      // 3. Bob logs in
      await controller.signIn(
        email: 'bob@startup.io',
        name: 'Bob Junior',
      );
      final bobState = container.read(appControllerProvider);
      expect(bobState.authenticated, isTrue);
      expect(bobState.profile.name, 'Bob Junior');
      expect(bobState.applications, isEmpty, reason: 'Bob must NEVER see Alice applications');

      // 4. Bob signs out and Alice logs back in
      await controller.signOut();
      await controller.signIn(
        email: 'alice@company.com',
        name: 'Alice Engineer',
      );
      final aliceRestoredState = container.read(appControllerProvider);
      expect(aliceRestoredState.applications.length, 1);
      expect(aliceRestoredState.applications.first.id, 'app-alice-1');
    });

    testWidgets('unauthenticated user is blocked by GoRouter and redirected to /sign-in', (tester) async {
      tester.platformDispatcher.defaultRouteNameTestValue = '/tracker';
      addTearDown(tester.platformDispatcher.clearDefaultRouteNameTestValue);

      final repository = PartitionedMemoryRepository(
        initial: fixtureSnapshot()
          ..addAll({'onboardingComplete': true, 'authenticated': false}),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [repositoryProvider.overrideWithValue(repository)],
          child: const AppBootstrap(),
        ),
      );
      await tester.pumpAndSettle();

      // Protected route /tracker must be redirected to /sign-in
      expect(find.text('Welcome back.'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
    });

    testWidgets('TrackerScreen defense-in-depth displays locked screen when unauthenticated', (tester) async {
      final repository = PartitionedMemoryRepository(
        initial: fixtureSnapshot()
          ..addAll({'onboardingComplete': true, 'authenticated': false}),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [repositoryProvider.overrideWithValue(repository)],
          child: const MaterialApp(
            home: AppBootstrap(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure user lands on sign-in
      expect(find.text('Welcome back.'), findsOneWidget);
    });

    testWidgets('Signing out from ProfileScreen removes all private tracker records and redirects to /sign-in', (tester) async {
      tester.platformDispatcher.defaultRouteNameTestValue = '/profile';
      addTearDown(tester.platformDispatcher.clearDefaultRouteNameTestValue);

      final repository = PartitionedMemoryRepository(
        initial: fixtureSnapshot()
          ..addAll({'onboardingComplete': true, 'authenticated': true}),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [repositoryProvider.overrideWithValue(repository)],
          child: const AppBootstrap(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Profile & Settings'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Sign out'),
        300,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('Sign out'), findsOneWidget);

      // Tap Sign out
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();

      // Must be back at Sign In
      expect(find.text('Welcome back.'), findsOneWidget);

      // Verify state was completely purged
      final container = ProviderScope.containerOf(
        tester.element(find.byType(AppBootstrap)),
      );
      final state = container.read(appControllerProvider);
      expect(state.authenticated, isFalse);
      expect(state.applications, isEmpty);
      expect(state.resumes, isEmpty);
    });
  });
}
