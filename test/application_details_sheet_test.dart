import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rolevia/core/theme.dart';
import 'fixtures.dart';
import 'package:rolevia/features/application_details_sheet.dart';
import 'package:rolevia/models/models.dart';
import 'package:rolevia/state/app_state.dart';

import 'app_test.dart' show MemoryRepository;

final _sheet = find.byKey(const ValueKey('adaptive-draggable-sheet'));
final _grabber = find.byKey(const ValueKey('sheet-grabber'));
final _scroll = find.byKey(const ValueKey('adaptive-sheet-scroll'));
final _notes = find.descendant(
  of: find.byKey(const ValueKey('application-notes')),
  matching: find.byType(TextFormField),
);

Future<ProviderContainer> _open(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  double scale = 1,
  Brightness brightness = Brightness.light,
  bool reduceMotion = false,
  String? jobLink,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final data = fixtureSnapshot();
  if (jobLink != null) {
    (data['applications'] as List).first['link'] = jobLink;
  }
  await tester.pumpWidget(
    ProviderScope(
      overrides: [repositoryProvider.overrideWithValue(MemoryRepository(data))],
      child: MaterialApp(
        theme: appTheme(brightness),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scale),
            disableAnimations: reduceMotion,
          ),
          child: child!,
        ),
        home: Consumer(
          builder: (context, ref, _) {
            final state = ref.watch(appControllerProvider);
            return Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: state.ready
                      ? () => showApplicationDetailsSheet(
                          context,
                          state.applications.first,
                        )
                      : null,
                  child: const Text('Open details'),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  final container = ProviderScope.containerOf(
    tester.element(find.text('Open details')),
  );
  await tester.tap(find.text('Open details'));
  await tester.pumpAndSettle();
  return container;
}

double _size(WidgetTester tester) =>
    tester.widget<DraggableScrollableSheet>(_sheet).controller!.size;

Future<void> _toNotes(WidgetTester tester) async {
  final scope = AdaptiveSheetScope.of(
    tester.element(find.byType(ApplicationDetailsBody)),
  );
  scope.expand();
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(
    _notes,
    150,
    scrollable: find
        .descendant(of: _scroll, matching: find.byType(Scrollable))
        .first,
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('one status control and no size or Save buttons', (tester) async {
    await _open(tester);
    expect(find.byType(DraggableScrollableSheet), findsOneWidget);
    expect(find.text('Medium'), findsNothing);
    expect(find.text('Med'), findsNothing);
    expect(find.text('Large'), findsNothing);
    expect(find.text('Save changes'), findsNothing);
    expect(find.byType(DropdownButton<ApplicationStage>), findsNothing);
    expect(
      find.byKey(const ValueKey('application-status-control')),
      findsOneWidget,
    );
    expect(find.byType(ChoiceChip), findsNWidgets(5));
    expect(tester.widget<DraggableScrollableSheet>(_sheet).snapSizes, [
      0.55,
      0.95,
    ]);
    expect(_size(tester), closeTo(0.55, 0.005));
    await tester.tap(find.byTooltip('Close dialog'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('snap arrivals emit light haptics', (tester) async {
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          calls.add(call.arguments as String);
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
    await _open(tester);
    calls.clear();
    await tester.drag(_grabber, const Offset(0, -280));
    await tester.pumpAndSettle();
    await tester.drag(_grabber, const Offset(0, 180));
    await tester.pumpAndSettle();
    expect(calls, [
      'HapticFeedbackType.lightImpact',
      'HapticFeedbackType.lightImpact',
    ]);
    await tester.tap(find.byTooltip('Close dialog'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('job link shows the domain and launches the full stored URL', (
    tester,
  ) async {
    const channel = MethodChannel('plugins.flutter.io/url_launcher');
    String? launched;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      if (call.method == 'launch') {
        launched = (call.arguments as Map)['url'] as String;
      }
      return true;
    });
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      ),
    );
    const link = 'https://careers.example.com/jobs/42';
    await _open(tester, jobLink: link);
    AdaptiveSheetScope.of(tester.element(find.byType(ApplicationDetailsBody)))
        .expand();
    await tester.pumpAndSettle();
    expect(find.text('careers.example.com'), findsOneWidget);
    expect(find.text(link), findsNothing);
    await tester.tap(find.text('careers.example.com'));
    await tester.pumpAndSettle();
    expect(launched, link);
    await tester.tap(find.byTooltip('Close dialog'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'grabber drag expands, collapses, then dismisses without lifecycle assertions',
    (tester) async {
      await _open(tester);
      await tester.drag(_grabber, const Offset(0, -280));
      await tester.pumpAndSettle();
      expect(_size(tester), closeTo(0.95, 0.005));
      await tester.drag(_grabber, const Offset(0, 180));
      await tester.pumpAndSettle();
      expect(_size(tester), closeTo(0.55, 0.005));
      await tester.fling(_grabber, const Offset(0, 320), 1200);
      await tester.pumpAndSettle();
      expect(_sheet, findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'content expands before scrolling and hands downward drag back at top',
    (tester) async {
      await _open(tester);
      await tester.fling(find.text('Status'), const Offset(0, -160), 800);
      await tester.pumpAndSettle();
      expect(_size(tester), closeTo(0.95, 0.005));
      final scrollable = tester.state<ScrollableState>(
        find.descendant(of: _scroll, matching: find.byType(Scrollable)).first,
      );
      scrollable.position.jumpTo(0);
      await tester.pump();
      await tester.fling(find.text('Status'), const Offset(0, 120), 800);
      await tester.pumpAndSettle();
      expect(_size(tester), closeTo(0.55, 0.005));
      expect(scrollable.position.pixels, closeTo(0, 0.1));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('notes autosave shows Saved for two seconds', (tester) async {
    final container = await _open(tester);
    await _toNotes(tester);
    await tester.enterText(_notes, 'Interview on Tuesday');
    await tester.pump(const Duration(milliseconds: 351));
    await tester.pump(const Duration(milliseconds: 200));
    expect(container.read(appControllerProvider).applications.first.notes, [
      'Interview on Tuesday',
    ]);
    final indicator = find
        .ancestor(
          of: find.byKey(const ValueKey('notes-saved')),
          matching: find.byType(AnimatedOpacity),
        )
        .first;
    expect(tester.widget<AnimatedOpacity>(indicator).opacity, 1);
    await tester.pump(const Duration(seconds: 2));
    expect(tester.widget<AnimatedOpacity>(indicator).opacity, 0);
    await tester.tap(find.byTooltip('Close dialog'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'editing then scrim-dismiss before debounce flushes notes without disposed dependencies',
    (tester) async {
      final container = await _open(tester);
      await _toNotes(tester);
      await tester.enterText(_notes, 'Unsaved on pop');
      // Use the actual scrim, rather than calling pop directly.
      await tester.tapAt(const Offset(8, 8));
      await tester.pumpAndSettle();
      expect(_sheet, findsNothing);
      expect(container.read(appControllerProvider).applications.first.notes, [
        'Unsaved on pop',
      ]);
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(seconds: 3));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('dirty notes survive swipe dismissal and repeated reopening', (
    tester,
  ) async {
    final container = await _open(tester);
    for (var i = 0; i < 3; i++) {
      if (i > 0) {
        await tester.tap(find.text('Open details'));
        await tester.pumpAndSettle();
      }
      await _toNotes(tester);
      await tester.enterText(_notes, 'Pending note $i');
      tester
          .widget<EditableText>(
            find.descendant(of: _notes, matching: find.byType(EditableText)),
          )
          .focusNode
          .unfocus();
      final scrollable = tester.state<ScrollableState>(
        find.descendant(of: _scroll, matching: find.byType(Scrollable)).first,
      );
      scrollable.position.jumpTo(0);
      await tester.pump();
      await tester.fling(_grabber, const Offset(0, 900), 2400);
      await tester.pumpAndSettle();
      expect(_sheet, findsNothing);
      expect(container.read(appControllerProvider).applications.first.notes, [
        'Pending note $i',
      ]);
      expect(tester.takeException(), isNull);
    }
    await tester.pump(const Duration(seconds: 3));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'status chips save immediately and subsequent notes do not revert the stage',
    (tester) async {
      final container = await _open(tester);
      await tester.drag(
        find.byKey(const ValueKey('application-status-control')),
        const Offset(-140, 0),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, 'Interview'));
      await tester.pumpAndSettle();
      expect(
        container.read(appControllerProvider).applications.first.stage,
        ApplicationStage.interview,
      );
      await _toNotes(tester);
      await tester.enterText(_notes, 'Bring the portfolio');
      await tester.pump(const Duration(milliseconds: 351));
      final record = container.read(appControllerProvider).applications.first;
      expect(record.stage, ApplicationStage.interview);
      expect(record.notes, ['Bring the portfolio']);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Close dialog'));
      await tester.pumpAndSettle();
      expect(_sheet, findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'date picker, delete cancellation and confirmed delete use existing actions',
    (tester) async {
      final container = await _open(tester);
      await _toNotes(tester);
      await tester.scrollUntilVisible(
        find.text('Applied date'),
        -150,
        scrollable: find
            .descendant(of: _scroll, matching: find.byType(Scrollable))
            .first,
      );
      await tester.tap(find.text('Applied date'));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Delete application'),
        150,
        scrollable: find
            .descendant(of: _scroll, matching: find.byType(Scrollable))
            .first,
      );
      await tester.tap(find.text('Delete application'));
      await tester.pumpAndSettle();
      expect(find.text('Delete this application?'), findsOneWidget);
      expect(find.text("This can't be undone."), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(
        container
            .read(appControllerProvider)
            .applications
            .any((a) => a.id == 'a1'),
        isTrue,
      );
      await tester.tap(find.text('Delete application'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(_sheet, findsNothing);
      expect(
        container
            .read(appControllerProvider)
            .applications
            .any((a) => a.id == 'a1'),
        isFalse,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'grabber exposes Expand/Collapse semantics and reduced-motion resizing is immediate',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await _open(tester, reduceMotion: true);
      final node = tester.getSemantics(find.bySemanticsLabel('Resize sheet'));
      final ids = node.getSemanticsData().customSemanticsActionIds!;
      final labels = ids
          .map((id) => CustomSemanticsAction.getAction(id)!.label)
          .toList();
      expect(labels, containsAll(['Expand', 'Collapse']));
      final expandId = ids.firstWhere(
        (id) => CustomSemanticsAction.getAction(id)!.label == 'Expand',
      );
      final widget = tester.widget<Semantics>(
        find.ancestor(of: _grabber, matching: find.byType(Semantics)).first,
      );
      widget.properties.customSemanticsActions![CustomSemanticsAction.getAction(
        expandId,
      )]!();
      await tester.pump();
      expect(_size(tester), closeTo(0.95, 0.005));
      semantics.dispose();
      await tester.tap(find.byTooltip('Close dialog'));
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'rotation retains the resting detent and 360px floor after prior dragging',
    (tester) async {
      await _open(tester, scale: 1.3);
      await tester.drag(_grabber, const Offset(0, -280));
      await tester.pumpAndSettle();
      await tester.drag(_grabber, const Offset(0, 180));
      await tester.pumpAndSettle();
      expect(_size(tester), closeTo(0.55, 0.005));
      tester.view.physicalSize = const Size(844, 390);
      await tester.pumpAndSettle();
      expect(tester.getSize(_sheet).height, greaterThanOrEqualTo(360));
      expect(tester.takeException(), isNull);
      tester.view.physicalSize = const Size(390, 844);
      await tester.pumpAndSettle();
      expect(_size(tester), closeTo(0.55, 0.005));
      await tester.tap(find.byTooltip('Close dialog'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  for (final theme in Brightness.values) {
    testWidgets(
      'small screen text 1.3 and keyboard in $theme keep notes visible',
      (tester) async {
        await _open(
          tester,
          size: const Size(360, 640),
          scale: 1.3,
          brightness: theme,
        );
        expect(tester.getSize(_sheet).height, greaterThanOrEqualTo(360));
        await _toNotes(tester);
        await tester.tap(_notes);
        tester.view.viewInsets = const FakeViewPadding(bottom: 280);
        addTearDown(tester.view.resetViewInsets);
        await tester.pumpAndSettle();
        expect(_size(tester), closeTo(0.95, 0.005));
        expect(tester.getBottomLeft(_notes).dy, lessThanOrEqualTo(360));
        expect(tester.takeException(), isNull);
        tester.view.resetViewInsets();
        await tester.pumpAndSettle();
        expect(_size(tester), closeTo(0.95, 0.005));
        await tester.tap(find.byTooltip('Close dialog'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }
}
