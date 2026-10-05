import 'package:flutter_test/flutter_test.dart';
import 'package:rolevia/core/matching/evidence_scorer.dart';
import 'package:rolevia/models/matching_models.dart';

JobRequirement requirement(String id, RequirementPriority priority) =>
    JobRequirement(
      id: id,
      text: id,
      category: RequirementCategory.hardSkill,
      priority: priority,
    );

RequirementEvidenceMatch verdict(
  String id,
  RequirementPriority priority,
  EvidenceVerdict value,
) => RequirementEvidenceMatch(
  requirement: requirement(id, priority),
  verdict: value,
  reason: '',
  confidence: AnalysisConfidence.high,
);

void main() {
  test('uses 70 percent must-have and 30 percent nice-to-have weights', () {
    final score = EvidenceScorer.score(
      [
        verdict('must', RequirementPriority.mustHave, EvidenceVerdict.strong),
        verdict(
          'nice',
          RequirementPriority.niceToHave,
          EvidenceVerdict.missing,
        ),
      ],
      jobTextTruncated: false,
      resumeParseWeak: false,
      seniorityMismatch: false,
      keywordStuffingFlag: false,
    );

    expect(score.overall, 70);
    expect(score.mustHave, 100);
    expect(score.niceToHave, 0);
  });

  test('caps a score when a must-have is missing', () {
    final score = EvidenceScorer.score(
      [
        verdict('one', RequirementPriority.mustHave, EvidenceVerdict.strong),
        verdict('two', RequirementPriority.mustHave, EvidenceVerdict.missing),
        verdict('nice', RequirementPriority.niceToHave, EvidenceVerdict.strong),
      ],
      jobTextTruncated: false,
      resumeParseWeak: false,
      seniorityMismatch: false,
      keywordStuffingFlag: false,
    );

    expect(score.overall, lessThanOrEqualTo(75));
    expect(score.missingMustHaves, 1);
  });

  test('confidence falls when an input is weak or truncated', () {
    final score = EvidenceScorer.score(
      [verdict('one', RequirementPriority.mustHave, EvidenceVerdict.strong)],
      jobTextTruncated: true,
      resumeParseWeak: false,
      seniorityMismatch: false,
      keywordStuffingFlag: false,
    );

    expect(score.confidence, AnalysisConfidence.low);
  });
}
