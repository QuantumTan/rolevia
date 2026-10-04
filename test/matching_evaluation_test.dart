import 'package:flutter_test/flutter_test.dart';
import 'package:rolevia/core/matching/evidence_matcher.dart';
import 'package:rolevia/models/models.dart';

import 'fixtures/matching/matching_fixture.dart';

void main() {
  group('Matching Fixture Evaluation Suite', () {
    final fixtures = MatchingFixtureLoader.loadAll();

    test('loads at least 15 required scenarios', () {
      expect(fixtures.length, greaterThanOrEqualTo(15));
    });

    for (final fixture in fixtures) {
      test('Scenario ${fixture.id}: ${fixture.name}', () {
        final analysis = EvidenceMatcher.analyze(
          resume: ResumeVersion(
            id: 'resume-${fixture.id}',
            title: fixture.name,
            filename: 'resume.pdf',
            fileType: 'PDF',
            addedAt: DateTime(2025),
            isSample: false,
            extractedText: fixture.resumeText,
          ),
          jobText: fixture.jobText,
          now: fixture.referenceDate ?? DateTime(2025, 1, 1),
        );

        // Check overall score range
        expect(
          analysis.breakdown.overall,
          greaterThanOrEqualTo(fixture.minScore),
          reason:
              'Score ${analysis.breakdown.overall} was below expected min ${fixture.minScore} for ${fixture.id}',
        );
        expect(
          analysis.breakdown.overall,
          lessThanOrEqualTo(fixture.maxScore),
          reason:
              'Score ${analysis.breakdown.overall} was above expected max ${fixture.maxScore} for ${fixture.id}',
        );

        // Check expected verdicts
        for (final entry in fixture.expectedVerdicts.entries) {
          final query = entry.key.toLowerCase();
          final matchingRequirement = analysis.matches.firstWhere(
            (m) =>
                m.requirement.text.toLowerCase().contains(query) ||
                m.requirement.normalizedSkills.any(
                  (s) => s.contains(query.replaceAll(' ', '_')),
                ),
            orElse: () => throw TestFailure(
              'No requirement found matching "${entry.key}" in ${fixture.id}. Available: ${analysis.requirements.map((r) => r.text).toList()}',
            ),
          );
          expect(
            matchingRequirement.verdict.name,
            entry.value,
            reason:
                'Verdict mismatch for "${entry.key}" in ${fixture.id}. Actual: ${matchingRequirement.verdict.name}, Expected: ${entry.value}',
          );
        }

        // Check expected flags
        if (fixture.expectedFlags.containsKey('keywordStuffingFlag')) {
          expect(
            analysis.breakdown.keywordStuffingFlag,
            fixture.expectedFlags['keywordStuffingFlag'],
            reason: 'keywordStuffingFlag mismatch in ${fixture.id}',
          );
        }
        if (fixture.expectedFlags.containsKey('seniorityMismatch')) {
          expect(
            analysis.breakdown.seniorityMismatch,
            fixture.expectedFlags['seniorityMismatch'],
            reason: 'seniorityMismatch mismatch in ${fixture.id}',
          );
        }

        // Check expected confidence if specified
        if (fixture.expectedConfidence != null) {
          expect(
            analysis.breakdown.confidence.name,
            fixture.expectedConfidence,
            reason: 'Confidence mismatch in ${fixture.id}',
          );
        }
      });
    }
  });
}
