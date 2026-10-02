import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rolevia/app.dart';
import 'package:rolevia/data/demo_repository.dart';
import 'package:rolevia/data/fixtures.dart';
import 'package:rolevia/models/models.dart';
import 'package:rolevia/state/app_state.dart';

class _GoldenRepository implements DemoRepository {
  _GoldenRepository(this.value);
  Map<String, dynamic>? value;
  @override
  Future<Map<String, dynamic>?> read() async => value;
  @override
  Future<void> write(Map<String, dynamic> data) async => value = data;
  @override
  Future<void> clear() async => value = null;
}

void main() {
  setUpAll(() async {
    final font = FontLoader('Inter')
      ..addFont(rootBundle.load('assets/fonts/Inter-Variable.ttf'));
    await font.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    final cupertino = FontLoader('CupertinoIcons')
      ..addFont(
        rootBundle.load('packages/cupertino_icons/assets/CupertinoIcons.ttf'),
      );
    await cupertino.load();
  });
  for (final theme in [AppTheme.light, AppTheme.dark]) {
    testWidgets('Discover renders at 390x844 in ${theme.name}', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.binding.setSurfaceSize(null);
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      final data = fixtureSnapshot()
        ..addAll({'onboardingComplete': true, 'authenticated': true});
      data['profile'] = ProfileSettings(theme: theme).toJson();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            repositoryProvider.overrideWithValue(_GoldenRepository(data)),
          ],
          child: const AppBootstrap(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discover'));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(AppBootstrap),
        matchesGoldenFile('goldens/discover_${theme.name}.png'),
      );
    });
  }

  testWidgets('narrow phone with 200 percent text has no render exceptions', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(() {
      tester.binding.setSurfaceSize(null);
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });
    final data = fixtureSnapshot()
      ..addAll({'onboardingComplete': true, 'authenticated': true});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          repositoryProvider.overrideWithValue(_GoldenRepository(data)),
        ],
        child: const AppBootstrap(),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
