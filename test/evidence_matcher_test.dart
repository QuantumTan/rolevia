import 'package:flutter_test/flutter_test.dart';
import 'package:rolevia/core/matching/evidence_matcher.dart';
import 'package:rolevia/models/matching_models.dart';
import 'package:rolevia/models/models.dart';

ResumeVersion resume(String text) => ResumeVersion(
  id: 'resume',
  title: 'Resume',
  filename: 'resume.pdf',
  fileType: 'PDF',
  addedAt: DateTime(2025),
  isSample: false,
  extractedText: text,
);

void main() {
  test('contextual project evidence outranks a skills-list mention', () {
    final analysis = EvidenceMatcher.analyze(
      resume: resume('''
Skills
Docker

Projects
- Containerized a Flutter API with Docker and reduced setup time.
'''),
      jobText: 'Requirements\n- Docker experience',
    );

    expect(analysis.matches.single.verdict, EvidenceVerdict.strong);
    expect(analysis.matches.single.evidence!.section, 'Projects');
  });

  test('a skills-list-only hit receives mention only', () {
    final analysis = EvidenceMatcher.analyze(
      resume: resume('Skills\nDocker, Flutter, Git'),
      jobText: 'Requirements\n- Docker experience',
    );

    expect(analysis.matches.single.verdict, EvidenceVerdict.mentionOnly);
  });

  test('negation prevents a keyword from becoming evidence', () {
    final analysis = EvidenceMatcher.analyze(
      resume: resume('Experience\n- No experience with Docker.'),
      jobText: 'Requirements\n- Docker experience',
    );

    expect(analysis.matches.single.verdict, EvidenceVerdict.missing);
    expect(analysis.matches.single.reason, contains('explicitly says'));
  });

  test('related technology is classified as transferable', () {
    final analysis = EvidenceMatcher.analyze(
      resume: resume(
        'Projects\n- Built reporting queries and indexes in PostgreSQL.',
      ),
      jobText: 'Requirements\n- MySQL',
    );

    expect(analysis.matches.single.verdict, EvidenceVerdict.transferable);
  });

  test('seniority mismatch is visible and changes the score', () {
    final analysis = EvidenceMatcher.analyze(
      resume: resume(
        'Experience\nJunior Flutter Developer\n2024 - Present\n- Developed Flutter screens.',
      ),
      jobText: 'Senior Flutter Developer\nRequirements\n- Flutter',
      now: DateTime(2025, 1),
    );

    expect(analysis.breakdown.seniorityMismatch, isTrue);
    expect(analysis.breakdown.overall, lessThan(100));
  });
}
