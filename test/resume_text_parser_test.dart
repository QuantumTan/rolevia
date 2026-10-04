import 'package:flutter_test/flutter_test.dart';
import 'package:rolevia/core/services/resume_text_parser.dart';

void main() {
  group('ResumeTextParser', () {
    test('splits common resume headings into editable sections', () {
      final result = ResumeTextParser.parse('''
PROFESSIONAL SUMMARY
Operations analyst focused on process improvement and reporting.

WORK EXPERIENCE
Operations Analyst, Northstar Services
January 2021 - Present
• Reduced weekly reporting time by 30 percent.

EDUCATION
BS Information Technology, State University

TECHNICAL SKILLS
SQL, Excel, Power BI, stakeholder communication
''');

      expect(
        result.sections.map((section) => section.title),
        containsAll(['Summary', 'Experience', 'Education', 'Skills']),
      );
      expect(result.quality, ResumeParseQuality.medium);
      expect(result.warnings, isEmpty);
    });

    test('repairs wrapped hyphenation and flags sparse scans', () {
      final result = ResumeTextParser.parse(
        'EXPERIENCE\nBuilt automa-\ntion tools.',
      );

      expect(result.cleanedText, contains('automation'));
      expect(result.quality, ResumeParseQuality.low);
      expect(result.warnings, isNotEmpty);
    });

    test('rebuilds edited sections as plain matching text', () {
      final text = ResumeTextParser.fromSections(const [
        ResumeParsedSection(title: 'Experience', content: 'Built a CRM.'),
        ResumeParsedSection(title: 'Skills', content: 'Dart, SQL'),
      ]);

      expect(text, 'EXPERIENCE\nBuilt a CRM.\n\nSKILLS\nDart, SQL');
    });
  });
}
