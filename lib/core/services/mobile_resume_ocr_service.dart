import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';

class ResumeOcrResult {
  const ResumeOcrResult({required this.text, required this.pageCount});

  final String text;
  final int pageCount;
}

class MobileResumeOcrService {
  static bool get isSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<ResumeOcrResult> extract(Uint8List bytes) async {
    if (!isSupported) {
      throw UnsupportedError('On-device OCR is available on Android and iOS.');
    }

    await pdfrxFlutterInitialize();
    final document = await PdfDocument.openData(
      bytes,
      sourceName: 'resume-ocr.pdf',
    );
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final temporaryDirectory = await getTemporaryDirectory();
    final pages = <String>[];
    final pageCount = document.pages.length;

    try {
      for (final page in document.pages) {
        final rendered = await page.render(
          fullWidth: page.width * 2,
          fullHeight: page.height * 2,
          backgroundColor: 0xffffffff,
        );
        if (rendered == null) continue;

        ui.Image? image;
        File? temporaryImage;
        try {
          image = await rendered.createImage(pixelSizeThreshold: 2600);
          final png = await image.toByteData(format: ui.ImageByteFormat.png);
          if (png == null) continue;
          temporaryImage = File(
            '${temporaryDirectory.path}${Platform.pathSeparator}'
            'rolevia-ocr-${DateTime.now().microsecondsSinceEpoch}-${page.pageNumber}.png',
          );
          await temporaryImage.writeAsBytes(
            png.buffer.asUint8List(png.offsetInBytes, png.lengthInBytes),
            flush: true,
          );
          final recognized = await recognizer.processImage(
            InputImage.fromFilePath(temporaryImage.path),
          );
          if (recognized.text.trim().isNotEmpty) {
            pages.add(recognized.text.trim());
          }
        } finally {
          image?.dispose();
          rendered.dispose();
          if (temporaryImage != null && await temporaryImage.exists()) {
            await temporaryImage.delete();
          }
        }
      }
    } finally {
      await recognizer.close();
      await document.dispose();
    }

    return ResumeOcrResult(text: pages.join('\n\n'), pageCount: pageCount);
  }
}
