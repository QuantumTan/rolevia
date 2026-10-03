import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rolevia/app.dart';
import 'package:rolevia/data/repositories/local_repository.dart';
import 'package:rolevia/state/app_state.dart';
import 'app_test.dart' show MemoryRepository;
import 'production_flows_test.dart' show resume, job;

void main() {
  testWidgets('empty ingestion, real comparison, export and tracker resume link', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    String? clipboard;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') clipboard = (call.arguments as Map)['text'] as String;
        if (call.method == 'Clipboard.hasStrings') return {'value': false};
        return null;
      });
    addTearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(SystemChannels.platform, null));
    final repository = MemoryRepository({...emptyWorkspace, 'onboardingComplete': true, 'authenticated': true,
      'defaultResumeId': 'resume-1', 'resumes': [resume('Developed Flutter applications using SQL and Docker.').toJson()]});
    await tester.pumpWidget(ProviderScope(overrides: [repositoryProvider.overrideWithValue(repository)], child: const AppBootstrap()));
    await tester.pumpAndSettle();
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, isEmpty);
    expect(find.text('Use example'), findsNothing);
    await tester.enterText(find.byType(TextField), 'Role: Developer\nCompany: Employer\nDevelop Flutter applications using SQL and Docker.');
    tester.testTextInput.hide();
    await tester.ensureVisible(find.text('Run Analysis'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Run Analysis'));
    await tester.pumpAndSettle();
    expect(find.text('Analysis Results'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Export Report'), 350, scrollable: find.byType(Scrollable).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Export Report'));
    await tester.pumpAndSettle();
    expect(clipboard, contains('# Match report: Developer'));
    await tester.ensureVisible(find.text('Add to tracker'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add to tracker'));
    await tester.pumpAndSettle();
    final state = ProviderScope.containerOf(tester.element(find.byType(AppBootstrap))).read(appControllerProvider);
    expect(state.matches, hasLength(1));
    expect(state.applications.single.resumeId, 'resume-1');
    expect(state.applications.single.jobId, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Instant Match updates card in place with a real comparison', (tester) async {
    final repository = MemoryRepository({...emptyWorkspace, 'onboardingComplete': true, 'authenticated': true,
      'defaultResumeId': 'resume-1', 'resumes': [resume('Flutter SQL Docker development').toJson()],
      'jobs': [job().toJson()]});
    await tester.pumpWidget(ProviderScope(overrides: [repositoryProvider.overrideWithValue(repository)], child: const AppBootstrap()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discover'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byTooltip('Instant Match'), 250, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Instant Match'));
    await tester.pumpAndSettle();
    final state = ProviderScope.containerOf(tester.element(find.byType(AppBootstrap))).read(appControllerProvider);
    expect(state.matches.single.jobId, 'job-1');
    expect(state.jobs.single.matchScore, state.matches.single.overall);
    expect(find.text('Analysis Results'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
