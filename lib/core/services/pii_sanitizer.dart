abstract final class PiiSanitizer {
  static String sanitize(String text) {
    var result = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    result = result.replaceAll(RegExp(
      r'^.*\b(age|birth\s*date|birthday|dob|date of birth|civil status|marital status|religion|citizenship|nationality|gender|sex|home address|residential address|sss|gsis|tin|phil\s*health|pag[ -]?ibig)\b\s*[:\-].*$',
      caseSensitive: false, multiLine: true), '[REDACTED]');
    result = result.replaceAll(RegExp(
      r'^\s*(age|birth\s*date|dob|date of birth|civil status|marital status|religion|citizenship|sss|gsis|tin|phil\s*health|pag[ -]?ibig)\b[^\n]*',
      caseSensitive: false, multiLine: true), '[REDACTED]');
    for (final pattern in [
      r'\b\d{2}[- ]\d{7}[- ]\d\b',
      r'\b\d{2}[- ]\d{9}[- ]\d\b',
      r'\b\d{4}[- ]\d{4}[- ]\d{4}\b',
      r'\b\d{3}[- ]\d{3}[- ]\d{3}(?:[- ]\d{3,5})?\b',
      r'\b\d{9,12}\b',
      r'[A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,}',
      r'(?:\+?63|0)\s*9\d{2}[\s-]*\d{3}[\s-]*\d{4}',
      r'data:image/[^\s]+',
    ]) {
      result = result.replaceAll(RegExp(pattern, caseSensitive: false), '[REDACTED]');
    }
    return result.trim();
  }
}
