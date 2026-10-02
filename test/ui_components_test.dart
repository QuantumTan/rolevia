import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rolevia/core/theme.dart';
import 'package:rolevia/core/widgets/score_ring.dart';
import 'package:rolevia/core/widgets/copy_button.dart';
import 'package:rolevia/features/shell.dart';
import 'package:rolevia/features/detail_screens.dart';
import 'package:rolevia/shared/widgets.dart';
import 'package:rolevia/models/models.dart';

import 'ui_layout_test.dart' show openApp, destination;

void main() {
  test('text and action tokens meet normal-text contrast in every palette', () {
    double ratio(Color a, Color b) {
      final first = a.computeLuminance();
      final second = b.computeLuminance();
      return first > second
          ? (first + 0.05) / (second + 0.05)
          : (second + 0.05) / (first + 0.05);
    }

    for (final colors in [
      AppColors.light,
      AppColors.dark,
      AppColors.lightHighContrast,
      AppColors.darkHighContrast,
    ]) {
      for (final surface in [colors.surface, colors.elevatedSurface]) {
        for (final text in [
          colors.labelPrimary,
          colors.labelSecondary,
          colors.accent,
        ]) {
          expect(ratio(text, surface), greaterThanOrEqualTo(4.5));
        }
      }
      expect(ratio(Colors.white, colors.primary), greaterThanOrEqualTo(4.5));
    }
  });
  testWidgets(
    'score counts up, reaches its value and exposes one semantic label',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          theme: appTheme(Brightness.light),
          home: const Scaffold(body: BandScoreRing(85)),
        ),
      );
      expect(find.text('0%'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 800));
      expect(find.text('85%'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Match score 85 percent, Strong match'),
        findsOneWidget,
      );
      semantics.dispose();
    },
  );
  for (final brightness in Brightness.values) {
    testWidgets('badge bands at 49 50 74 75 in $brightness', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: appTheme(brightness),
          home: const Scaffold(
            body: Column(
              children: [
                MatchBadge(49),
                MatchBadge(50),
                MatchBadge(74),
                MatchBadge(75),
              ],
            ),
          ),
        ),
      );
      final colors = brightness == Brightness.dark
          ? AppColors.dark
          : AppColors.light;
      for (final pair in [
        (49, colors.error),
        (50, colors.warning),
        (74, colors.warning),
        (75, colors.success),
      ]) {
        expect(
          tester.widget<Text>(find.text('${pair.$1}% Match')).style!.color,
          pair.$2,
        );
      }
    });
  }
  testWidgets('empty state presents its actionable recovery', (tester) async {
    var called = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme(Brightness.light),
        home: Scaffold(
          body: EmptyState(
            icon: Icons.description,
            title: 'No resumes yet',
            message: 'Add your first resume.',
            action: TextButton(
              onPressed: () => called = true,
              child: const Text('Add resume'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add resume'));
    expect(called, isTrue);
    expect(find.text('No resumes yet'), findsOneWidget);
  });
  testWidgets('navigation switches branch and keeps selected semantics', (
    tester,
  ) async {
    await openApp(tester, const Size(360, 640), AppTheme.light, 1.3);
    await tester.tap(destination('Vault', false));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<AdaptiveNavigationBar>(find.byType(AdaptiveNavigationBar))
          .selectedIndex,
      1,
    );
    await tester.tap(destination('Match', false));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<AdaptiveNavigationBar>(find.byType(AdaptiveNavigationBar))
          .selectedIndex,
      2,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('reduced motion freezes skeletons and immediately shows score', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme(Brightness.dark),
        home: const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: Column(children: [BandScoreRing(75), SkeletonBox()]),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('75%'), findsOneWidget);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
  test('company initials tolerate whitespace and empty names', () {
    expect(const CompanyAvatar('  Northwind Digital ').initials, 'ND');
    expect(const CompanyAvatar('').initials, '?');
  });
  testWidgets('copy button copies actual content and confirms inline', (
    tester,
  ) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'];
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme(Brightness.light),
        home: const Scaffold(body: CopyButton('Verified experience')),
      ),
    );
    await tester.tap(find.text('Copy'));
    await tester.pumpAndSettle();
    expect(copied, 'Verified experience');
    expect(find.text('Copied'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpWidget(const SizedBox());
  });
  for (final theme in [AppTheme.light, AppTheme.dark]) {
    testWidgets('pushed routes remain usable at 360x640 text 1.3 in $theme', (
      tester,
    ) async {
      await openApp(tester, const Size(360, 640), theme, 1.3);
      final router = GoRouter.of(tester.element(find.byType(AppShell)));
      for (final route in [
        '/jobs/j1',
        '/matches/m1',
        '/rewrites',
        '/interview',
        '/profile',
      ]) {
        router.push(route);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: route);
        final scrollable = find.byType(Scrollable).first;
        await tester.drag(scrollable, const Offset(0, -900));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$route scrolled');
        router.pop();
        await tester.pumpAndSettle();
      }
    });
  }
  testWidgets(
    'results keyword sheet copies and skills collapse without overflow',
    (tester) async {
      await openApp(tester, const Size(360, 640), AppTheme.light, 1.3);
      GoRouter.of(tester.element(find.byType(AppShell))).push('/matches/m1');
      await tester.pumpAndSettle();
      final missing = find.text('Docker');
      await tester.scrollUntilVisible(
        missing,
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(missing);
      await tester.pumpAndSettle();
      expect(find.byType(CopyButton), findsOneWidget);
      expect(tester.takeException(), isNull);
      Navigator.of(tester.element(find.byType(CopyButton))).pop();
      await tester.pumpAndSettle();
      expect(find.byType(MatchResultScreen), findsOneWidget);
    },
  );
}
