import 'package:flutter_test/flutter_test.dart';
import 'package:rolevia/core/services/pdf_layout_reconstructor.dart';

PdfLayoutLine line(
  int page,
  String text,
  double left,
  double top, {
  double width = 120,
  double height = 12,
}) => PdfLayoutLine(
  page: page,
  text: text,
  left: left,
  top: top,
  width: width,
  height: height,
);

void main() {
  group('PdfLayoutReconstructor', () {
    test('removes repeated page margins and preserves page content', () {
      final result = PdfLayoutReconstructor.reconstruct([
        line(0, 'JANE SAMPLE', 20, 8),
        line(0, 'EXPERIENCE', 20, 60),
        line(0, 'Built reporting tools', 20, 80),
        line(0, 'Page 1', 250, 760),
        line(1, 'JANE SAMPLE', 20, 8),
        line(1, 'EDUCATION', 20, 60),
        line(1, 'State University', 20, 80),
        line(1, 'Page 2', 250, 760),
      ]);

      expect(result.removedRepeatedMargins, isTrue);
      expect(result.text, isNot(contains('JANE SAMPLE')));
      expect(result.text, isNot(contains('Page')));
      expect(result.text, contains('Built reporting tools'));
      expect(result.text, contains('State University'));
    });

    test('reads a two-column layout one column at a time', () {
      final result = PdfLayoutReconstructor.reconstruct([
        line(0, 'RESUME', 20, 10, width: 360),
        line(0, 'SKILLS', 20, 60),
        line(0, 'SQL', 20, 80),
        line(0, 'Excel', 20, 100),
        line(0, 'Power BI', 20, 120),
        line(0, 'EXPERIENCE', 240, 60),
        line(0, 'Analyst', 240, 80),
        line(0, 'Northstar', 240, 100),
        line(0, '2021 to 2025', 240, 120),
      ]);

      expect(result.detectedColumns, isTrue);
      expect(
        result.text.indexOf('Power BI'),
        lessThan(result.text.indexOf('EXPERIENCE')),
      );
    });

    test('joins same-row table cells with a clear separator', () {
      final result = PdfLayoutReconstructor.reconstruct([
        line(0, 'Certification', 20, 40, width: 80),
        line(0, 'Year', 140, 40, width: 40),
      ]);

      expect(result.text, 'Certification | Year');
    });
  });
}
