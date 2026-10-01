import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rolevia/app.dart';
import 'package:rolevia/data/demo_repository.dart';
import 'package:rolevia/data/fixtures.dart';
import 'package:rolevia/models/models.dart';
import 'package:rolevia/state/app_state.dart';

class MemoryRepository implements DemoRepository {
  MemoryRepository([this.value]);
  Map<String, dynamic>? value;
  @override
  Future<Map<String, dynamic>?> read() async => value;
  @override
  Future<void> write(Map<String, dynamic> data) async => value = data;
  @override
  Future<void> clear() async => value = null;
}

void main() {
  test('search and filters return only matching jobs', () {
    final values = filterJobs(
      jobs: seedJobs,
      query: 'flutter',
      modes: {WorkMode.hybrid},
      minimumSalary: 100000,
    );
    expect(values.map((e) => e.id), ['j1']);
    expect(
      filterJobs(jobs: seedJobs, savedOnly: true, savedIds: {'j5'}).single.id,
      'j5',
    );
  });

  test('match validation identifies each missing input', () {
    expect(validateMatch(), 'Choose a resume to continue.');
    expect(validateMatch(resumeId: 'r1'), 'Choose a job to continue.');
    expect(
      validateMatch(resumeId: 'r1', pastedMode: true, pasted: 'short'),
      contains('40 characters'),
    );
    expect(validateMatch(resumeId: 'r1', jobId: 'j1'), isNull);
  });

  test('stage counts and submitted definition stay consistent', () {
    final counts = stageCounts(seedApplications);
    expect(counts.values.reduce((a, b) => a + b), seedApplications.length);
    expect(
      seedApplications.where((a) => a.stage != ApplicationStage.saved).length,
      6,
    );
  });

  test(
    'linked job tracking prevents duplicates and persists round-trip',
    () async {
      final repo = MemoryRepository(fixtureSnapshot());
      final container = ProviderContainer(
        overrides: [repositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      while (!container.read(appControllerProvider).ready) {
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }
      final controller = container.read(appControllerProvider.notifier);
      final before = container.read(appControllerProvider).applications.length;
      controller.trackJob(seedJobs.first);
      expect(container.read(appControllerProvider).applications.length, before);
      controller.toggleSaved('j2');
      await Future<void>.delayed(const Duration(milliseconds: 5));
      expect((await repo.read())!['savedJobIds'], contains('j2'));
      final restored = ProviderContainer(
        overrides: [repositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(restored.dispose);
      while (!restored.read(appControllerProvider).ready) {
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }
      expect(restored.read(appControllerProvider).savedJobIds, contains('j2'));
    },
  );

  testWidgets('Discover to Match to Results to Tracker smoke flow', (
    tester,
  ) async {
    final data = fixtureSnapshot()
      ..addAll({'onboardingComplete': true, 'authenticated': true});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          repositoryProvider.overrideWithValue(MemoryRepository(data)),
        ],
        child: const AppBootstrap(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Discover'), findsWidgets);
    await tester.ensureVisible(find.text('Flutter Developer').first);
    await tester.tap(find.text('Flutter Developer').first);
    await tester.pumpAndSettle();
    expect(find.text('Job details'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Match my resume'), 400);
    await tester.tap(find.text('Match my resume'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Analyze demo match'));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Demo analysis'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Add related job to Tracker'),
      400,
    );
    await tester.drag(find.byType(ListView).last, const Offset(0, -120));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add related job to Tracker'));
    await tester.pump();
    expect(find.textContaining('Tracker'), findsWidgets);
  });
}
