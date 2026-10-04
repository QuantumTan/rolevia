import 'package:uuid/uuid.dart';

import '../../models/matching_models.dart';
import '../../models/models.dart';
import '../matching/evidence_matcher.dart';
import 'job_ingestion.dart';

abstract final class MatchAnalyzer {
  static MatchResult analyze({
    required ResumeVersion resume,
    Job? job,
    required String text,
  }) {
    final source = resume.extractedText.trim();
    if (source.isEmpty) {
      throw const FormatException(
        'Re-import this resume PDF to extract its text before matching.',
      );
    }
    final input = JobIngestion(text);
    if (input.words < 5) {
      throw const FormatException(
        'Add the responsibilities and requirements from the job post.',
      );
    }

    final analysis = EvidenceMatcher.analyze(
      resume: resume,
      jobText: input.text,
      job: job,
    );
    if (analysis.requirements.isEmpty) {
      throw const FormatException(
        'Add specific responsibilities, qualifications, or required skills.',
      );
    }

    final breakdown = analysis.breakdown;
    final role = job?.role ?? input.title ?? 'Pasted job post';
    final company = job?.company ?? input.company ?? 'Company not specified';
    final matched = analysis.matches
        .where((match) => match.verdict != EvidenceVerdict.missing)
        .map((match) => match.requirement.text)
        .toList();
    final missing = analysis.matches
        .where((match) => match.verdict == EvidenceVerdict.missing)
        .map((match) => match.requirement.text)
        .toList();

    return MatchResult(
      id: const Uuid().v4(),
      resumeId: resume.id,
      resumeTitle: resume.filename,
      jobId: job?.id,
      jobLabel: '$role · $company',
      role: role,
      company: company,
      location: job?.location ?? 'Location not specified',
      createdAt: DateTime.now(),
      overall: breakdown.overall,
      summaryTitle: 'Evidence-based quick estimate',
      summaryText: _summary(analysis),
      components: {
        'Must-have evidence': breakdown.mustHave,
        'Nice-to-have evidence': breakdown.niceToHave,
        for (final entry in breakdown.categoryScores.entries)
          _categoryLabel(entry.key): entry.value,
      },
      atsChecks: resume.atsChecks,
      jobDescription: input.text,
      originalJobDescription: job?.originalDescription ?? input.original,
      jobTextTruncated:
          job?.descriptionTruncated == true || input.isLikelyTruncated,
      requirementMatches: analysis.matches,
      evidenceScore: breakdown,
      analysisLabel: 'Quick estimate',
      matched: matched,
      missing: missing,
      strengths: [
        for (final match in analysis.matches)
          if (match.verdict == EvidenceVerdict.strong) match.requirement.text,
      ],
      gaps: [
        if (breakdown.seniorityMismatch) 'The role seniority appears higher than the level shown in the resume.',
        if (breakdown.keywordStuffingFlag) 'A large or repeated skills block was detected. Repeated terms did not raise the score.',
        for (final match in analysis.matches)
          if (match.verdict == EvidenceVerdict.missing) match.requirement.text,
      ],
      suggestions: const [],
    );
  }

  static String _summary(EvidenceAnalysis analysis) {
    final strong = analysis.matches
        .where((match) => match.verdict == EvidenceVerdict.strong)
        .length;
    final missing = analysis.matches
        .where((match) => match.verdict == EvidenceVerdict.missing)
        .length;
    final confidence = analysis.breakdown.confidence.label.toLowerCase();
    return '$strong requirements have strong resume evidence and $missing are missing. '
        'This is a $confidence offline estimate; the score comes from the documented verdict weights.';
  }

  static String _categoryLabel(String name) => switch (name) {
    'hardSkill' => 'Hard skills',
    'tool' => 'Tools',
    'responsibility' => 'Responsibilities',
    'domainKnowledge' => 'Domain knowledge',
    'softSkill' => 'Soft skills',
    'education' => 'Education',
    'certification' => 'Certifications',
    'language' => 'Languages',
    'yearsExperience' => 'Years of experience',
    'locationSchedule' => 'Location and schedule',
    _ => name,
  };
}
