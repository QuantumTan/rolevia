import '../../models/matching_models.dart';
import '../../models/models.dart';
import '../services/job_text_cleaner.dart';
import 'duration_math.dart';
import 'evidence_scorer.dart';
import 'matching_config.dart';
import 'skill_taxonomy.dart';

class EvidenceAnalysis {
  const EvidenceAnalysis({
    required this.requirements,
    required this.matches,
    required this.breakdown,
  });

  final List<JobRequirement> requirements;
  final List<RequirementEvidenceMatch> matches;
  final EvidenceScoreBreakdown breakdown;
}

class _ResumeLine {
  const _ResumeLine({
    required this.text,
    required this.section,
    required this.role,
    this.range,
  });

  final String text, section, role;
  final EmploymentDateRange? range;
}

abstract final class EvidenceMatcher {
  static const Set<String> _stopWords = {
    'and',
    'the',
    'with',
    'for',
    'from',
    'that',
    'this',
    'your',
    'you',
    'will',
    'must',
    'have',
    'has',
    'are',
    'our',
    'role',
    'work',
    'team',
    'years',
    'year',
    'experience',
    'required',
    'preferred',
    'knowledge',
    'skills',
  };

  static final RegExp _contextVerb = RegExp(
    r'\b(?:built|created|developed|managed|led|delivered|designed|improved|resolved|implemented|supported|handled|used|deployed|maintained|configured|automated|trained|reduced|increased|achieved|worked)\b',
    caseSensitive: false,
  );
  static final RegExp _weakLanguage = RegExp(
    r'\b(?:familiar with|exposure to|learning|beginner|basic knowledge|some knowledge)\b',
    caseSensitive: false,
  );
  static final RegExp _negation = RegExp(
    r'\b(?:no experience|without experience|lack(?:ing)?|never used|do not have|don\x27t have)\b',
    caseSensitive: false,
  );

  static EvidenceAnalysis analyze({
    required ResumeVersion resume,
    required String jobText,
    Job? job,
    DateTime? now,
  }) {
    final cleanedJob = JobTextCleaner.clean(jobText);
    final requirements = extractRequirements(cleanedJob, job: job);
    final resumeLines = _parseResume(resume.extractedText, now: now);
    final keywordStuffing = _detectKeywordStuffing(resumeLines);
    final matches = [
      for (final requirement in requirements)
        _matchRequirement(requirement, resumeLines, now: now),
    ];
    final seniorityMismatch = _hasSeniorityMismatch(
      jobText,
      resume.extractedText,
    );
    final resumeParseWeak = !resumeLines.any(
      (line) => line.section == 'Experience' && line.range != null,
    );
    final breakdown = EvidenceScorer.score(
      matches,
      jobTextTruncated:
          cleanedJob.isLikelyTruncated || job?.descriptionTruncated == true,
      resumeParseWeak: resumeParseWeak,
      seniorityMismatch: seniorityMismatch,
      keywordStuffingFlag: keywordStuffing,
    );
    return EvidenceAnalysis(
      requirements: requirements,
      matches: matches,
      breakdown: breakdown,
    );
  }

  static List<JobRequirement> extractRequirements(
    JobTextCleanResult jobText, {
    Job? job,
  }) {
    final candidates = <(String, JobSectionKind)>[];
    for (final section in jobText.sections) {
      final lines = section.body
          .split('\n')
          .map((line) => line.replaceFirst(RegExp(r'^-\s*'), '').trim())
          .where((line) => line.isNotEmpty);
      for (final line in lines) {
        final pieces = line.length > 220
            ? line.split(RegExp(r'(?<=[.;])\s+'))
            : [line];
        for (final piece in pieces) {
          final value = piece.trim();
          if (_looksLikeRequirement(value, section.kind)) {
            candidates.add((value, section.kind));
          }
        }
      }
    }
    if (job != null) {
      for (final skill in job.skills) {
        candidates.add((skill, JobSectionKind.requirements));
      }
      for (final responsibility in job.responsibilities) {
        candidates.add((responsibility, JobSectionKind.responsibilities));
      }
      for (final qualification in job.qualifications) {
        candidates.add((qualification, JobSectionKind.requirements));
      }
    }

    final seen = <String>{};
    final requirements = <JobRequirement>[];
    for (final candidate in candidates) {
      final fingerprint = candidate.$1
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9+#]+'), ' ')
          .trim();
      if (fingerprint.isEmpty || !seen.add(fingerprint)) continue;
      final skills = SkillTaxonomy.extract(candidate.$1).toList()..sort();
      final minimumYears = _minimumYears(candidate.$1);
      requirements.add(
        JobRequirement(
          id: 'req-${requirements.length + 1}',
          text: candidate.$1,
          category: _category(candidate.$1, skills, minimumYears),
          priority: _priority(candidate.$1, candidate.$2),
          minimumYears: minimumYears,
          normalizedSkills: skills,
        ),
      );
    }
    return requirements;
  }

