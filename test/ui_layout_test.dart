import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rolevia/app.dart';
import 'package:rolevia/core/widgets/adaptive_navigation_bar.dart';
import 'package:rolevia/core/widgets/pressable.dart';
import 'fixtures.dart';
import 'package:rolevia/features/application_details_sheet.dart';
import 'package:rolevia/models/models.dart';
import 'package:rolevia/state/app_state.dart';

import 'app_test.dart' show MemoryRepository;

class _DeferredRepository extends MemoryRepository {
  final response = Completer<Map<String, dynamic>?>();

  @override
  Future<Map<String, dynamic>?> read() => response.future;
}

Future<void> openApp(
  WidgetTester tester,
  Size size,
  AppTheme theme,
  double scale,
) async {
  await tester.binding.setSurfaceSize(size);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(() {
    tester.binding.setSurfaceSize(null);
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
  final data = fixtureSnapshot()
    ..addAll({'onboardingComplete': true, 'authenticated': true});
  data['profile'] = ProfileSettings(theme: theme).toJson();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [repositoryProvider.overrideWithValue(MemoryRepository(data))],
      child: const AppBootstrap(),
    ),
  );
  await tester.pumpAndSettle();
}

Finder destination(String label, bool wide) => find.descendant(
  of: find.byType(wide ? NavigationRail : AdaptiveNavigationBar),
  matching: wide ? find.text(label) : find.byTooltip(label),
);

