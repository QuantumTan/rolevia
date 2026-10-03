import 'package:uuid/uuid.dart';

import '../../models/models.dart';
import 'job_ingestion.dart';

abstract final class MatchAnalyzer {
  static const _stopWords = {
    'the',
    'and',
    'with',
    'for',
    'this',
    'that',
    'you',
    'your',
    'our',
    'are',
    'will',
    'have',
    'has',
    'from',
    'job',
    'role',
    'company',
    'work',
    'team',
    'must',
    'able',
    'can',
    'all',
    'not',
    'who',
    'what',
    'when',
    'where',
    'into',
    'about',
    'required',
    'requirements',
    'responsibilities',
    'hiring',
    'position',
    'title',
    'experience',
    'skills',
    'years',
    'year',
    'their',
  };

  static bool _contains(String text, String keyword) =>
      RegExp('(?<![a-z0-9])${RegExp.escape(keyword.toLowerCase())}(?![a-z0-9])')
          .hasMatch(text.toLowerCase());

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
    final keywords = <String>{
      if (job != null && job.skills.isNotEmpty)
        ...job.skills.map((s) => s.trim().toLowerCase()).where((s) => s.isNotEmpty)
      else ...RegExp(r'[a-zA-Z][a-zA-Z0-9+#/-]{2,}')
          .allMatches(input.text.toLowerCase())
          .map((m) => m.group(0)!)
          .where((word) => !_stopWords.contains(word)),
    }.toList();
    final matched = keywords.where((k) => _contains(source, k)).toList();
    final missing = keywords.where((k) => !_contains(source, k)).toList();
    final keywordScore = keywords.isEmpty
        ? 0
        : (100 * matched.length / keywords.length).round();
    final lines = source
        .split(RegExp(r'[\n\r]+'))
        .where((s) => s.trim().isNotEmpty)
        .toList();
    final actionLines = lines
        .where(
          (s) => RegExp(
            r'\b(built|created|developed|managed|led|delivered|designed|improved|resolved|implemented|supported|organized|trained|reduced|increased|automated)\b',
            caseSensitive: false,
          ).hasMatch(s),
        )
        .length;
    final metricLines = lines
        .where(
          (s) => RegExp(
            r'\b\d+(?:\.\d+)?\s*(?:%|(?:users|customers|clients|hours|minutes|projects|tickets|sales|days)\b)',
            caseSensitive: false,
          ).hasMatch(s),
        )
        .length;
    final actionScore = (actionLines * 100 / (lines.isEmpty ? 1 : lines.length))
        .round()
        .clamp(0, 100);
    final metricsScore =
        (metricLines * 100 / (actionLines == 0 ? 1 : actionLines))
            .round()
            .clamp(0, 100);
    final checks = resume.atsChecks;
    final formatting = checks.isEmpty
        ? 0
        : (checks.values.where((v) => v).length * 100 / checks.length).round();
    final score =
        (keywordScore * .7 +
                formatting * .2 +
                actionScore * .05 +
                metricsScore * .05)
            .round()
            .clamp(0, 100);
    final role = job?.role ?? input.title ?? 'Pasted job post';
    final company = job?.company ?? input.company ?? 'Company not specified';
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
      overall: score,
      summaryTitle: 'Text and formatting comparison',
      summaryText:
          '${matched.length} of ${keywords.length} job keywords appear in your resume. '
          'Score weights: keywords 70%, PDF checks 20%, action-verb density 5%, quantified action lines 5%.',
      components: {
        'Hard Skills & Keywords': keywordScore,
        'ATS Formatting & Readability': formatting,
        'Action-verb density': actionScore,
        'Quantified action lines': metricsScore,
      },
      atsChecks: checks,
      matched: matched,
      missing: missing,
      strengths: [
        if (matched.isNotEmpty)
          'Your resume contains ${matched.length} job keywords.',
      ],
      gaps: [
        if (checks.isEmpty) 'Re-import the PDF to check formatting.',
        for (final check in checks.entries)
          if (!check.value) 'Review: ${check.key}.',
        if (actionLines == 0)
          'Describe what you did using specific action verbs.',
        if (metricLines == 0)
          'Include measurable outcomes where you have evidence.',
      ],
      suggestions: const [],
    );
  }
}
