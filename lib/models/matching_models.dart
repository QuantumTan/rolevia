enum RequirementCategory {
  hardSkill,
  tool,
  responsibility,
  domainKnowledge,
  softSkill,
  education,
  certification,
  language,
  yearsExperience,
  locationSchedule,
}

enum RequirementPriority { mustHave, niceToHave }

enum EvidenceVerdict { strong, partial, transferable, mentionOnly, missing }

enum AnalysisConfidence { high, medium, low }

extension EvidenceVerdictLabel on EvidenceVerdict {
  String get label => switch (this) {
    EvidenceVerdict.strong => 'Strong',
    EvidenceVerdict.partial => 'Partial',
    EvidenceVerdict.transferable => 'Transferable',
    EvidenceVerdict.mentionOnly => 'Mention only',
    EvidenceVerdict.missing => 'Missing',
  };
}

extension RequirementPriorityLabel on RequirementPriority {
  String get label => switch (this) {
    RequirementPriority.mustHave => 'Must-have',
    RequirementPriority.niceToHave => 'Nice-to-have',
  };
}

extension AnalysisConfidenceLabel on AnalysisConfidence {
  String get label => switch (this) {
    AnalysisConfidence.high => 'High confidence',
    AnalysisConfidence.medium => 'Medium confidence',
    AnalysisConfidence.low => 'Low confidence',
  };
}

class JobRequirement {
  const JobRequirement({
    required this.id,
    required this.text,
    required this.category,
    required this.priority,
    this.minimumYears,
    this.normalizedSkills = const [],
  });

  final String id;
  final String text;
  final RequirementCategory category;
  final RequirementPriority priority;
  final double? minimumYears;
  final List<String> normalizedSkills;

  Map<String, Object?> toJson() => {
    'id': id,
    'text': text,
    'category': category.name,
    'priority': priority.name,
    'minimumYears': minimumYears,
    'normalizedSkills': normalizedSkills,
  };

  factory JobRequirement.fromJson(Map<String, dynamic> json) => JobRequirement(
    id: json['id']?.toString() ?? '',
    text: json['text']?.toString() ?? '',
    category: RequirementCategory.values.firstWhere(
      (value) => value.name == json['category'],
      orElse: () => RequirementCategory.responsibility,
    ),
    priority: RequirementPriority.values.firstWhere(
      (value) => value.name == json['priority'],
      orElse: () => RequirementPriority.mustHave,
    ),
    minimumYears: (json['minimumYears'] as num?)?.toDouble(),
    normalizedSkills: List<String>.from(json['normalizedSkills'] ?? const []),
  );
}

class ResumeEvidence {
  const ResumeEvidence({
    required this.quote,
    required this.section,
    required this.role,
    required this.confidence,
    this.recencyYears,
    this.durationYears,
  });

  final String quote;
  final String section;
  final String role;
  final AnalysisConfidence confidence;
  final double? recencyYears;
  final double? durationYears;

  Map<String, Object?> toJson() => {
    'quote': quote,
    'section': section,
    'role': role,
    'confidence': confidence.name,
    'recencyYears': recencyYears,
    'durationYears': durationYears,
  };

  factory ResumeEvidence.fromJson(Map<String, dynamic> json) => ResumeEvidence(
    quote: json['quote']?.toString() ?? '',
    section: json['section']?.toString() ?? 'Resume',
    role: json['role']?.toString() ?? '',
    confidence: AnalysisConfidence.values.firstWhere(
      (value) => value.name == json['confidence'],
      orElse: () => AnalysisConfidence.medium,
    ),
    recencyYears: (json['recencyYears'] as num?)?.toDouble(),
    durationYears: (json['durationYears'] as num?)?.toDouble(),
  );
}

class RequirementEvidenceMatch {
  const RequirementEvidenceMatch({
    required this.requirement,
    required this.verdict,
    required this.reason,
    required this.confidence,
    this.evidence,
    this.suggestion = '',
  });

  final JobRequirement requirement;
  final EvidenceVerdict verdict;
  final String reason;
  final AnalysisConfidence confidence;
  final ResumeEvidence? evidence;
  final String suggestion;

  Map<String, Object?> toJson() => {
    'requirement': requirement.toJson(),
    'verdict': verdict.name,
    'reason': reason,
    'confidence': confidence.name,
    'evidence': evidence?.toJson(),
    'suggestion': suggestion,
  };

  factory RequirementEvidenceMatch.fromJson(Map<String, dynamic> json) =>
      RequirementEvidenceMatch(
        requirement: JobRequirement.fromJson(
          Map<String, dynamic>.from(json['requirement'] as Map? ?? const {}),
        ),
        verdict: EvidenceVerdict.values.firstWhere(
          (value) => value.name == json['verdict'],
          orElse: () => EvidenceVerdict.missing,
        ),
        reason: json['reason']?.toString() ?? '',
        confidence: AnalysisConfidence.values.firstWhere(
          (value) => value.name == json['confidence'],
          orElse: () => AnalysisConfidence.medium,
        ),
        evidence: json['evidence'] is Map
            ? ResumeEvidence.fromJson(
                Map<String, dynamic>.from(json['evidence'] as Map),
              )
            : null,
        suggestion: json['suggestion']?.toString() ?? '',
      );
}

class EvidenceScoreBreakdown {
  const EvidenceScoreBreakdown({
    required this.overall,
    required this.mustHave,
    required this.niceToHave,
    required this.categoryScores,
    required this.confidence,
    this.missingMustHaves = 0,
    this.seniorityMismatch = false,
    this.keywordStuffingFlag = false,
  });

  final int overall;
  final int mustHave;
  final int niceToHave;
  final Map<String, int> categoryScores;
  final AnalysisConfidence confidence;
  final int missingMustHaves;
  final bool seniorityMismatch;
  final bool keywordStuffingFlag;

  Map<String, Object?> toJson() => {
    'overall': overall,
    'mustHave': mustHave,
    'niceToHave': niceToHave,
    'categoryScores': categoryScores,
    'confidence': confidence.name,
    'missingMustHaves': missingMustHaves,
    'seniorityMismatch': seniorityMismatch,
    'keywordStuffingFlag': keywordStuffingFlag,
  };

  factory EvidenceScoreBreakdown.fromJson(Map<String, dynamic> json) =>
      EvidenceScoreBreakdown(
        overall: (json['overall'] as num? ?? 0).round(),
        mustHave: (json['mustHave'] as num? ?? 0).round(),
        niceToHave: (json['niceToHave'] as num? ?? 0).round(),
        categoryScores: Map<String, int>.from(
          (json['categoryScores'] as Map? ?? const {}).map(
            (key, value) => MapEntry(key.toString(), (value as num).round()),
          ),
        ),
        confidence: AnalysisConfidence.values.firstWhere(
          (value) => value.name == json['confidence'],
          orElse: () => AnalysisConfidence.medium,
        ),
        missingMustHaves: (json['missingMustHaves'] as num? ?? 0).round(),
        seniorityMismatch: json['seniorityMismatch'] == true,
        keywordStuffingFlag: json['keywordStuffingFlag'] == true,
      );
}
