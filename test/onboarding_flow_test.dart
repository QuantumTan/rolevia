import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  testWidgets('tapping Skip on OnboardingScreen navigates to SignInScreen', (tester) async {
    final repository = MemoryRepository(
      fixtureSnapshot()
        ..addAll({'onboardingComplete': false, 'authenticated': false}),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [repositoryProvider.overrideWithValue(repository)],
        child: const AppBootstrap(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Skip'), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('tapping Get started on OnboardingScreen navigates to SignInScreen', (tester) async {
    final repository = MemoryRepository(
      fixtureSnapshot()
        ..addAll({'onboardingComplete': false, 'authenticated': false}),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [repositoryProvider.overrideWithValue(repository)],
        child: const AppBootstrap(),
      ),
    );
    await tester.pumpAndSettle();

    // Swipe to last page
    await tester.drag(find.text('Paste any job post'), const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.drag(find.text('See your match and gaps'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(find.text('Get started'), findsOneWidget);
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(find.text('Continue with Google'), findsOneWidget);
  });
}
