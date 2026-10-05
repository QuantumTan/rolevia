import '../../models/matching_models.dart';

abstract final class MatchingConfig {
  static const String promptVersion = 'evidence-v1';

  static const double mustHaveWeight = 0.70;
  static const double niceToHaveWeight = 0.30;

  static const Map<EvidenceVerdict, double> verdictMultiplier = {
    EvidenceVerdict.strong: 1.0,
    EvidenceVerdict.partial: 0.6,
    EvidenceVerdict.transferable: 0.5,
    EvidenceVerdict.mentionOnly: 0.3,
    EvidenceVerdict.missing: 0.0,
  };

  static const Map<int, int> missingMustHaveCaps = {1: 75, 2: 60, 3: 50};

  static const double seniorityMismatchMultiplier = 0.85;
  static const int staleSkillYears = 5;
  static const int veryStaleSkillYears = 8;
  static const int largeSkillsSectionThreshold = 25;
}