  static RequirementEvidenceMatch _matchRequirement(
    JobRequirement requirement,
    List<_ResumeLine> lines, {
    DateTime? now,
  }) {
    RequirementEvidenceMatch? best;
    var sawNegation = false;
    final matchingRanges = <EmploymentDateRange>[];
    if (requirement.minimumYears != null) {
      for (final line in lines) {
        if (line.range == null || _negation.hasMatch(line.text)) continue;
        final skills = SkillTaxonomy.extract(line.text);
        final exact = requirement.normalizedSkills.any(
          (required) => skills.any(
            (candidate) =>
                SkillTaxonomy.relationship(required, candidate) ==
                SkillRelationship.exact,
          ),
        );
        if (exact) matchingRanges.add(line.range!);
      }
    }
    final totalMatchingYears = matchingRanges.isEmpty
        ? null
        : DurationMath.yearsFromMonths(
            DurationMath.totalUniqueMonths(matchingRanges),
          );
    for (final line in lines) {
      final resumeSkills = SkillTaxonomy.extract(line.text);
      var relationship = SkillRelationship.none;
      if (requirement.normalizedSkills.isNotEmpty) {
        for (final required in requirement.normalizedSkills) {
          for (final candidate in resumeSkills) {
            final current = SkillTaxonomy.relationship(required, candidate);
            if (current == SkillRelationship.exact) {
              relationship = current;
              break;
            }
            if (current == SkillRelationship.related) {
              relationship = current;
            }
          }
          if (relationship == SkillRelationship.exact) break;
        }
      } else if (_termOverlap(requirement.text, line.text) >= 2) {
        relationship = SkillRelationship.exact;
      }
      if (relationship == SkillRelationship.none) continue;
      if (_negation.hasMatch(line.text)) {
        sawNegation = true;
        continue;
      }

      var verdict = relationship == SkillRelationship.related
          ? EvidenceVerdict.transferable
          : _baseVerdict(line);
      final range = line.range;
      final recency = range == null
          ? null
          : DurationMath.recencyYears(range, now: now);
      final lineDuration = range == null
          ? null
          : DurationMath.yearsFromMonths(range.months);
      final duration = totalMatchingYears ?? lineDuration;
      if (_weakLanguage.hasMatch(line.text)) {
        verdict = EvidenceVerdict.partial;
      }
      if (recency != null && recency > MatchingConfig.staleSkillYears) {
        verdict = EvidenceVerdict.partial;
      }
      if (requirement.minimumYears != null &&
          (duration == null || duration < requirement.minimumYears!)) {
        verdict = EvidenceVerdict.partial;
      }
      final confidence =
          relationship == SkillRelationship.exact &&
              verdict == EvidenceVerdict.strong
          ? AnalysisConfidence.high
          : line.section == 'Skills'
          ? AnalysisConfidence.low
          : AnalysisConfidence.medium;
      final evidence = ResumeEvidence(
        quote: _shortQuote(line.text),
        section: line.section,
        role: line.role,
        confidence: confidence,
        recencyYears: recency,
        durationYears: duration,
      );
      final current = RequirementEvidenceMatch(
        requirement: requirement,
        verdict: verdict,
        evidence: evidence,
        confidence: confidence,
        reason: _reason(requirement, verdict, evidence),
        suggestion: _suggestion(requirement, verdict),
      );
      if (best == null || _rank(current.verdict) > _rank(best.verdict)) {
        best = current;
      }
    }

    return best ??
        RequirementEvidenceMatch(
          requirement: requirement,
          verdict: EvidenceVerdict.missing,
          reason: sawNegation
              ? 'The resume explicitly says this experience is not present.'
              : 'No supporting evidence was found in the resume.',
          confidence: sawNegation
              ? AnalysisConfidence.high
              : AnalysisConfidence.medium,
          suggestion: 'Do not add this unless it reflects experience you actually have.',
        );
  }

