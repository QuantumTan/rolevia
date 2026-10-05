enum JobSectionKind {
  about,
  responsibilities,
  requirements,
  niceToHave,
  benefits,
  other,
}

extension JobSectionKindLabel on JobSectionKind {
  String get label => switch (this) {
    JobSectionKind.about => 'About',
    JobSectionKind.responsibilities => 'Responsibilities',
    JobSectionKind.requirements => 'Requirements / Qualifications',
    JobSectionKind.niceToHave => 'Nice to have',
    JobSectionKind.benefits => 'Benefits',
    JobSectionKind.other => 'Other',
  };
}

class JobTextSection {
  const JobTextSection({
    required this.kind,
    required this.heading,
    required this.body,
  });

  final JobSectionKind kind;
  final String heading;
  final String body;
}

class JobTextCleanResult {
  const JobTextCleanResult({
    required this.original,
    required this.cleaned,
    required this.sections,
    required this.isLikelyTruncated,
    required this.changed,
  });

  final String original;
  final String cleaned;
  final List<JobTextSection> sections;
  final bool isLikelyTruncated;
  final bool changed;

  int get characters => cleaned.length;
  int get words => cleaned.isEmpty
      ? 0
      : cleaned.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
  int get readingMinutes => words == 0 ? 0 : (words / 200).ceil();

  int get estimatedLines {
    if (cleaned.isEmpty) return 0;
    return cleaned
        .split('\n')
        .fold<int>(
          0,
          (total, line) =>
              total +
              (line.trim().isEmpty
                  ? 1
                  : (line.length / 48).ceil().clamp(1, 1000)),
        );
  }
}

