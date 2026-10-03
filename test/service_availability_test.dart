import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rolevia/app.dart';
import 'package:rolevia/core/config/app_config.dart';
import 'package:rolevia/data/fixtures.dart';
import 'package:rolevia/state/app_state.dart';

import 'app_test.dart' show MemoryRepository;

void main() {
  setUp(() {
    AppConfig.configuredOverride = false;
  });

  tearDown(() {
    AppConfig.configuredOverride = null;
  });

  testWidgets(
    'unavailable sign-in does not authenticate; local entry still works',
    (tester) async {
      tester.platformDispatcher.defaultRouteNameTestValue = '/sign-in';
      addTearDown(tester.platformDispatcher.clearDefaultRouteNameTestValue);
      final repository = MemoryRepository(
        fixtureSnapshot()
          ..addAll({'onboardingComplete': true, 'authenticated': false}),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [repositoryProvider.overrideWithValue(repository)],
          child: const AppBootstrap(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();
      expect(
        find.text('Google sign-in is currently unavailable.'),
        findsOneWidget,
      );
      expect(repository.value!['authenticated'], isFalse);

      await tester.ensureVisible(find.text('Sign in'));
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();
      expect(
        find.text('Email sign-in is currently unavailable.'),
        findsOneWidget,
      );
      expect(repository.value!['authenticated'], isFalse);

      await tester.ensureVisible(find.text('Continue on this device'));
      await tester.tap(find.text('Continue on this device'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Skip for now'));
      await tester.tap(find.text('Skip for now'));
      await tester.pumpAndSettle();
      expect(find.text('Run Analysis'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('unavailable rewarded ads do not grant scans', (tester) async {
    final repository = MemoryRepository(
      fixtureSnapshot()
        ..addAll({'onboardingComplete': true, 'authenticated': true}),
    );
    (repository.value!['profile'] as Map)['scanQuota'] = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [repositoryProvider.overrideWithValue(repository)],
        child: const AppBootstrap(),
      ),
    );
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(AppBootstrap)),
    );
    final before = container.read(appControllerProvider).profile.scanQuota;
    await tester.ensureVisible(find.text('Get another scan'));
    await tester.tap(find.text('Get another scan'));
    await tester.pumpAndSettle();
    expect(find.text('No ads available'), findsOneWidget);
    await tester.pump(const Duration(seconds: 6));
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    expect(container.read(appControllerProvider).profile.scanQuota, before);
    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Watch ad'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Watch ad'));
    await tester.pumpAndSettle();
    expect(find.text('No ads available'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(container.read(appControllerProvider).profile.scanQuota, before);
    expect(tester.takeException(), isNull);
  });
}
