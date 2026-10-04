import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'deterministic_ats_checker.dart';
import 'mobile_resume_ocr_service.dart';
import 'pdf_layout_reconstructor.dart';
import 'pii_sanitizer.dart';
import 'resume_text_parser.dart';

enum ResumeTextSource { textLayer, onDeviceOcr }

class ExtractedResume {
  const ExtractedResume({
    required this.sanitizedText,
    required this.report,
    required this.parse,
    required this.source,
    required this.pageCount,
    required this.complexColumns,
    required this.smallFonts,
    required this.marginText,
  });

  final String sanitizedText;
  final AtsReport report;
  final ResumeParseResult parse;
  final ResumeTextSource source;
  final int pageCount;
  final bool complexColumns;
  final bool smallFonts;
  final bool marginText;

  bool get usedOcr => source == ResumeTextSource.onDeviceOcr;

  ExtractedResume reviewed(String text) {
    final sanitized = PiiSanitizer.sanitize(text);
    final nextParse = ResumeTextParser.parse(sanitized);
    final updated = DeterministicAtsChecker.check(
      sanitized,
      pages: pageCount,
      complexColumns: complexColumns,
      smallFonts: smallFonts,
      marginText: marginText,
    );
    final checks = Map<String, bool>.from(updated.checks)
      ..['Email contact'] = report.checks['Email contact'] ?? false
      ..['Phone contact'] = report.checks['Phone contact'] ?? false;
    return ExtractedResume(
      sanitizedText: nextParse.cleanedText,
      report: AtsReport(checks, [
        for (final entry in checks.entries)
          if (!entry.value) 'Review: ${entry.key}.',
      ]),
      parse: nextParse,
      source: source,
      pageCount: pageCount,
      complexColumns: complexColumns,
      smallFonts: smallFonts,
      marginText: marginText,
    );
  }
}

class PdfExtractorService {
  Future<ExtractedResume> extract(Uint8List bytes) async {
    final textLayer = await compute(extractPdfText, bytes);
    if (!textLayer.parse.shouldTryOcr) return textLayer;

    if (!MobileResumeOcrService.isSupported) {
      if (textLayer.sanitizedText.trim().isEmpty) {
        throw const FormatException(
          'This PDF has no readable text layer. Open the app on Android or iOS to use on-device OCR, or export a searchable PDF.',
        );
      }
      return textLayer;
    }

    try {
      final ocr = await MobileResumeOcrService().extract(bytes);
      final candidate = _analyzeText(
        ocr.text,
        pages: ocr.pageCount,
        source: ResumeTextSource.onDeviceOcr,
      );
      final ocrIsBetter =
          candidate.sanitizedText.length >=
              textLayer.sanitizedText.length * 1.2 ||
          (candidate.parse.quality != ResumeParseQuality.low &&
              textLayer.parse.quality == ResumeParseQuality.low);
      if (ocrIsBetter) return candidate;
      if (textLayer.sanitizedText.trim().isNotEmpty) return textLayer;
      throw const FormatException(
        'On-device OCR could not find readable resume text.',
      );
    } catch (error) {
      if (textLayer.sanitizedText.trim().isNotEmpty) return textLayer;
      throw FormatException('On-device OCR could not read this PDF: $error');
    }
  }
}

ExtractedResume extractPdfText(Uint8List bytes) {
  if (bytes.length > 10 * 1024 * 1024) {
    throw const FormatException('PDF exceeds 10 MB.');
  }
  if (bytes.length < 5 || String.fromCharCodes(bytes.take(5)) != '%PDF-') {
    throw const FormatException('Invalid PDF signature.');
  }
  final document = PdfDocument(inputBytes: bytes);
  try {
    final extractor = PdfTextExtractor(document);
    final textLines = extractor.extractTextLines();
    final layout = PdfLayoutReconstructor.reconstruct([
      for (final line in textLines)
        PdfLayoutLine(
          page: line.pageIndex,
          text: line.text,
          left: line.bounds.left,
          top: line.bounds.top,
          width: line.bounds.width,
          height: line.bounds.height,
        ),
    ]);
    final fallback = extractor.extractText(layoutText: true);
    final reconstructed = layout.text.trim().isNotEmpty
        ? layout.text
        : fallback;
    final smallFonts = textLines.any(
      (line) => line.fontSize > 0 && line.fontSize < 8,
    );
    return _analyzeText(
      reconstructed,
      pages: document.pages.count,
      source: ResumeTextSource.textLayer,
      complexColumns: layout.detectedColumns,
      smallFonts: smallFonts,
      marginText: layout.removedRepeatedMargins,
    );
  } finally {
    document.dispose();
  }
}

ExtractedResume _analyzeText(
  String text, {
  required int pages,
  required ResumeTextSource source,
  bool complexColumns = false,
  bool smallFonts = false,
  bool marginText = false,
}) {
  final report = DeterministicAtsChecker.check(
    text,
    pages: pages,
    complexColumns: complexColumns,
    smallFonts: smallFonts,
    marginText: marginText,
  );
  final sanitized = PiiSanitizer.sanitize(text);
  final parse = ResumeTextParser.parse(sanitized);
  return ExtractedResume(
    sanitizedText: parse.cleanedText,
    report: report,
    parse: parse,
    source: source,
    pageCount: pages,
    complexColumns: complexColumns,
    smallFonts: smallFonts,
    marginText: marginText,
  );
}
