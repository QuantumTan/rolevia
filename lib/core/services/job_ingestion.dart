class JobIngestion {
  JobIngestion(String input) : text = sanitize(input);

  final String text;

  static String sanitize(String value) => value
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n')
      .replaceAll(
        RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F\u200B-\u200D\uFEFF]'),
        '',
      )
      .replaceAll('\u00a0', ' ')
      .replaceAll(RegExp(r'[ \t]+'), ' ')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();

  int get words => text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
  int get readingMinutes => (words / 200).ceil();
  String? get title =>
      _field(r'(?:job title|position|role)') ??
      RegExp(
        r'^(.{2,80}?)\s+at\s+[^\n]+',
        caseSensitive: false,
      ).firstMatch(text)?.group(1)?.trim() ??
      RegExp(
        r'is hiring (?:a |an )?([^\n.!]{2,80})',
        caseSensitive: false,
      ).firstMatch(text)?.group(1)?.trim();
  String? get company =>
      _field(r'(?:company|employer)') ??
      RegExp(
        r'^[^\n]+?\s+at\s+([^\n.!]{2,80})',
        caseSensitive: false,
      ).firstMatch(text)?.group(1)?.trim() ??
      RegExp(
        r'^([^\n.!]{2,80}?)\s+is hiring',
        caseSensitive: false,
      ).firstMatch(text)?.group(1)?.trim();

  String? _field(String label) => RegExp(
    '^$label\\s*:\\s*([^\\n]+)',
    caseSensitive: false,
    multiLine: true,
  ).firstMatch(text)?.group(1)?.trim();
}
