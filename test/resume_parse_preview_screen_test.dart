import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rolevia/core/services/deterministic_ats_checker.dart';
import 'package:rolevia/core/services/pdf_extractor_service.dart';
import 'package:rolevia/core/services/resume_text_parser.dart';
import 'package:rolevia/features/resume_parse_preview_screen.dart';

void main() {
  testWidgets('shows extraction source, warnings, and editable sections', (
    tester,
  ) async {
    const text = '''
EXPERIENCE
Operations Analyst, Northstar Services
2021 to Present
Built weekly dashboards and improved reporting quality.

SKILLS
SQL, Excel, Power BI
''';
    final parse = ResumeTextParser.parse(text);
    final extracted = ExtractedResume(
      sanitizedText: parse.cleanedText,
      report: DeterministicAtsChecker.check(text, pages: 1),
      parse: parse,
      source: ResumeTextSource.textLayer,
      pageCount: 1,
      complexColumns: false,
      smallFonts: false,
      marginText: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ResumeParsePreviewScreen(
          fileName: 'resume.pdf',
          extracted: extracted,
        ),
      ),
    );

    expect(find.text('What we read from your resume'), findsOneWidget);
    expect(find.textContaining('text layer in resume.pdf'), findsOneWidget);
    expect(
      find.byType(TextField, skipOffstage: false),
      findsNWidgets(parse.sections.length),
    );
    expect(find.text('Use this text'), findsOneWidget);
  });
}
