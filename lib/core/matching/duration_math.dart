class EmploymentDateRange {
  const EmploymentDateRange(this.start, this.end);

  final DateTime start, end;

  int get months => (end.year - start.year) * 12 + end.month - start.month + 1;
}

abstract final class DurationMath {
  static const Map<String, int> _months = {
    'jan': 1,
    'january': 1,
    'feb': 2,
    'february': 2,
    'mar': 3,
    'march': 3,
    'apr': 4,
    'april': 4,
    'may': 5,
    'jun': 6,
    'june': 6,
    'jul': 7,
    'july': 7,
    'aug': 8,
    'august': 8,
    'sep': 9,
    'sept': 9,
    'september': 9,
    'oct': 10,
    'october': 10,
    'nov': 11,
    'november': 11,
    'dec': 12,
    'december': 12,
  };

  static EmploymentDateRange? parseRange(String text, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final expression = RegExp(
      r'(?:(jan(?:uary)?|feb(?:ruary)?|mar(?:ch)?|apr(?:il)?|may|jun(?:e)?|jul(?:y)?|aug(?:ust)?|sep(?:t(?:ember)?)?|oct(?:ober)?|nov(?:ember)?|dec(?:ember)?)\s+)?((?:19|20)\d{2})\s*(?:-|–|to|until)\s*(?:(jan(?:uary)?|feb(?:ruary)?|mar(?:ch)?|apr(?:il)?|may|jun(?:e)?|jul(?:y)?|aug(?:ust)?|sep(?:t(?:ember)?)?|oct(?:ober)?|nov(?:ember)?|dec(?:ember)?)\s+)?((?:19|20)\d{2}|present|current|now)',
      caseSensitive: false,
    );
    final match = expression.firstMatch(text);
    if (match == null) return null;
    final startYear = int.parse(match.group(2)!);
    final startMonth = _month(match.group(1)) ?? 1;
    final endToken = match.group(4)!.toLowerCase();
    final isCurrent = {'present', 'current', 'now'}.contains(endToken);
    final endYear = isCurrent ? today.year : int.parse(endToken);
    final endMonth = isCurrent ? today.month : (_month(match.group(3)) ?? 12);
    final start = DateTime(startYear, startMonth);
    final end = DateTime(endYear, endMonth);
    if (end.isBefore(start)) return null;
    return EmploymentDateRange(start, end);
  }

  static int totalUniqueMonths(Iterable<EmploymentDateRange> ranges) {
    final months = <int>{};
    for (final range in ranges) {
      var year = range.start.year;
      var month = range.start.month;
      while (year < range.end.year ||
          (year == range.end.year && month <= range.end.month)) {
        months.add(year * 12 + month);
        month += 1;
        if (month == 13) {
          month = 1;
          year += 1;
        }
      }
    }
    return months.length;
  }

  static double yearsFromMonths(int months) => months / 12;

  static double recencyYears(EmploymentDateRange range, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final months =
        (today.year - range.end.year) * 12 + today.month - range.end.month;
    return months.clamp(0, 1200) / 12;
  }

  static int? _month(String? value) =>
      value == null ? null : _months[value.toLowerCase()];
}
