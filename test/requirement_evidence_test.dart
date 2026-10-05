import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rolevia/core/theme.dart';
import 'package:rolevia/core/widgets/requirement_evidence.dart';
import 'package:rolevia/features/detail_screens.dart';
import 'package:rolevia/models/matching_models.dart';
import 'package:rolevia/models/models.dart';
import 'package:rolevia/state/app_state.dart';

import 'app_test.dart' show MemoryRepository;

void main() {
  final testMatch = RequirementEvidenceMatch(
    requirement: const JobRequirement(
      id: 'req_flutter',
      text: 'Production Flutter and Dart experience',
      category: RequirementCategory.hardSkill,
      priority: RequirementPriority.mustHave,
      minimumYears: 2.0,
      normalizedSkills: ['flutter', 'dart'],
    ),
    verdict: EvidenceVerdict.strong,
    reason: 'Resume demonstrates 3 years building production Flutter apps with high test coverage.',
    confidence: AnalysisConfidence.high,
    evidence: const ResumeEvidence(
      quote: 'Architected Riverpod state management and offline sync for 50k DAU Flutter app',
      section: 'Work Experience',
      role: 'Senior Mobile Engineer',
      confidence: AnalysisConfidence.high,
      recencyYears: 0.5,
      durationYears: 3.0,
    ),
    suggestion: 'Highlight specific performance improvements or architecture decisions in interview prep.',
  );

  final testMissingMatch = RequirementEvidenceMatch(
    requirement: const JobRequirement(
      id: 'req_docker',
      text: 'Docker containerization and orchestration',
      category: RequirementCategory.tool,
      priority: RequirementPriority.niceToHave,
      normalizedSkills: ['docker'],
    ),
    verdict: EvidenceVerdict.missing,
    reason: 'No evidence found in parsed resume text.',
    confidence: AnalysisConfidence.high,
    evidence: null,
    suggestion: 'If you have container experience from personal or academic projects, add verifiable examples.',
  );

  testWidgets(
    'requirement evidence sheet displays exact quote, role, section, and truthful suggestion',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          theme: appTheme(Brightness.light),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Center(
                  child: RequirementEvidenceRow(
                    match: testMatch,
                    onTap: () =>
                        showRequirementEvidenceSheet(context, testMatch),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify row renders requirement text and strong verdict chip
      expect(
        find.text('Production Flutter and Dart experience'),
        findsOneWidget,
      );
      expect(find.text('Strong'), findsOneWidget);
      expect(find.text('2+ yrs required'), findsOneWidget);

      // Tap row to open evidence bottom sheet
      await tester.tap(find.text('Production Flutter and Dart experience'));
      await tester.pumpAndSettle();

      // Verify sheet title and content
      expect(find.text('Requirement Evidence'), findsOneWidget);
      expect(find.text('Resume evidence'), findsOneWidget);
      expect(
        find.textContaining('Architected Riverpod state management'),
        findsOneWidget,
      );
      expect(find.text('Found in section: Work Experience'), findsOneWidget);
      expect(find.text('Role: Senior Mobile Engineer'), findsOneWidget);
      expect(
        find.text('Recency: 0.5 yrs ago · Duration: 3.0 yrs'),
        findsOneWidget,
      );
      expect(find.text('Verdict explanation'), findsOneWidget);
      expect(
        find.text(
          'Resume demonstrates 3 years building production Flutter apps with high test coverage.',
        ),
        findsOneWidget,
      );
      expect(find.text('Actionable suggestion'), findsOneWidget);
      expect(
        find.text(
          'Don’t add skills you don’t have. Only include genuine experience with verified outcomes.',
        ),
        findsOneWidget,
      );
      expect(find.text('Copy suggestion'), findsOneWidget);

      // Scroll to copy button inside the adaptive sheet and tap it
      await tester.scrollUntilVisible(
        find.text('Copy suggestion'),
        100,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.text('Copy suggestion'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Close the sheet
      Navigator.of(tester.element(find.text('Copy suggestion'))).pop();
      await tester.pumpAndSettle();
      expect(find.text('Resume evidence'), findsNothing);
    },
  );

  testWidgets(
    'missing requirement sheet does not fabricate quotes and shows truthful notice',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          theme: appTheme(Brightness.dark),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Center(
                  child: RequirementEvidenceRow(
                    match: testMissingMatch,
                    onTap: () =>
                        showRequirementEvidenceSheet(context, testMissingMatch),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Docker containerization and orchestration'),
        findsOneWidget,
      );
      expect(find.text('Missing'), findsOneWidget);

      await tester.tap(find.text('Docker containerization and orchestration'));
      await tester.pumpAndSettle();

      // Verify no quote is fabricated and truthful statement is displayed
      expect(
        find.text(
          'No direct evidence quote was found in your resume for this requirement.',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Don’t add skills you don’t have. Only include genuine experience with verified outcomes.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'MatchResultScreen renders evidence-based groups and Why this score breakdown',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final matchResult = MatchResult(
        id: 'mr_test_1',
        resumeId: 'r1',
        resumeTitle: 'Senior_Resume',
        jobLabel: 'Staff Mobile Engineer',
        role: 'Staff Mobile Engineer',
        company: 'Rolevia Tech',
        location: 'Remote',
        createdAt: DateTime(2026, 4, 1),
        overall: 88,
        analysisLabel: 'Full analysis',
        evidenceScore: const EvidenceScoreBreakdown(
          overall: 88,
          mustHave: 92,
          niceToHave: 80,
          categoryScores: {'hardSkill': 95, 'tool': 85},
          confidence: AnalysisConfidence.high,
          missingMustHaves: 0,
          seniorityMismatch: false,
          keywordStuffingFlag: false,
        ),
        requirementMatches: [testMatch, testMissingMatch],
        components: {'Skills': 90, 'Experience': 85},
        matched: ['Flutter', 'Dart', 'Riverpod'],
        missing: ['Docker'],
        strengths: ['Strong Flutter fundamentals'],
        gaps: ['Containerization'],
        suggestions: const [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            repositoryProvider.overrideWithValue(
              MemoryRepository({
                'matches': [matchResult.toJson()],
              }),
            ),
          ],
          child: MaterialApp(
            theme: appTheme(Brightness.light),
            home: const MatchResultScreen(id: 'mr_test_1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify verdict, confidence, and analysis label
      expect(find.text('Full analysis'), findsOneWidget);
      expect(find.text('High confidence'), findsOneWidget);
      expect(find.text('Why this score'), findsOneWidget);
      expect(find.text('92/100'), findsOneWidget); // Must-have score
      expect(find.text('80/100'), findsOneWidget); // Nice-to-have score
      expect(
        find.text('All required must-have items demonstrated in resume'),
        findsOneWidget,
      );
      expect(
        find.text('Seniority level matches position expectations'),
        findsOneWidget,
      );

      // Verify requirement groups
      expect(find.text('Must-have requirements (1)'), findsOneWidget);
      expect(find.text('Nice-to-have requirements (1)'), findsOneWidget);

      // Scroll to Gaps to close section
      await tester.scrollUntilVisible(find.text('Gaps to close (1)'), 200);
      await tester.pumpAndSettle();

      // Verify Gaps to close section
      expect(find.text('Gaps to close (1)'), findsOneWidget);
      expect(
        find.text(
          'Don’t add skills you don’t have. Only include genuine experience with verified outcomes.',
        ),
        findsOneWidget,
      );

      // Scroll back up and tap requirement row to open sheet
      await tester.scrollUntilVisible(
        find.text('Production Flutter and Dart experience'),
        -200,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Production Flutter and Dart experience'));
      await tester.pumpAndSettle();

      expect(find.text('Requirement Evidence'), findsOneWidget);
      expect(
        find.textContaining('Architected Riverpod state management'),
        findsOneWidget,
      );
    },
  );
}
