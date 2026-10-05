import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rolevia/app.dart';
import 'package:rolevia/core/config/app_config.dart';
import 'fixtures.dart';
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
    'SignInScreen toggles between Sign In and Create Account tabs with proper fields',
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

      // Starts in Sign In mode
      expect(find.text('Welcome back.'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
      expect(find.text('Confirm Password'), findsNothing);

      // Switch to Create Account tab
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('Create account.'), findsOneWidget);
      expect(find.text('Create account'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);

      // Switch back to Sign In
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome back.'), findsOneWidget);
      expect(find.text('Confirm Password'), findsNothing);
    },
  );

  testWidgets(
    'Create Account validates password confirmation mismatch when fields differ',
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

      // Switch to Create Account
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Fill in email and mismatched passwords
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'user@example.com');
      await tester.enterText(textFields.at(1), 'password123');
      await tester.enterText(textFields.at(2), 'password999');
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Create account'));
      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match.'), findsOneWidget);
    },
  );

  testWidgets(
    'ProfileScreen renders Sign out button when authenticated and resets auth state',
    (tester) async {
      tester.platformDispatcher.defaultRouteNameTestValue = '/profile';
      addTearDown(tester.platformDispatcher.clearDefaultRouteNameTestValue);
      final repository = MemoryRepository(
        fixtureSnapshot()
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

      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();

      // Should navigate back to sign-in screen
      expect(find.text('Welcome back.'), findsOneWidget);
      expect(repository.value!['authenticated'], isFalse);
    },
  );

  testWidgets(
    'SignInScreen toggles password obscure visibility using eye icon button',
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

      // Password field starts obscured
      final passwordFieldFinder = find.byWidgetPredicate(
        (w) => w is TextField && w.obscureText == true,
      );
      expect(passwordFieldFinder, findsOneWidget);

      final showButton = find.byTooltip('Show password');
      expect(showButton, findsOneWidget);

      // Scroll into view and tap show password toggle
      await tester.ensureVisible(showButton);
      await tester.tap(showButton);
      await tester.pumpAndSettle();

      // Now password should be visible (obscureText is false)
      final visiblePasswordFieldFinder = find.byWidgetPredicate(
        (w) => w is TextField && w.obscureText == false,
      );
      // Email is index 0 (not obscured), and password is now also not obscured
      expect(visiblePasswordFieldFinder, findsNWidgets(2));
      final hideButton = find.byTooltip('Hide password');
      expect(hideButton, findsOneWidget);

      // Scroll into view and tap hide password toggle
      await tester.ensureVisible(hideButton);
      await tester.tap(hideButton);
      await tester.pumpAndSettle();

      // Now password should be obscured again
      expect(
        find.byWidgetPredicate((w) => w is TextField && w.obscureText == true),
        findsOneWidget,
      );
      expect(find.byTooltip('Show password'), findsOneWidget);
    },
  );
}
