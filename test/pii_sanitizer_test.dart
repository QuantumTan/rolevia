import 'package:flutter_test/flutter_test.dart';
import 'package:rolevia/core/services/pii_sanitizer.dart';

void main() {
  group('PiiSanitizer', () {
    test('redacts Philippine government ID numbers', () {
      const input = '''
SSS Number: 34-1234567-8
TIN ID: 123-456-789-000
PhilHealth: 12-345678901-2
Pag-IBIG: 1234-5678-9012
''';
      final sanitized = PiiSanitizer.sanitize(input);
      expect(sanitized, isNot(contains('34-1234567-8')));
      expect(sanitized, isNot(contains('123-456-789-000')));
      expect(sanitized, isNot(contains('12-345678901-2')));
      expect(sanitized, isNot(contains('1234-5678-9012')));
      expect(sanitized, contains('[REDACTED]'));
    });

    test('redacts personal demographic lines', () {
      const input = '''
Age: 26
Date of Birth: 1998-05-14
Civil Status: Single
Religion: Roman Catholic
Citizenship: Filipino
''';
      final sanitized = PiiSanitizer.sanitize(input);
      expect(sanitized, isNot(contains('26')));
      expect(sanitized, isNot(contains('1998-05-14')));
      expect(sanitized, isNot(contains('Single')));
      expect(sanitized, isNot(contains('Roman Catholic')));
      expect(sanitized, isNot(contains('Filipino')));
      expect(sanitized, contains('[REDACTED]'));
    });

    test('redacts contact emails and phone numbers', () {
      const input = '''
Contact me at juan.delacruz@example.com or +63 917 123 4567.
Alternative mobile: 0918-123-4567.
''';
      final sanitized = PiiSanitizer.sanitize(input);
      expect(sanitized, isNot(contains('juan.delacruz@example.com')));
      expect(sanitized, isNot(contains('0918-123-4567')));
      expect(sanitized, isNot(contains('917 123 4567')));
      expect(sanitized, contains('[REDACTED]'));
    });

    test('preserves legitimate resume content and career history', () {
      const input = '''
Juan Dela Cruz
Senior Mobile Engineer
Skills: Flutter, Dart, Riverpod, Drift, SQLite, PostGIS, TypeScript
Experience:
Senior Flutter Developer at Tech Innovations PH (2022 - Present)
- Architected offline-first database sync using SQLite and Supabase
- Optimized app rendering performance and reduced memory footprint by 40%
Education:
Bachelor of Science in Computer Science, University of the Philippines
''';
      final sanitized = PiiSanitizer.sanitize(input);
      expect(sanitized, contains('Senior Mobile Engineer'));
      expect(sanitized, contains('Flutter, Dart, Riverpod, Drift'));
      expect(sanitized, contains('Architected offline-first database sync'));
      expect(sanitized, contains('Bachelor of Science in Computer Science'));
    });
  });
}
