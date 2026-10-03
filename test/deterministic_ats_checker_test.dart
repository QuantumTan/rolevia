import 'package:flutter_test/flutter_test.dart';
import 'package:rolevia/core/services/deterministic_ats_checker.dart';

void main() {
  group('DeterministicAtsChecker', () {
    const validResume = '''
Maria Santos
Senior Software Engineer
Email: maria.santos@example.com
Phone: +63 917 555 1234
Location: Makati City, Philippines

Professional Summary:
Passionate mobile developer with 6+ years of building robust production applications.

Experience:
Lead Flutter Developer - Solutions Corp (2021 - Present)
- Built enterprise offline applications.
- Mentored junior engineers and led code review processes.

Education:
B.S. in Information Technology - Ateneo de Manila University

Skills:
Flutter, Dart, Riverpod, SQL, REST APIs, Git, CI/CD
''';

    test('returns ATS OK when all 10 heuristics pass', () {
      final report = DeterministicAtsChecker.check(
        validResume,
        pages: 2,
        complexColumns: false,
        smallFonts: false,
        marginText: false,
      );

      expect(report.status, equals('ATS OK'));
      expect(report.tips, isEmpty);
      expect(report.checks.values.every((v) => v), isTrue);
      expect(report.checks.length, equals(10));
    });

    test('flags complex layout when text is too short (< 80 chars)', () {
      final report = DeterministicAtsChecker.check(
        'Too short resume text',
        pages: 1,
      );

      expect(report.status, equals('Complex layout'));
      expect(report.checks['Extractable text'], isFalse);
      expect(report.tips, contains('Review: Extractable text.'));
    });

    test('flags complex layout when pages exceed 2', () {
      final report = DeterministicAtsChecker.check(
        validResume,
        pages: 3,
      );

      expect(report.status, equals('Complex layout'));
      expect(report.checks['One or two pages'], isFalse);
      expect(report.tips, contains('Review: One or two pages.'));
    });

    test('flags complex layout when complex columns or small fonts are detected', () {
      final report = DeterministicAtsChecker.check(
        validResume,
        pages: 1,
        complexColumns: true,
        smallFonts: true,
        marginText: true,
      );

      expect(report.status, equals('Complex layout'));
      expect(report.checks['Simple reading order'], isFalse);
      expect(report.checks['Readable font size'], isFalse);
      expect(report.checks['Content outside header and footer'], isFalse);
      expect(report.tips.length, greaterThanOrEqualTo(3));
    });

    test('flags missing contact information or required sections', () {
      const strippedResume = '''
Generic Developer
Passionate programmer with experience in building software products.
Graduated from university with high honors.
''';

      final report = DeterministicAtsChecker.check(
        strippedResume,
        pages: 1,
      );

      expect(report.status, equals('Complex layout'));
      expect(report.checks['Email contact'], isFalse);
      expect(report.checks['Phone contact'], isFalse);
      expect(report.checks['Skills section'], isFalse);
    });
  });
}
