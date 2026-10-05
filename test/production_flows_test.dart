import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rolevia/core/services/job_ingestion.dart';
import 'package:rolevia/core/services/location_service.dart';
import 'package:rolevia/core/services/match_analyzer.dart';
import 'package:rolevia/data/local/app_database.dart';
import 'package:rolevia/data/repositories/local_repository.dart';
import 'package:rolevia/models/models.dart';
import 'package:rolevia/state/app_state.dart';
import 'app_test.dart' show MemoryRepository;

ResumeVersion resume(String text) => ResumeVersion(id: 'resume-1', title: 'My resume',
  filename: 'resume.pdf', fileType: 'PDF', addedAt: DateTime(2026), isSample: false,
  extractedText: text, atsChecks: const {'Readable font size': true, 'One or two pages': false});

Job job({String id = 'job-1', double? latitude, double? longitude, int? min, int? max}) => Job(
  id: id, role: 'Developer', company: 'Employer', location: 'Taguig', mode: WorkMode.onSite,
  type: EmploymentType.fullTime, postedDays: 1, skills: const ['Flutter', 'SQL', 'Docker'],
  overview: 'Develop Flutter applications using SQL and Docker.', responsibilities: const [],
  qualifications: const [], latitude: latitude, longitude: longitude, salaryMin: min, salaryMax: max);

void main() {
  test('sanitizes clipboard and detects labeled role without inventing metadata', () {
    final input = JobIngestion('Job title: Developer\r\nCompany: Employer\u200b\r\n Flutter\t SQL');
    expect(input.title, 'Developer'); expect(input.company, 'Employer');
    expect(input.text, isNot(contains('\u200b')));
    expect(input.words, 7); expect(input.readingMinutes, 1);
    expect(JobIngestion('Write good code').company, isNull);
  });

  test('comparison depends on real text and never generates metrics', () {
    final description = job();
    final strong = MatchAnalyzer.analyze(resume: resume('Develop Flutter applications using SQL and Docker.'),
      job: description, text: jobText(description));
    final weak = MatchAnalyzer.analyze(resume: resume('Organized classroom activities for students.'),
      job: description, text: jobText(description));
    expect(strong.overall, greaterThan(weak.overall));
    expect(strong.matched.map((s) => s.toLowerCase()), contains('flutter'));
    expect(weak.missing.map((s) => s.toLowerCase()), contains('docker'));
    expect(strong.suggestions, isEmpty);
    expect(strong.components.values.every((n) => n >= 0 && n <= 100), isTrue);
    expect(strong.atsChecks['One or two pages'], isFalse);
    expect(strong.markdownReport, contains('One or two pages: Review'));
    expect(() => MatchAnalyzer.analyze(resume: resume(''), text: jobText(description)), throwsFormatException);
  });

  test('geographic and salary filters combine and require a chosen location', () {
    final jobs = [job(latitude: 14.55, longitude: 121.02, min: 25000, max: 30000),
      job(id: 'far', latitude: 7.1, longitude: 125.6, min: 55000, max: 60000),
      job(id: 'unknown')];
    expect(filterJobs(jobs: jobs, nearMeOnly: true), isEmpty);
    final values = filterJobs(jobs: jobs, nearMeOnly: true, maxRadiusKm: 10,
      userLocation: PhilippineHubs.taguig, minimumSalary: 20000, maximumSalary: 35000);
    expect(values.map((j) => j.id), ['job-1']);
    expect(values.single.distanceKm, isNotNull);
    expect(job(min: 20000).salaryLabel, contains('20000+'));
  });

  test('fresh controller has no fixtures; tracker keeps the analyzed resume', () async {
    final repository = MemoryRepository();
    final container = ProviderContainer(overrides: [repositoryProvider.overrideWithValue(repository)]);
    addTearDown(container.dispose);
    while (!container.read(appControllerProvider).ready) { await Future<void>.delayed(Duration.zero); }
    final initial = container.read(appControllerProvider);
    expect(initial.jobs, isEmpty); expect(initial.resumes, isEmpty); expect(initial.matches, isEmpty);
    expect(initial.matchJobText, isEmpty); expect(initial.defaultResumeId, isNull);
    final app = container.read(appControllerProvider.notifier);
    app.addResume(resume('Flutter SQL Docker development'));
    final match = app.analyze(resumeId: 'resume-1', pasted: 'Role: Developer\nCompany: Employer\nBuild Flutter applications using SQL and Docker.');
    final record = app.trackMatch(match);
    expect(record.resumeId, 'resume-1'); expect(record.jobId, isNull);
    expect(record.stage, ApplicationStage.wishlist);
    expect(app.trackMatch(match).id, record.id);
    app.deleteResume('resume-1');
    expect(container.read(appControllerProvider).defaultResumeId, isNull);
    expect(container.read(appControllerProvider).selectedMatchResumeId, isNull);
  });

  test('Drift round trip retains extraction, report, interview, salary and resume link', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = LocalRepository(db, 'device');
    addTearDown(repo.close);
    final original = resume('Flutter SQL Docker development');
    final result = MatchAnalyzer.analyze(resume: original, job: job(), text: jobText(job()));
    final appointment = DateTime(2026, 11, 12, 9, 30);
    final record = ApplicationRecord(id: 'application', company: 'Employer', role: 'Developer', location: 'Taguig',
      appliedAt: DateTime(2026), stage: ApplicationStage.offer, resumeId: original.id,
      interviewAt: appointment, salaryOffered: 45000);
    await repo.write({...emptyWorkspace, 'resumes': [original.toJson()], 'matches': [result.toJson()],
      'applications': [record.toJson()]});
    final restored = await repo.read();
    expect(ResumeVersion.fromJson(restored['resumes'][0]).extractedText, original.extractedText);
    expect(MatchResult.fromJson(restored['matches'][0]).overall, result.overall);
    final restoredRecord = ApplicationRecord.fromJson(restored['applications'][0]);
    expect(restoredRecord.interviewAt, appointment); expect(restoredRecord.salaryOffered, 45000);
    expect(restoredRecord.resumeId, original.id);
    expect(restoredRecord.copyWith(clearInterview: true, clearSalary: true).interviewAt, isNull);
  });
}
