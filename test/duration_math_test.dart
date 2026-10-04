import 'package:flutter_test/flutter_test.dart';
import 'package:rolevia/core/matching/duration_math.dart';

void main() {
  test('parses month and year ranges including present', () {
    final range = DurationMath.parseRange(
      'Jan 2020 - Present',
      now: DateTime(2024, 12),
    );

    expect(range, isNotNull);
    expect(range!.months, 60);
    expect(DurationMath.recencyYears(range, now: DateTime(2024, 12)), 0);
  });

  test('merges overlapping jobs instead of double-counting time', () {
    final ranges = [
      DurationMath.parseRange('Jan 2020 - Dec 2021')!,
      DurationMath.parseRange('Jul 2021 - Jun 2022')!,
    ];

    expect(DurationMath.totalUniqueMonths(ranges), 30);
  });

  test('rejects reversed ranges and computes recency', () {
    expect(DurationMath.parseRange('2024 - 2020'), isNull);
    final range = DurationMath.parseRange('2018 - 2020')!;
    expect(
      DurationMath.recencyYears(range, now: DateTime(2025, 1)),
      closeTo(4.1, 0.1),
    );
  });
}
