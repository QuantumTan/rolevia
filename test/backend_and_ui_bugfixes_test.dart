import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:rolevia/core/services/pdf_extractor_service.dart';
import 'package:rolevia/data/local/app_database.dart';
import 'package:rolevia/data/repositories/local_repository.dart';
import 'package:rolevia/models/models.dart';
import 'package:rolevia/state/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Backend and Data Resiliency Bug Fixes', () {
    test('Job.fromJson safely parses floating point values from external APIs', () {
      final json = <String, dynamic>{
        'id': 'job-float-1',
        'role': 'Full Stack Developer',
        'company': 'Tech Corp',
        'location': 'Taguig',
        'mode': 'remote',
        'type': 'fullTime',
        'posted_days': 3.0,
        'match_score': 88.0,
        'salary_min': 45000.0,
        'salary_max': 90000.0,
        'distance_km': 12.5,
        'skills': ['Flutter', 'Dart'],
        'overview': 'Exciting role',
        'responsibilities': ['Build apps'],
        'qualifications': ['2+ years experience'],
      };

      final job = Job.fromJson(json);
      expect(job.id, 'job-float-1');
      expect(job.postedDays, 3);
      expect(job.matchScore, 88);
      expect(job.salaryMin, 45000);
      expect(job.salaryMax, 90000);
      expect(job.distanceKm, 12.5);
    });

    test('ResumeVersion.fromJson handles null dates and list items safely', () {
      final json = <String, dynamic>{
        'id': 'res-1',
        'title': 'My Resume',
        'filename': 'resume.pdf',
        'fileType': 'PDF',
        'addedAt': null,
        'atsStatus': null,
        'experience': ['Developed apps', 123],
        'skills': ['Flutter', 'Dart'],
      };

      final resume = ResumeVersion.fromJson(json);
      expect(resume.id, 'res-1');
      expect(resume.atsStatus, 'ATS OK');
      expect(resume.experience, ['Developed apps', '123']);
      expect(resume.addedAt, isA<DateTime>());
    });

    test('ApplicationRecord.fromJson handles unknown stage and null dates safely', () {
      final json = <String, dynamic>{
        'id': 'app-1',
        'company': 'BPO Global',
        'role': 'Support Engineer',
        'location': 'Cebu',
        'appliedAt': null,
        'stage': 'unknown_stage_value',
        'salaryOffered': 50000.0,
        'followUpAt': 'not-a-valid-date',
      };

      final app = ApplicationRecord.fromJson(json);
      expect(app.id, 'app-1');
      expect(app.stage, ApplicationStage.applied);
      expect(app.salaryOffered, 50000);
      expect(app.followUpAt, isNull);
      expect(app.appliedAt, isA<DateTime>());
    });

    test('MatchResult.fromJson parses floating-point component scores and null suggestions safely', () {
      final json = <String, dynamic>{
        'id': 'match-1',
        'resumeId': 'res-1',
        'jobLabel': 'Dev - Tech',
        'createdAt': null,
        'overall': 92.4,
        'components': {
          'Must-have evidence': 95.0,
          'Nice-to-have evidence': 85.0,
        },
        'matched': ['Flutter'],
        'missing': ['Docker'],
        'strengths': ['Fast learner'],
        'gaps': ['Containerization'],
        'suggestions': [
          {'original': 'Wrote code', 'suggested': 'Engineered system'},
          null,
        ],
      };

      final result = MatchResult.fromJson(json);
      expect(result.id, 'match-1');
      expect(result.overall, 92);
      expect(result.components['Must-have evidence'], 95);
      expect(result.components['Nice-to-have evidence'], 85);
      expect(result.suggestions.length, 1);
      expect(result.suggestions.first.original, 'Wrote code');
    });

    test('LocalRepository.resumeText safely returns empty string when resume does not exist', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final repo = LocalRepository(db, 'user-test');

      final text = await repo.resumeText('non-existent-id');
      expect(text, '');

      await repo.close();
    });

    test('LocalRepository.watchOutboxCount emits correct queue length', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final repo = LocalRepository(db, 'user-test');

      expect(await repo.watchOutboxCount().first, 0);

      await repo.enqueue('resumes', 'upsert', {'id': 'r1'});
      expect(await repo.watchOutboxCount().first, 1);

      await repo.close();
    });

    test('AppController.addResume deduplicates resumes by ID and updateResume updates in place', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final repo = LocalRepository(db, 'user-test');

      final container = ProviderContainer(
        overrides: [
          repositoryProvider.overrideWithValue(repo),
        ],
      );

      final resume1 = ResumeVersion(
        id: 'res-unique',
        title: 'Initial Title',
        filename: 'resume.pdf',
        fileType: 'PDF',
        addedAt: DateTime.now(),
        isSample: false,
        atsStatus: 'ATS OK',
        extractedText: 'Initial text',
      );

      container.read(appControllerProvider.notifier).addResume(resume1);
      expect(container.read(appControllerProvider).resumes.length, 1);

      final resume1Updated = resume1.copyWith(title: 'Updated Title');
      // Calling addResume with the same ID should replace, not duplicate
      container.read(appControllerProvider.notifier).addResume(resume1Updated);
      expect(container.read(appControllerProvider).resumes.length, 1);
      expect(container.read(appControllerProvider).resumes.first.title, 'Updated Title');

      // Calling updateResume directly
      final resume1Final = resume1.copyWith(title: 'Final Title');
      container.read(appControllerProvider.notifier).updateResume(resume1Final);
      expect(container.read(appControllerProvider).resumes.length, 1);
      expect(container.read(appControllerProvider).resumes.first.title, 'Final Title');

      await pumpEventQueue();
      container.dispose();
      await repo.close();
    });

    test('AppController.toggleOffline safely handles analysis errors and refunds scan quota', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final repo = LocalRepository(db, 'user-test');

      final container = ProviderContainer(
        overrides: [
          repositoryProvider.overrideWithValue(repo),
        ],
      );

      // Queue an offline analysis with an invalid / empty job text that fails parsing
      final resume = ResumeVersion(
        id: 'res-offline',
        title: 'Offline Resume',
        filename: 'resume.pdf',
        fileType: 'PDF',
        addedAt: DateTime.now(),
        isSample: false,
        atsStatus: 'ATS OK',
        extractedText: 'Some valid resume extracted text here for testing',
      );
      container.read(appControllerProvider.notifier).addResume(resume);

      final initialQuota = container.read(appControllerProvider).profile.scanQuota;
      container.read(appControllerProvider.notifier).toggleOffline(true);
      container.read(appControllerProvider.notifier).queueOfflineAnalysis(
        jobText: 'Too short', // Under 5 words, will fail validation
        resumeId: 'res-offline',
      );

      // Reconnect
      container.read(appControllerProvider.notifier).toggleOffline(false);

      // Quota should remain intact (consumed then refunded due to error)
      expect(container.read(appControllerProvider).profile.scanQuota, initialQuota);
      // Queued job text should be cleared
      expect(container.read(appControllerProvider).queuedJobText, isNull);

      await pumpEventQueue();
      container.dispose();
      await repo.close();
    });

    test('extractPdfText accepts PDF with header offset within 1024 bytes', () {
      // PDF standard allows leading whitespace or UTF-8 BOM before %PDF-
      final pdfContent = '   \n\r%PDF-1.4\n1 0 obj\n<<>>\nendobj\ntrailer\n<<>>\n%%EOF';
      final bytes = Uint8List.fromList(utf8.encode(pdfContent));

      // Should not throw 'Invalid PDF signature.'
      try {
        extractPdfText(bytes);
      } catch (e) {
        // May fail inside PdfDocument constructor on synthetic PDF, but must pass signature check
        expect(e.toString(), isNot(contains('Invalid PDF signature.')));
      }
    });
  });
}
