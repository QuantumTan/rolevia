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
    final values = filterJobs(jobs: seedJobs, query: 'flutter');
    expect(values.map((e) => e.id), ['j1']);

    final bpoJobs = filterJobs(jobs: seedJobs, categoryFilters: {'BPO'});
    expect(bpoJobs.any((j) => j.id == 'j4'), isTrue);
  });

  test('match validation identifies missing input', () {
    expect(validateMatch(resumeId: null), 'Choose a resume to continue.');
    expect(validateMatch(resumeId: 'r1', pasted: ''), isNotNull);
    expect(
      validateMatch(
        resumeId: 'r1',
        pasted: 'Northwind Digital is hiring a Junior Flutter Developer in Davao City.',
      ),
      isNull,
    );
  });

  test('stage counts and submitted definition stay consistent', () {
    final counts = stageCounts(seedApplications);
    expect(counts.values.reduce((a, b) => a + b), seedApplications.length);
    // wishlist count vs active applications
    expect(
      seedApplications
          .where((a) => a.stage != ApplicationStage.wishlist)
          .length,
      3,
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

  testWidgets('Job Matcher smoke flow renders and navigates to match', (
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

    // Default tab after authentication is Match
    expect(find.text('Job Matcher'), findsWidgets);
    expect(find.text('Find my match'), findsOneWidget);
    expect(find.text('3 scans left'), findsOneWidget);

    // Switch to Discover
    await tester.tap(find.text('Discover'));
    await tester.pumpAndSettle();
    expect(find.text('Junior Flutter Developer'), findsOneWidget);

    // Switch to Tracker
    await tester.tap(find.text('Tracker'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Applied'), findsWidgets);
  });
}