abstract final class JobTextCleaner {
  static final RegExp _controlCharacters = RegExp(
    r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F\u200B-\u200D\uFEFF]',
  );
  static final RegExp _bullet = RegExp(
    r'^\s*(?:[•·▪\u2713*\-]|\d+[.)])\s+',
    caseSensitive: false,
  );
  static final RegExp _artifactLine = RegExp(
    r'^\s*(?:see|show|read|view)\s+more\s*[.›>]*\s*$',
    caseSensitive: false,
  );
  static final RegExp _trackingLine = RegExp(
    r'^\s*(?:apply now|click here to apply|job id\s*:\s*\S+|ref(?:erence)?\s*(?:id|no)?\s*:\s*\S+|utm_[a-z_]+\s*=.*)\s*$',
    caseSensitive: false,
  );
  static final RegExp _fillerDots = RegExp(r'(?:\s*\.\s*){4,}');

  static final List<(JobSectionKind, RegExp)> _headingPatterns = [
    (
      JobSectionKind.about,
      RegExp(
        r'^(?:about(?: the role| us| this job)?|job summary|role overview|position summary|company overview|tungkol sa trabaho)$',
        caseSensitive: false,
      ),
    ),
    (
      JobSectionKind.responsibilities,
      RegExp(
        r'^(?:responsibilities|key responsibilities|duties|what you(?:\x27|’)ll do|what you will do|your role|gagawin|mga gawain)$',
        caseSensitive: false,
      ),
    ),
    (
      JobSectionKind.requirements,
      RegExp(
        r'^(?:requirements|qualifications|required qualifications|what we(?:\x27|’)re looking for|what we are looking for|who you are|must have|minimum qualifications|mga kailangan|kailangan namin|hinahanap namin)$',
        caseSensitive: false,
      ),
    ),
    (
      JobSectionKind.niceToHave,
      RegExp(
        r'^(?:nice to have|preferred qualifications|preferred|bonus|plus|advantage|good to have|mas okay kung meron)$',
        caseSensitive: false,
      ),
    ),
    (
      JobSectionKind.benefits,
      RegExp(
        r'^(?:benefits|perks|what we offer|compensation and benefits|why join us|mga benepisyo)$',
        caseSensitive: false,
      ),
    ),
  ];

  static JobTextCleanResult clean(String value) {
    final original = value;
    final source = _normalizeUnicode(value)
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll(_controlCharacters, '')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(RegExp(r' *\n *'), '\n');

    final explicitlyTruncated = RegExp(
      r'(?:\.\.\.|…|(?:see|show|read|view)\s+more\s*[.›>]*)\s*$',
      caseSensitive: false,
    ).hasMatch(source.trim());

    final normalizedLines = <String>[];
    for (final rawLine in source.split('\n')) {
      var line = rawLine.trimRight();
      if (_artifactLine.hasMatch(line) || _trackingLine.hasMatch(line)) {
        continue;
      }
      line = line.replaceAll(_fillerDots, ' ');
      line = line.replaceAll(RegExp(r'\s{2,}'), ' ').trim();
      if (_bullet.hasMatch(line)) {
        line = '- ${line.replaceFirst(_bullet, '').trim()}';
      }
      if (line.isEmpty && normalizedLines.lastOrNull?.isEmpty == true) {
        continue;
      }
      normalizedLines.add(line);
    }

    while (normalizedLines.isNotEmpty && normalizedLines.first.isEmpty) {
      normalizedLines.removeAt(0);
    }
    while (normalizedLines.isNotEmpty && normalizedLines.last.isEmpty) {
      normalizedLines.removeLast();
    }

    final deduplicated = _deduplicateBlocks(normalizedLines.join('\n'));
    final sections = _detectSections(deduplicated);
    final hasExplicitHeading = deduplicated
        .split('\n')
        .any((line) => _parseHeading(line) != null);
    final cleaned = sections.isEmpty || !hasExplicitHeading
        ? deduplicated
        : sections
              .map((section) => '${section.heading}\n${section.body}'.trim())
              .join('\n\n')
              .trim();
    final shortSnippet = _looksLikeShortSnippet(cleaned, sections);

    return JobTextCleanResult(
      original: original,
      cleaned: cleaned,
      sections: sections,
      isLikelyTruncated: explicitlyTruncated || shortSnippet,
      changed: cleaned != original.trim(),
    );
  }

  static String _normalizeUnicode(String value) => value
      .replaceAll('\u00A0', ' ')
      .replaceAll('\u2028', '\n')
      .replaceAll('\u2029', '\n')
      .replaceAll('\u2018', "'")
      .replaceAll('\u2019', "'")
      .replaceAll('\u201C', '"')
      .replaceAll('\u201D', '"')
      .replaceAll('\u2013', '-')
      .replaceAll('\u2014', '-')
      .replaceAll('\u2212', '-');

  static String _deduplicateBlocks(String text) {
    final blocks = text.split(RegExp(r'\n\s*\n'));
    final seen = <String>{};
    final kept = <String>[];
    for (final block in blocks) {
      final trimmed = block.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      final fingerprint = trimmed
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
          .trim();
      if (fingerprint.isEmpty || seen.add(fingerprint)) kept.add(trimmed);
    }
    return kept.join('\n\n').trim();
  }

  static List<JobTextSection> _detectSections(String text) {
    if (text.isEmpty) return const [];
    final sections = <JobTextSection>[];
    var kind = JobSectionKind.other;
    var heading = kind.label;
    var explicitHeading = false;
    var body = <String>[];

    void flush() {
      final value = body.join('\n').trim();
      if (value.isEmpty) return;
      final effectiveKind =
          sections.isEmpty && !explicitHeading && kind == JobSectionKind.other
          ? JobSectionKind.about
          : kind;
      sections.add(
        JobTextSection(
          kind: effectiveKind,
          heading: explicitHeading ? heading : effectiveKind.label,
          body: value,
        ),
      );
      body = <String>[];
    }

    for (final line in text.split('\n')) {
      final parsed = _parseHeading(line);
      if (parsed != null) {
        flush();
        kind = parsed.$1;
        heading = parsed.$2;
        explicitHeading = true;
        if (parsed.$3.isNotEmpty) body.add(parsed.$3);
      } else {
        body.add(line);
      }
    }
    flush();
    return sections;
  }

  static (JobSectionKind, String, String)? _parseHeading(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.length > 100) return null;
    final parts = trimmed.split(RegExp(r'\s*:\s*', caseSensitive: false));
    final candidate = parts.first.replaceAll(RegExp(r'[:\s]+$'), '').trim();
    for (final entry in _headingPatterns) {
      if (entry.$2.hasMatch(candidate)) {
        final remainder = parts.length > 1
            ? parts.sublist(1).join(': ').trim()
            : '';
        return (entry.$1, entry.$1.label, remainder);
      }
    }
    return null;
  }

  static bool _looksLikeShortSnippet(
    String cleaned,
    List<JobTextSection> sections,
  ) {
    if (cleaned.length >= 300 || cleaned.isEmpty) return false;
    final words = cleaned
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;
    if (words < 20) return false;
    final hasExplicitSections = sections.length > 1;
    final hasBullets = RegExp(r'^- ', multiLine: true).hasMatch(cleaned);
    final endsCleanly = RegExp(r'[.!?)]$').hasMatch(cleaned.trim());
    return !hasExplicitSections && !hasBullets && !endsCleanly;
  }
}

extension<T> on List<T> {
  T? get lastOrNull => isEmpty ? null : last;
}
