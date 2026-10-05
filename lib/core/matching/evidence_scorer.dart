import '../../models/matching_models.dart';
import 'matching_config.dart';

abstract final class EvidenceScorer {
  static EvidenceScoreBreakdown score(
    List<RequirementEvidenceMatch> matches, {
    required bool jobTextTruncated,
    required bool resumeParseWeak,
    required bool seniorityMismatch,
    required bool keywordStuffingFlag,
  }) {
    final mustHave = matches
        .where(
          (match) => match.requirement.priority == RequirementPriority.mustHave,
        )
        .toList();
    final niceToHave = matches
        .where(
          (match) =>
              match.requirement.priority == RequirementPriority.niceToHave,
        )
        .toList();

    final mustScore = _groupScore(mustHave);
    final niceScore = _groupScore(niceToHave);
    final raw = switch ((mustHave.isEmpty, niceToHave.isEmpty)) {
      (false, false) =>
        mustScore * MatchingConfig.mustHaveWeight +
            niceScore * MatchingConfig.niceToHaveWeight,
      (false, true) => mustScore,
      (true, false) => niceScore,
      (true, true) => 0.0,
    };

    var overall = raw.round().clamp(0, 100);
    if (seniorityMismatch) {
      overall = (overall * MatchingConfig.seniorityMismatchMultiplier).round();
    }
    final missingMustHaves = mustHave
        .where((match) => match.verdict == EvidenceVerdict.missing)
        .length;
    if (missingMustHaves > 0) {
      final key = missingMustHaves.clamp(1, 3);
      overall = overall.clamp(0, MatchingConfig.missingMustHaveCaps[key] ?? 50);
    }

    final categoryScores = <String, int>{};
    for (final category in RequirementCategory.values) {
      final values = matches
          .where((match) => match.requirement.category == category)
          .toList();
      if (values.isNotEmpty) {
        categoryScores[category.name] = _groupScore(values).round();
      }
    }

    final lowConfidenceMatches = matches
        .where((match) => match.confidence == AnalysisConfidence.low)
        .length;
    final confidence = jobTextTruncated || resumeParseWeak
        ? AnalysisConfidence.low
        : lowConfidenceMatches > matches.length / 3
        ? AnalysisConfidence.medium
        : AnalysisConfidence.high;

    return EvidenceScoreBreakdown(
      overall: overall,
      mustHave: mustScore.round(),
      niceToHave: niceScore.round(),
      categoryScores: categoryScores,
      confidence: confidence,
      missingMustHaves: missingMustHaves,
      seniorityMismatch: seniorityMismatch,
      keywordStuffingFlag: keywordStuffingFlag,
    );
  }

  static double _groupScore(List<RequirementEvidenceMatch> matches) {
    if (matches.isEmpty) return 0;
    final earned = matches.fold<double>(
      0,
      (total, match) =>
          total + (MatchingConfig.verdictMultiplier[match.verdict] ?? 0),
    );
    return earned * 100 / matches.length;
  }
}
