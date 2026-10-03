import 'package:flutter_test/flutter_test.dart';
import 'package:rolevia/core/services/job_text_cleaner.dart';

void main() {
  group('JobTextCleaner', () {
    test('preserves paragraphs and normalizes common bullet glyphs', () {
      final result = JobTextCleaner.clean('''
Job Summary
Build tools for support teams.

Responsibilities:
• Handle customer concerns
✓ Track CSAT and AHT
2. Escalate complex cases
''');

      expect(result.cleaned, contains('About\nBuild tools for support teams.'));
      expect(result.cleaned, contains('Responsibilities'));
      expect(result.cleaned, contains('- Handle customer concerns'));
      expect(result.cleaned, contains('- Track CSAT and AHT'));
      expect(result.cleaned, contains('- Escalate complex cases'));
      expect(result.sections.map((section) => section.kind), [
        JobSectionKind.about,
        JobSectionKind.responsibilities,
      ]);
    });

    test('detects English and Taglish headings', () {
      final result = JobTextCleaner.clean('''
What you'll do
- Answer chat and voice concerns

Mga kailangan
- At least one year of customer support

Mas okay kung meron
- Familiarity with Zendesk

Mga benepisyo
- HMO after regularization
''');

      expect(result.sections.map((section) => section.kind), [
        JobSectionKind.responsibilities,
        JobSectionKind.requirements,
        JobSectionKind.niceToHave,
        JobSectionKind.benefits,
      ]);
    });

    test('removes filler dots, social artifacts, and duplicate blocks', () {
      final result = JobTextCleaner.clean('''
Requirements
....
• Flutter experience

Requirements
....
• Flutter experience
See more
''');

      expect(result.cleaned, isNot(contains('....')));
      expect(result.cleaned.toLowerCase(), isNot(contains('see more')));
      expect(
        RegExp('Flutter experience').allMatches(result.cleaned),
        hasLength(1),
      );
      expect(result.isLikelyTruncated, isTrue);
    });

    test('keeps original text for inspection', () {
      const original = 'Requirements:\r\n• SQL\r\nShow more';
      final result = JobTextCleaner.clean(original);

      expect(result.original, original);
      expect(result.changed, isTrue);
      expect(result.cleaned, contains('- SQL'));
    });

    test('flags a short unfinished snippet but not a short complete post', () {
      final truncated = JobTextCleaner.clean(
        'We need a customer support specialist who can answer voice and chat concerns, document each case, track service levels, and work with the escalation team',
      );
      final complete = JobTextCleaner.clean(
        'We need a customer support specialist who can answer customer questions.',
      );

      expect(truncated.isLikelyTruncated, isTrue);
      expect(complete.isLikelyTruncated, isFalse);
    });

    test('does not impose a character cap', () {
      final source = List.filled(5000, 'requirement').join(' ');
      final result = JobTextCleaner.clean(source);

      expect(result.cleaned, endsWith(source));
      expect(RegExp('requirement').allMatches(result.cleaned), hasLength(5000));
    });
  });
}
