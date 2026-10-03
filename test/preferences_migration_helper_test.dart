import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rolevia/data/local/app_database.dart';
import 'package:rolevia/data/local/preferences_migration_helper.dart';
import 'package:rolevia/data/repositories/local_repository.dart';
import 'package:uuid/uuid.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late LocalRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = LocalRepository(db, 'device');
  });

  tearDown(() async {
    await repo.close();
  });

  group('PreferencesMigrationHelper', () {
    test('seeds fixture data if database and SharedPreferences are empty', () async {
      SharedPreferences.setMockInitialValues({});
      await PreferencesMigrationHelper.migrate(repo);

      final state = await repo.read();
      expect(state['seeded'], isTrue);
      expect((state['resumes'] as List).isNotEmpty, isTrue);
      expect((state['applications'] as List).isNotEmpty, isTrue);
      expect((state['matches'] as List).isNotEmpty, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey(PreferencesMigrationHelper.legacyKey), isFalse);
    });

    test('migrates legacy SharedPreferences blob to Drift database and creates backup', () async {
      final legacyPayload = {
        'onboardingComplete': true,
        'defaultResumeId': 'legacy-resume-1',
        'resumes': [
          {
            'id': 'legacy-resume-1',
            'title': 'Legacy Resume',
            'filename': 'resume.pdf',
            'fileType': 'application/pdf',
            'atsStatus': 'ATS OK',
            'addedAt': DateTime.now().toUtc().toIso8601String(),
          }
        ],
        'applications': [
          {
            'id': 'legacy-app-1',
            'jobId': null,
            'company': 'Legacy Corp',
            'role': 'Flutter Specialist',
            'location': 'Taguig',
            'stage': 'Applied',
            'matchBadge': 'High match',
            'link': 'https://example.com/apply',
            'notes': ['Sent initial portfolio'],
            'appliedAt': DateTime.now().toUtc().toIso8601String(),
            'updatedAt': DateTime.now().toUtc().toIso8601String(),
          }
        ],
        'matches': [
          {
            'id': 'legacy-match-1',
            'resumeId': 'legacy-resume-1',
            'jobId': null,
            'role': 'Flutter Specialist',
            'company': 'Legacy Corp',
            'overall': 92,
            'components': {'skills': 90, 'experience': 95},
            'matched': ['Flutter', 'Dart'],
            'missing': <String>[],
            'suggestions': ['Ready to apply'],
            'createdAt': DateTime.now().toUtc().toIso8601String(),
          }
        ]
      };

      SharedPreferences.setMockInitialValues({
        PreferencesMigrationHelper.legacyKey: jsonEncode(legacyPayload),
      });

      await PreferencesMigrationHelper.migrate(repo);

      final state = await repo.read();
      expect(state['legacyMigrated'], isTrue);
      expect(state['onboardingComplete'], isTrue);

      final resumes = state['resumes'] as List;
      expect(resumes.length, equals(1));
      final migratedResumeId = resumes.first['id'] as String;
      expect(Uuid.isValidUUID(fromString: migratedResumeId), isTrue);
      expect(resumes.first['title'], equals('Legacy Resume'));

      final applications = state['applications'] as List;
      expect(applications.length, equals(1));
      expect(applications.first['company'], equals('Legacy Corp'));
      expect(Uuid.isValidUUID(fromString: applications.first['id'] as String), isTrue);

      final matches = state['matches'] as List;
      expect(matches.length, equals(1));
      expect(matches.first['resumeId'], equals(migratedResumeId));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey(PreferencesMigrationHelper.legacyKey), isFalse);
      expect(
        prefs.containsKey('${PreferencesMigrationHelper.legacyKey}_migrated_backup'),
        isTrue,
      );

      // Running migration again must be idempotent and preserve existing records
      await PreferencesMigrationHelper.migrate(repo);
      final stateAfterSecondRun = await repo.read();
      expect((stateAfterSecondRun['resumes'] as List).length, equals(1));
    });
  });
}
