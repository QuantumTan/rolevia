import 'dart:io';

import 'package:rolevia/core/matching/evidence_matcher.dart';
import 'package:rolevia/models/matching_models.dart';
import 'package:rolevia/models/models.dart';

import '../test/fixtures/matching/matching_fixture.dart';

void main() {
  stdout.writeln('======================================================');
  stdout.writeln('Rolevia Evidence Matching Evaluation Report');
  stdout.writeln('======================================================\n');

  final fixtures = MatchingFixtureLoader.loadAll();
  stdout.writeln('Loaded ${fixtures.length} matching fixtures.\n');

  var totalPassed = 0;
  var totalFailed = 0;
  final results = <Map<String, dynamic>>[];

  for (final fixture in fixtures) {
    final analysis = EvidenceMatcher.analyze(
      resume: ResumeVersion(
        id: 'eval-${fixture.id}',
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

    final actualScore = analysis.breakdown.overall;
    final inScoreRange =
        actualScore >= fixture.minScore && actualScore <= fixture.maxScore;
    final expectedMid = ((fixture.minScore + fixture.maxScore) / 2).round();
    final scoreDelta = actualScore - expectedMid;

    var verdictsPassed = true;
    final verdictReports = <String>[];

    for (final entry in fixture.expectedVerdicts.entries) {
      final query = entry.key.toLowerCase();
      final match = analysis.matches
          .cast<RequirementEvidenceMatch?>()
          .firstWhere(
            (m) =>
                m != null &&
                (m.requirement.text.toLowerCase().contains(query) ||
                    m.requirement.normalizedSkills.any(
                      (s) => s.contains(query.replaceAll(' ', '_')),
                    )),
            orElse: () => null,
          );

      if (match == null) {
        verdictsPassed = false;
        verdictReports.add(
          '  ❌ [MISSING REQ] "${entry.key}" was not extracted',
        );
      } else {
        final actualVerdict = match.verdict.name;
        final isMatch = actualVerdict == entry.value;
        if (!isMatch) verdictsPassed = false;
        final mark = isMatch ? '✔' : '❌';
        final quoteInfo = match.evidence != null
            ? ' (Quote: "${match.evidence!.quote}")'
            : '';
        verdictReports.add(
          '  $mark "${match.requirement.text}" => actual: $actualVerdict, expected: ${entry.value}$quoteInfo',
        );
      }
    }

    var flagsPassed = true;
    final flagReports = <String>[];
    if (fixture.expectedFlags.containsKey('keywordStuffingFlag')) {
      final expected = fixture.expectedFlags['keywordStuffingFlag']!;
      final actual = analysis.breakdown.keywordStuffingFlag;
      if (expected != actual) flagsPassed = false;
      flagReports.add(
        '  ${expected == actual ? '✔' : '❌'} Keyword stuffing flag: actual $actual, expected $expected',
      );
    }
    if (fixture.expectedFlags.containsKey('seniorityMismatch')) {
      final expected = fixture.expectedFlags['seniorityMismatch']!;
      final actual = analysis.breakdown.seniorityMismatch;
      if (expected != actual) flagsPassed = false;
      flagReports.add(
        '  ${expected == actual ? '✔' : '❌'} Seniority mismatch flag: actual $actual, expected $expected',
      );
    }

    var confidencePassed = true;
    if (fixture.expectedConfidence != null) {
      final actualConf = analysis.breakdown.confidence.name;
      if (actualConf != fixture.expectedConfidence) {
        confidencePassed = false;
      }
      flagReports.add(
        '  ${confidencePassed ? '✔' : '❌'} Confidence: actual $actualConf, expected ${fixture.expectedConfidence}',
      );
    }

    final passed =
        inScoreRange && verdictsPassed && flagsPassed && confidencePassed;
    if (passed) {
      totalPassed++;
    } else {
      totalFailed++;
    }

    results.add({
      'id': fixture.id,
      'name': fixture.name,
      'passed': passed,
      'actualScore': actualScore,
      'expectedMin': fixture.minScore,
      'expectedMax': fixture.maxScore,
      'scoreDelta': scoreDelta,
      'verdictReports': verdictReports,
      'flagReports': flagReports,
    });
  }

  for (final res in results) {
    final status = res['passed'] == true ? 'PASS' : 'FAIL';
    final id = res['id'];
    final name = res['name'];
    final actualScore = res['actualScore'];
    final min = res['expectedMin'];
    final max = res['expectedMax'];
    final delta = res['scoreDelta'] as int;
    final deltaStr = delta >= 0 ? '+$delta' : '$delta';

    stdout.writeln('------------------------------------------------------');
    stdout.writeln('[$status] $id: $name');
    stdout.writeln(
      'Score: $actualScore (Expected: $min-$max, Delta from mid: $deltaStr)',
    );
    stdout.writeln('Verdicts:');
    for (final line in res['verdictReports'] as List<String>) {
      stdout.writeln(line);
    }
    if ((res['flagReports'] as List<String>).isNotEmpty) {
      stdout.writeln('Flags & Confidence:');
      for (final line in res['flagReports'] as List<String>) {
        stdout.writeln(line);
      }
    }
  }

  stdout.writeln('\n======================================================');
  stdout.writeln(
    'Summary: $totalPassed passed, $totalFailed failed out of ${fixtures.length} fixtures.',
  );
  stdout.writeln('======================================================');

  if (totalFailed > 0) {
    exit(1);
  }
}
