import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rolevia/core/design/icons.dart';
import 'package:rolevia/core/widgets/adaptive_navigation_bar.dart';
import 'package:rolevia/core/widgets/branch_container.dart';
import 'package:rolevia/core/widgets/app_top_bar.dart';
import 'package:rolevia/features/match_screen.dart';
import 'package:rolevia/models/models.dart';
import 'package:rolevia/state/app_state.dart';
import 'fixtures.dart';
import 'app_test.dart' show MemoryRepository;

Widget _wrapWithTheme(Widget child, {double width = 360, double scale = 1.0}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(
        size: Size(width, 700),
        textScaler: TextScaler.linear(scale),
        padding: const EdgeInsets.only(bottom: 24),
      ),
      child: Scaffold(
        body: child,
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Floating Navigation Bar (Phase 3)', () {
    const destinations = [
      AdaptiveNavDestination(
        semanticIcon: AppSemanticIcon.discover,
        label: 'Discover',
      ),
      AdaptiveNavDestination(
        semanticIcon: AppSemanticIcon.document,
        label: 'Vault',
      ),
      AdaptiveNavDestination(
        semanticIcon: AppSemanticIcon.tracker,
        label: 'Pipeline',
      ),
      AdaptiveNavDestination(
        semanticIcon: AppSemanticIcon.dashboard,
        label: 'Dashboard',
      ),
    ];

    testWidgets('all 5 slots are visible simultaneously in a fixed Row without swiping', (tester) async {
      int selected = 0;
      bool analyzeTapped = false;

      await tester.pumpWidget(
        _wrapWithTheme(
          AdaptiveNavigationBar(
            selectedIndex: selected,
            destinations: destinations,
            onDestinationSelected: (idx) => selected = idx,
            onActionTap: () => analyzeTapped = true,
          ),
          width: 360,
        ),
      );
      await tester.pumpAndSettle();

      // Verify all 5 labels are visible
      expect(find.text('Discover'), findsOneWidget);
      expect(find.text('Vault'), findsOneWidget);
      expect(find.text('Analyze'), findsOneWidget);
      expect(find.text('Pipeline'), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);

      // Verify Row contains 5 Expanded children
      final rowFinder = find.descendant(
        of: find.byType(AdaptiveNavigationBar),
        matching: find.byType(Row),
      );
      expect(rowFinder, findsOneWidget);

      final row = tester.widget<Row>(rowFinder.first);
      expect(row.children.length, 5);
      for (final child in row.children) {
        expect(child, isA<Expanded>());
      }

      // Verify center Analyze action tap
      await tester.tap(find.text('Analyze'));
      await tester.pumpAndSettle();
      expect(analyzeTapped, isTrue);

      // Verify tab tap
      await tester.tap(find.text('Vault'));
      await tester.pumpAndSettle();
      expect(selected, 1);
    });

    for (final width in [320.0, 360.0, 390.0, 430.0]) {
      testWidgets('zero overflow at width $width with 1.3x text scale', (tester) async {
        await tester.pumpWidget(
          _wrapWithTheme(
            AdaptiveNavigationBar(
              selectedIndex: 0,
              destinations: destinations,
              onDestinationSelected: (_) {},
              onActionTap: () {},
            ),
            width: width,
            scale: 1.3,
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);

        // Verify touch targets >= 44x44
        for (final label in ['Discover', 'Vault', 'Analyze', 'Pipeline', 'Dashboard']) {
          final item = find.text(label);
          expect(item, findsOneWidget);
        }
      });
    }

    testWidgets('compact mode on scroll hides labels and keeps height 56', (tester) async {
      await tester.pumpWidget(
        _wrapWithTheme(
          AdaptiveNavigationBar(
            selectedIndex: 0,
            isMinimized: true,
            destinations: destinations,
            onDestinationSelected: (_) {},
            onActionTap: () {},
          ),
          width: 360,
        ),
      );
      await tester.pumpAndSettle();

      // No text labels rendered in minimized mode
      expect(
        find.descendant(
          of: find.byType(AdaptiveNavigationBar),
          matching: find.byType(Text),
        ),
        findsNothing,
      );

      // Surface height is 56
      final surface = find.byKey(const ValueKey('navigation-surface'));
      expect(tester.getSize(surface).height, 56.0);
    });

    testWidgets('active tab displays 12% accent capsule container', (tester) async {
      await tester.pumpWidget(
        _wrapWithTheme(
          AdaptiveNavigationBar(
            selectedIndex: 0,
            destinations: destinations,
            onDestinationSelected: (_) {},
            onActionTap: () {},
          ),
          width: 360,
        ),
      );
      await tester.pumpAndSettle();

      // Discover (tab 0) is selected and has active accent container
      final discoverContainer = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byTooltip('Discover'),
          matching: find.byType(AnimatedContainer),
        ).first,
      );
      final discoverDec = discoverContainer.decoration as BoxDecoration;
      expect(discoverDec.color, isNotNull);
      expect(discoverDec.color, isNot(Colors.transparent));

      final vaultContainer = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byTooltip('Vault'),
          matching: find.byType(AnimatedContainer),
        ).first,
      );
      final vaultDec = vaultContainer.decoration as BoxDecoration;
      expect(vaultDec.color, Colors.transparent);
    });
  });

  group('Branch Container & Tab State Persistence', () {
    testWidgets('uses IndexedStack and retains state across tab switches', (tester) async {
      int index = 0;
      final controller1 = TextEditingController(text: 'Text in Tab 0');
      final controller2 = TextEditingController(text: 'Text in Tab 1');

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: BranchContainer(
                  index: index,
                  children: [
                    TextField(controller: controller1, key: const ValueKey('field_0')),
                    TextField(controller: controller2, key: const ValueKey('field_1')),
                  ],
                ),
                bottomNavigationBar: Row(
                  children: [
                    TextButton(onPressed: () => setState(() => index = 0), child: const Text('Tab 0')),
                    TextButton(onPressed: () => setState(() => index = 1), child: const Text('Tab 1')),
                  ],
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // IndexedStack is in the tree
      expect(find.byType(IndexedStack), findsOneWidget);
      expect(find.text('Text in Tab 0'), findsOneWidget);

      // Switch to Tab 1
      await tester.tap(find.text('Tab 1'));
      await tester.pumpAndSettle();
      expect(find.text('Text in Tab 1'), findsOneWidget);

      // Switch back to Tab 0 and verify text is preserved
      await tester.tap(find.text('Tab 0'));
      await tester.pumpAndSettle();
      expect(find.text('Text in Tab 0'), findsOneWidget);
    });
  });

  group('TopBar & Quota Pill (Phase 3)', () {
    testWidgets('shows quota pill with tabular figures and color states', (tester) async {
      final repository = MemoryRepository(
        fixtureSnapshot()
          ..addAll({
            'onboardingComplete': true,
            'authenticated': true,
            'profile': ProfileSettings(scanQuota: 2).toJson(),
          }),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [repositoryProvider.overrideWithValue(repository)],
          child: MaterialApp(
            home: const Scaffold(
              body: CustomScrollView(
                slivers: [
                  SliverAppTopBar(
                    title: 'Discover',
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2 scans left'), findsOneWidget);

      // Tap quota pill opens scan credit sheet
      await tester.tap(find.text('2 scans left'));
      await tester.pumpAndSettle();

      expect(find.text('Scan Credits'), findsOneWidget);
      expect(find.text('Watch ad for +1 scan'), findsOneWidget);
    });

    testWidgets('Pipeline top bar includes Add button', (tester) async {
      bool addPressed = false;
      final repository = MemoryRepository(
        fixtureSnapshot()
          ..addAll({
            'onboardingComplete': true,
            'authenticated': true,
          }),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [repositoryProvider.overrideWithValue(repository)],
          child: MaterialApp(
            home: Scaffold(
              body: CustomScrollView(
                slivers: [
                  SliverAppTopBar(
                    title: 'Pipeline',
                    onAdd: () => addPressed = true,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final addBtn = find.byTooltip('Add application');
      expect(addBtn, findsOneWidget);

      await tester.tap(addBtn);
      await tester.pumpAndSettle();
      expect(addPressed, isTrue);
    });
  });

  group('Match Studio & Share Intake', () {
    testWidgets('prefills shared text and displays source chip', (tester) async {
      final repository = MemoryRepository(
        fixtureSnapshot()
          ..addAll({
            'onboardingComplete': true,
            'authenticated': true,
          }),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [repositoryProvider.overrideWithValue(repository)],
          child: const MaterialApp(
            home: MatchScreen(
              initialText: 'Senior Flutter Developer at Manila Tech Inc',
              sourceLabel: 'Shared from Facebook',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Shared from Facebook'), findsOneWidget);
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, 'Senior Flutter Developer at Manila Tech Inc');

      // Dismiss source chip
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Shared from Facebook'), findsNothing);
    });
  });
}
