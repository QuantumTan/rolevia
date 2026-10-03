import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'deterministic_ats_checker.dart';
import 'pii_sanitizer.dart';

class ExtractedResume {
  const ExtractedResume(this.sanitizedText, this.report);
  final String sanitizedText;
  final AtsReport report;
}

class PdfExtractorService {
  Future<ExtractedResume> extract(Uint8List bytes) => compute(extractPdfText, bytes);
}

ExtractedResume extractPdfText(Uint8List bytes) {
  if (bytes.length > 10 * 1024 * 1024) throw const FormatException('PDF exceeds 10 MB.');
  if (bytes.length < 5 || String.fromCharCodes(bytes.take(5)) != '%PDF-') {
    throw const FormatException('Invalid PDF signature.');
  }
  final document = PdfDocument(inputBytes: bytes);
  try {
    final extractor = PdfTextExtractor(document);
    final text = extractor.extractText();
    if (text.trim().isEmpty) throw const FormatException('This PDF has no text layer. Export a searchable PDF.');
    final lines = extractor.extractTextLines();
    final report = DeterministicAtsChecker.check(text, pages: document.pages.count,
      smallFonts: lines.any((line) => line.fontSize < 8),
      complexColumns: lines.any((line) => RegExp(r'\S {5,}\S').hasMatch(line.text)),
      marginText: lines.any((line) => line.bounds.top < 12));
    return ExtractedResume(PiiSanitizer.sanitize(text), report);
  } finally {
    document.dispose();
  }
}
