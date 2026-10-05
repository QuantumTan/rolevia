enum ResumeParseQuality { high, medium, low }

class ResumeParsedSection {
  const ResumeParsedSection({required this.title, required this.content});

  final String title;
  final String content;
}

class ResumeParseResult {
  const ResumeParseResult({
    required this.cleanedText,
    required this.sections,
    required this.quality,
    required this.warnings,
  });

  final String cleanedText;
  final List<ResumeParsedSection> sections;
  final ResumeParseQuality quality;
  final List<String> warnings;

  bool get shouldTryOcr => quality == ResumeParseQuality.low;
}

abstract final class ResumeTextParser {
  static final _sectionAliases = <String, String>{
    'summary': 'Summary',
    'profile': 'Summary',
    'professional summary': 'Summary',
    'career objective': 'Summary',
    'objective': 'Summary',
    'experience': 'Experience',
    'work experience': 'Experience',
    'professional experience': 'Experience',
    'employment history': 'Experience',
    'work history': 'Experience',
    'education': 'Education',
    'educational background': 'Education',
    'academic background': 'Education',
    'skills': 'Skills',
    'technical skills': 'Skills',
    'core competencies': 'Skills',
    'competencies': 'Skills',
    'projects': 'Projects',
    'selected projects': 'Projects',
    'certifications': 'Certifications',
    'licenses and certifications': 'Certifications',
    'training and certifications': 'Certifications',
    'languages': 'Languages',
    'awards': 'Awards',
    'volunteer experience': 'Volunteer experience',
    'references': 'References',
  };

  static ResumeParseResult parse(String text) {
    final cleaned = _clean(text);
    final lines = cleaned.split('\n');
    final sections = <ResumeParsedSection>[];
    var currentTitle = 'Resume details';
    var buffer = <String>[];

    void flush() {
      final content = _trimBlankLines(buffer).join('\n').trim();
      if (content.isNotEmpty) {
        sections.add(
          ResumeParsedSection(title: currentTitle, content: content),
        );
      }
      buffer = <String>[];
    }

    for (final line in lines) {
      final heading = _canonicalHeading(line);
      if (heading != null) {
        flush();
        currentTitle = heading;
      } else {
        buffer.add(line);
      }
    }
    flush();

    final lowerTitles = sections
        .map((section) => section.title.toLowerCase())
        .toSet();
    final words = RegExp(r"[A-Za-z][A-Za-z'’+.#/-]*")
        .allMatches(cleaned)
        .length;
    final visible = cleaned.runes.where((rune) => rune > 32).length;
    final suspicious = RegExp(r'[�□■]{1,}|(?:\b[A-Z]\s){4,}[A-Z]\b')
        .allMatches(cleaned)
        .length;
    final hasExperience =
        lowerTitles.contains('experience') ||
        RegExp(
          r'\b(experience|employment|work history)\b',
          caseSensitive: false,
        ).hasMatch(cleaned);
    final hasEducation =
        lowerTitles.contains('education') ||
        RegExp(
          r'\b(education|university|college|bachelor|master)\b',
          caseSensitive: false,
        ).hasMatch(cleaned);
    final hasSkills =
        lowerTitles.contains('skills') ||
        RegExp(
          r'\b(skills|competencies|technologies|tools)\b',
          caseSensitive: false,
        ).hasMatch(cleaned);
    final recognizedSections = [
      hasExperience,
      hasEducation,
      hasSkills,
    ].where((value) => value).length;

    final ResumeParseQuality quality;
    if (cleaned.length < 120 || words < 35 || suspicious > 4) {
      quality = ResumeParseQuality.low;
    } else if (cleaned.length >= 450 &&
        words >= 90 &&
        recognizedSections >= 2) {
      quality = ResumeParseQuality.high;
    } else {
      quality = ResumeParseQuality.medium;
    }

    final warnings = <String>[
      if (quality == ResumeParseQuality.low) 'Only a small amount of readable text was found. Check the extracted sections carefully.',
      if (visible > 0 && words / visible < 0.08) 'Some characters may not have been extracted in the correct reading order.',
      if (!hasExperience) 'No clear experience section was detected.',
      if (!hasEducation) 'No clear education section was detected.',
      if (!hasSkills) 'No clear skills section was detected.',
      if (hasExperience &&
          !RegExp(
            r'\b(?:19|20)\d{2}\b|\b(?:jan(?:uary)?|feb(?:ruary)?|mar(?:ch)?|apr(?:il)?|may|jun(?:e)?|jul(?:y)?|aug(?:ust)?|sep(?:tember)?|oct(?:ober)?|nov(?:ember)?|dec(?:ember)?)\b',
            caseSensitive: false,
          ).hasMatch(cleaned))
        'Experience dates were not recognized. Add dates if they are missing.',
    ];

    return ResumeParseResult(
      cleanedText: cleaned,
      sections: sections.isEmpty && cleaned.isNotEmpty
          ? [ResumeParsedSection(title: 'Resume text', content: cleaned)]
          : sections,
      quality: quality,
      warnings: warnings,
    );
  }

  static String fromSections(Iterable<ResumeParsedSection> sections) {
    return sections
        .where((section) => section.content.trim().isNotEmpty)
        .map(
          (section) =>
              '${section.title.toUpperCase()}\n${section.content.trim()}',
        )
        .join('\n\n')
        .trim();
  }

  static String _clean(String text) {
    var result = text
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll('\u00a0', ' ')
        .replaceAll(RegExp(r'[\t ]+'), ' ')
        .replaceAll(RegExp(r'^[•●▪◦‣]\s*', multiLine: true), '• ')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n');
    result = result.replaceAllMapped(
      RegExp(r'([A-Za-z]{3,})-\n([a-z][A-Za-z]*)'),
      (match) => '${match.group(1)}${match.group(2)}',
    );
    return result.trim();
  }

  static String? _canonicalHeading(String line) {
    final normalized = line
        .trim()
        .replaceAll(RegExp(r'[:|]+$'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .toLowerCase();
    if (normalized.length > 40) return null;
    return _sectionAliases[normalized];
  }

  static List<String> _trimBlankLines(List<String> lines) {
    var start = 0;
    var end = lines.length;
    while (start < end && lines[start].trim().isEmpty) {
      start++;
    }
    while (end > start && lines[end - 1].trim().isEmpty) {
      end--;
    }
    return lines.sublist(start, end);
  }
}
