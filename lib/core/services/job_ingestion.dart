import 'job_text_cleaner.dart';

class JobIngestion {
  JobIngestion(String input) : result = JobTextCleaner.clean(input);

  final JobTextCleanResult result;

  String get text => result.cleaned;
  String get original => result.original;
  List<JobTextSection> get sections => result.sections;
  bool get isLikelyTruncated => result.isLikelyTruncated;

  static String sanitize(String value) => JobTextCleaner.clean(value).cleaned;

  int get words => result.words;
  int get readingMinutes => result.readingMinutes;
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