void main() {
  testWidgets('loading a tab URL waits for the router without route warnings', (
    tester,
  ) async {
    tester.platformDispatcher.defaultRouteNameTestValue = '/tracker';
    addTearDown(tester.platformDispatcher.clearDefaultRouteNameTestValue);
    final repository = _DeferredRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [repositoryProvider.overrideWithValue(repository)],
        child: const AppBootstrap(),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.takeException(), isNull);
    repository.response.complete(
      fixtureSnapshot()
        ..addAll({'onboardingComplete': true, 'authenticated': true}),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).selectedIndex,
      1,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'scroll navigation shrinks, restores, and keeps the page stable',
    (tester) async {
      await openApp(tester, const Size(390, 844), AppTheme.light, 1);
      await tester.tap(destination('Discover', false));
      await tester.pumpAndSettle();
      final scroll = find.byType(CustomScrollView);
      final height = tester.getSize(scroll).height;
      final surface = find.byKey(const ValueKey('navigation-surface'));
      final expandedWidth = tester.getSize(surface).width;
      await tester.drag(scroll, const Offset(0, -180));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<AdaptiveNavigationBar>(find.byType(AdaptiveNavigationBar))
            .isMinimized,
        isTrue,
      );
      expect(tester.getSize(surface).width, lessThan(expandedWidth));
      expect(tester.getSize(surface).height, 56);
      expect(tester.getSize(scroll).height, height);
      expect(
        find.descendant(
          of: find.byType(AdaptiveNavigationBar),
          matching: find.byType(Text),
        ),
        findsNothing,
      );
      for (final label in [
        'Discover',
        'Tracker',
        'Vault',
        'Dashboard',
      ]) {
        expect(destination(label, false), findsOneWidget);
        final rect = tester.getRect(destination(label, false));
        expect(rect.width, greaterThanOrEqualTo(44));
        expect(rect.height, greaterThanOrEqualTo(44));
      }
      await tester.drag(scroll, const Offset(0, 65));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<AdaptiveNavigationBar>(find.byType(AdaptiveNavigationBar))
            .isMinimized,
        isFalse,
      );
      await tester.drag(scroll, const Offset(0, -180));
      await tester.pumpAndSettle();
      await tester.tap(destination('Vault', false));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<AdaptiveNavigationBar>(find.byType(AdaptiveNavigationBar))
            .isMinimized,
        isFalse,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('clearing search cancels pending filter updates', (tester) async {
    await openApp(tester, const Size(390, 844), AppTheme.light, 1);
    await tester.tap(destination('Discover', false));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Flutter');
    await tester.pump();
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();
    expect(find.text('Recommended for you (4)'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
  });
  testWidgets(
    'phone navigation clears device safe area and hides for the keyboard',
    (tester) async {
      await openApp(tester, const Size(390, 844), AppTheme.light, 1);
      tester.view.padding = const FakeViewPadding(bottom: 34);
      await tester.pumpAndSettle();
      final lastTab = tester.getRect(destination('Dashboard', false));
      expect(lastTab.bottom, lessThanOrEqualTo(810));
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpAndSettle();
      expect(find.byType(AdaptiveNavigationBar), findsNothing);
      expect(tester.takeException(), isNull);
      tester.view.resetPadding();
      tester.view.resetViewInsets();
    },
  );
  for (final theme in [AppTheme.light, AppTheme.dark]) {
    for (final size in [
      const Size(320, 568),
      const Size(390, 844),
      const Size(768, 1024),
      const Size(1280, 800),
      const Size(844, 390),
    ]) {
      for (final scale in [1.0, 2.0]) {
        testWidgets('all tabs at ${size.width}, text $scale, ${theme.name}', (
          tester,
        ) async {
          await openApp(tester, size, theme, scale);
          final wide = size.width >= 720 && size.height >= 560;
          if (!wide) {
            final bar = tester.getRect(find.byType(AdaptiveNavigationBar));
            expect(bar.top, greaterThan(size.height - 160));
            expect(bar.bottom, lessThanOrEqualTo(size.height));
          }
          for (final label in [
            'Discover',
            'Tracker',
            'Vault',
            'Dashboard',
          ]) {
            final target = destination(label, wide);
            if (!wide) {
              final targetRect = tester.getRect(target);
              expect(targetRect.left, greaterThanOrEqualTo(0));
              expect(targetRect.right, lessThanOrEqualTo(size.width));
            }
            await tester.tap(target);
            await tester.pumpAndSettle();
            expect(
              tester.takeException(),
              isNull,
              reason: '$label at $size, scale $scale',
            );
            final scrollView = find.byType(CustomScrollView);
            if (scrollView.evaluate().isNotEmpty) {
              for (var step = 0; step < 6; step++) {
                await tester.drag(scrollView, const Offset(0, -400));
                await tester.pumpAndSettle();
                expect(
                  tester.takeException(),
                  isNull,
                  reason: '$label scrolled step $step at $size, scale $scale',
                );
              }
            }
          }
        });
      }
    }
  }

  testWidgets(
    'search persists when switching tabs and returning from a detail',
    (tester) async {
      await openApp(tester, const Size(390, 844), AppTheme.light, 1);
      await tester.tap(destination('Discover', false));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Flutter');
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();
      await tester.tap(destination('Vault', false));
      await tester.pumpAndSettle();
      await tester.tap(destination('Discover', false));
      await tester.pumpAndSettle();
      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('Junior Flutter Developer'), findsOneWidget);
      expect(find.text('Customer Support Associate'), findsNothing);
      await tester.tap(find.text('Junior Flutter Developer'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Flutter'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('pressable supports keyboard activation and disabled states', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PressableScale(
            onPressed: () => taps++,
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(taps, 2);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PressableScale(
            enabled: false,
            onPressed: () => taps++,
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    expect(taps, 2);
  });

  testWidgets(
    'phone navigation displays all tabs including Dashboard within screen bounds without horizontal scroll',
    (tester) async {
      for (final scale in [1.0, 1.35, 1.5, 2.0]) {
        await openApp(tester, const Size(360, 640), AppTheme.light, scale);
        expect(
          find.descendant(
            of: find.byType(AdaptiveNavigationBar),
            matching: find.byType(SingleChildScrollView),
          ),
          findsNothing,
        );
        for (final label in [
          'Discover',
          'Tracker',
          'Vault',
          'Dashboard',
        ]) {
          final target = destination(label, false);
          expect(target, findsOneWidget);
          final rect = tester.getRect(target);
          expect(
            rect.left,
            greaterThanOrEqualTo(0),
            reason: '$label left at scale $scale',
          );
          expect(
            rect.right,
            lessThanOrEqualTo(360),
            reason: '$label right at scale $scale',
          );
        }
        final dashboard = destination('Dashboard', false);
        await tester.tap(dashboard);
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<AdaptiveNavigationBar>(find.byType(AdaptiveNavigationBar))
              .selectedIndex,
          3,
        );

        final navTexts = tester.widgetList<Text>(
          find.descendant(
            of: find.byType(AdaptiveNavigationBar),
            matching: find.byType(Text),
          ),
        );
        for (final navText in navTexts) {
          expect(
            navText.maxLines,
            1,
            reason: '${navText.data} maxLines must be 1 to prevent text wrapping',
          );
          expect(
            navText.softWrap,
            false,
            reason: '${navText.data} softWrap must be false to keep on single line',
          );
        }
      }
    },
  );

  testWidgets(
    'Match screen renders cleanly and adapts without overflow under narrow constraints',
    (tester) async {
      await openApp(tester, const Size(200, 600), AppTheme.light, 1.0);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'tapping an application card in Tracker opens details sheet above FAB and shell navigation',
    (tester) async {
      await openApp(tester, const Size(390, 844), AppTheme.light, 1.0);
      final trackerTab = destination('Tracker', false);
      await tester.tap(trackerTab);
      await tester.pumpAndSettle();

      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);

      final appCard = find.text('Mobile Developer Trainee');
      expect(appCard, findsOneWidget);
      await tester.tap(appCard);
      await tester.pumpAndSettle();

      expect(find.byType(ApplicationDetailsBody), findsOneWidget);
      final barrier = find.byType(ModalBarrier);
      expect(barrier, findsWidgets);

      final closeButton = find.byTooltip('Close dialog');
      expect(closeButton, findsOneWidget);
      await tester.tap(closeButton);
      await tester.pumpAndSettle();

      expect(find.byType(ApplicationDetailsBody), findsNothing);
      expect(fab, findsOneWidget);
    },
  );
}
