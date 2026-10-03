class AtsReport {
  const AtsReport(this.checks, this.tips);
  final Map<String, bool> checks;
  final List<String> tips;
  String get status => checks.values.every((v) => v) ? 'ATS OK' : 'Complex layout';
}

abstract final class DeterministicAtsChecker {
  static AtsReport check(String text, {required int pages,
    bool complexColumns = false, bool smallFonts = false, bool marginText = false}) {
    final checks = <String, bool>{
      'Extractable text': text.trim().length >= 80,
      'Simple reading order': !complexColumns,
      'Readable font size': !smallFonts,
      'Content outside header and footer': !marginText,
      'Email contact': RegExp(r'[^\s@]+@[^\s@]+\.[^\s@]+').hasMatch(text),
      'Phone contact': RegExp(r'\+?\d[\d ()-]{8,}\d').hasMatch(text),
      'One or two pages': pages > 0 && pages <= 2,
      'Experience section': RegExp(r'experience|employment|projects', caseSensitive: false).hasMatch(text),
      'Education section': RegExp(r'education|degree|university|college', caseSensitive: false).hasMatch(text),
      'Skills section': RegExp(r'skills|competencies|technologies', caseSensitive: false).hasMatch(text),
    };
    return AtsReport(checks, [for (final e in checks.entries) if (!e.value) 'Review: ${e.key}.']);
  }
}