  static List<_ResumeLine> _parseResume(String text, {DateTime? now}) {
    var section = 'Other';
    var role = '';
    EmploymentDateRange? range;
    final lines = <_ResumeLine>[];
    for (final raw in text.replaceAll('\r', '\n').split('\n')) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      final heading = _resumeHeading(line);
      if (heading != null) {
        section = heading;
        role = '';
        range = null;
        continue;
      }
      final parsedRange = DurationMath.parseRange(line, now: now);
      if (parsedRange != null) {
        range = parsedRange;
        if (role.isEmpty && line.length <= 120) role = line;
        continue;
      }
      if (section == 'Experience' &&
          !line.startsWith(RegExp(r'[-•*]')) &&
          line.length <= 100 &&
          !_contextVerb.hasMatch(line)) {
        role = line;
      }
      lines.add(
        _ResumeLine(
          text: line.replaceFirst(RegExp(r'^[-•*]\s*'), ''),
          section: section,
          role: role,
          range: range,
        ),
      );
    }
    return lines;
  }

  static String? _resumeHeading(String line) {
    final value = line.toLowerCase().replaceAll(RegExp(r'[:\s]+$'), '');
    if (RegExp(r'^(?:professional )?experience|work history|employment$')
        .hasMatch(value)) {
      return 'Experience';
    }
    if (RegExp(r'^projects?|portfolio$').hasMatch(value)) return 'Projects';
    if (RegExp(r'^(?:technical )?skills?|tools?(?: and technologies)?$')
        .hasMatch(value)) {
      return 'Skills';
    }
    if (RegExp(r'^education|academic background$').hasMatch(value)) {
      return 'Education';
    }
    if (RegExp(r'^certifications?|licenses?$').hasMatch(value)) {
      return 'Certifications';
    }
    if (RegExp(r'^languages?$').hasMatch(value)) {
      return 'Languages';
    }
    if (RegExp(r'^summary|profile|objective$').hasMatch(value)) {
      return 'Summary';
    }
    return null;
  }

  static bool _looksLikeRequirement(String text, JobSectionKind section) {
    if (text.length < 3) return false;
    if ({
      JobSectionKind.requirements,
      JobSectionKind.responsibilities,
      JobSectionKind.niceToHave,
    }.contains(section)) {
      return true;
    }
    return SkillTaxonomy.extract(text).isNotEmpty ||
        RegExp(
          r'\b(?:required|must|preferred|responsible|proficient|experience|degree|certification|language|shift|location)\b',
          caseSensitive: false,
        ).hasMatch(text);
  }

  static RequirementPriority _priority(String text, JobSectionKind section) {
    if (section == JobSectionKind.niceToHave ||
        RegExp(
          r'\b(?:preferred|nice to have|bonus|plus|advantage|good to have)\b',
          caseSensitive: false,
        ).hasMatch(text)) {
      return RequirementPriority.niceToHave;
    }
    return RequirementPriority.mustHave;
  }

  static RequirementCategory _category(
    String text,
    List<String> skills,
    double? minimumYears,
  ) {
    final lower = text.toLowerCase();
    if (minimumYears != null) return RequirementCategory.yearsExperience;
    if (RegExp(r'\b(?:degree|bachelor|college|graduate)\b').hasMatch(lower)) {
      return RequirementCategory.education;
    }
    if (RegExp(r'\b(?:certified|certification|license)\b').hasMatch(lower)) {
      return RequirementCategory.certification;
    }
    if (RegExp(r'\b(?:english|filipino|tagalog|language)\b').hasMatch(lower)) {
      return RequirementCategory.language;
    }
    if (RegExp(
      r'\b(?:remote|hybrid|on[ -]?site|shift|location|manila|cebu|davao)\b',
    ).hasMatch(lower)) {
      return RequirementCategory.locationSchedule;
    }
    if (skills.isNotEmpty) return RequirementCategory.hardSkill;
    if (RegExp(
      r'\b(?:communication|teamwork|collaboration|adaptability|leadership)\b',
    ).hasMatch(lower)) {
      return RequirementCategory.softSkill;
    }
    return RequirementCategory.responsibility;
  }

  static double? _minimumYears(String text) {
    final match = RegExp(
      r'\b(\d+(?:\.\d+)?)\s*\+?\s*(?:years?|yrs?)\b',
      caseSensitive: false,
    ).firstMatch(text);
    return match == null ? null : double.tryParse(match.group(1)!);
  }

  static EvidenceVerdict _baseVerdict(_ResumeLine line) {
    if (line.section == 'Skills') return EvidenceVerdict.mentionOnly;
    if ({'Experience', 'Projects'}.contains(line.section) ||
        _contextVerb.hasMatch(line.text)) {
      return EvidenceVerdict.strong;
    }
    return EvidenceVerdict.partial;
  }

  static int _termOverlap(String left, String right) {
    Set<String> terms(String value) =>
        RegExp(r'[a-z][a-z0-9+#-]{2,}')
            .allMatches(value.toLowerCase())
            .map((match) => match.group(0)!)
            .where((term) => !_stopWords.contains(term))
            .toSet();
    return terms(left).intersection(terms(right)).length;
  }

  static int _rank(EvidenceVerdict verdict) => switch (verdict) {
    EvidenceVerdict.strong => 5,
    EvidenceVerdict.partial => 4,
    EvidenceVerdict.transferable => 3,
    EvidenceVerdict.mentionOnly => 2,
    EvidenceVerdict.missing => 1,
  };

  static String _reason(
    JobRequirement requirement,
    EvidenceVerdict verdict,
    ResumeEvidence evidence,
  ) => switch (verdict) {
    EvidenceVerdict.strong =>
      'Demonstrated in ${evidence.section.toLowerCase()} with specific context.',
    EvidenceVerdict.partial when requirement.minimumYears != null => 'Related evidence exists, but the required duration is not fully demonstrated.',
    EvidenceVerdict.partial =>
      'Related evidence exists, but its strength or recency is limited.',
    EvidenceVerdict.transferable =>
      'The resume shows a related skill that may transfer to this requirement.',
    EvidenceVerdict.mentionOnly => 'The skill is listed, but no experience or project shows how it was used.',
    EvidenceVerdict.missing =>
      'No supporting evidence was found in the resume.',
  };

  static String _suggestion(
    JobRequirement requirement,
    EvidenceVerdict verdict,
  ) => switch (verdict) {
    EvidenceVerdict.strong => 'Keep the evidence specific and truthful.',
    EvidenceVerdict.partial => 'Add a truthful example with scope, duration, or outcome if you have one.',
    EvidenceVerdict.transferable => 'Explain how the related experience applies without claiming the missing tool.',
    EvidenceVerdict.mentionOnly =>
      '${requirement.text} is listed without demonstrated use. Add a truthful bullet showing where you used it.',
    EvidenceVerdict.missing =>
      'Do not add this unless it reflects experience you actually have.',
  };

  static String _shortQuote(String text) {
    final cleaned = text.trim();
    return cleaned.length <= 220 ? cleaned : '${cleaned.substring(0, 217)}...';
  }

  static bool _hasSeniorityMismatch(String job, String resume) {
    final seniorJob = RegExp(
      r'\b(?:senior|lead|principal|manager|head of)\b',
      caseSensitive: false,
    ).hasMatch(job);
    if (!seniorJob) return false;
    final seniorResume = RegExp(
      r'\b(?:senior|lead|principal|manager|supervisor|head of)\b',
      caseSensitive: false,
    ).hasMatch(resume);
    final juniorResume = RegExp(
      r'\b(?:junior|entry[ -]?level|intern|trainee|assistant)\b',
      caseSensitive: false,
    ).hasMatch(resume);
    return !seniorResume && juniorResume;
  }

  static bool _detectKeywordStuffing(List<_ResumeLine> lines) {
    final skills = lines.where((line) => line.section == 'Skills').toList();
    final skillCount = skills.fold<int>(
      0,
      (total, line) => total + SkillTaxonomy.extract(line.text).length,
    );
    final fingerprints = <String>{};
    var repeated = 0;
    for (final line in lines) {
      final fingerprint = line.text
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
          .trim();
      if (fingerprint.length > 20 && !fingerprints.add(fingerprint)) {
        repeated += 1;
      }
    }
    return skillCount > MatchingConfig.largeSkillsSectionThreshold ||
        repeated >= 2;
  }
}
