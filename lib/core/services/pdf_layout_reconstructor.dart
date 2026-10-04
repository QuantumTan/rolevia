class PdfLayoutLine {
  const PdfLayoutLine({
    required this.page,
    required this.text,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final int page;
  final String text;
  final double left;
  final double top;
  final double width;
  final double height;

  double get right => left + width;
  double get bottom => top + height;
}

class PdfLayoutResult {
  const PdfLayoutResult({
    required this.text,
    required this.detectedColumns,
    required this.removedRepeatedMargins,
  });

  final String text;
  final bool detectedColumns;
  final bool removedRepeatedMargins;
}

abstract final class PdfLayoutReconstructor {
  static PdfLayoutResult reconstruct(List<PdfLayoutLine> source) {
    final lines = source
        .map(
          (line) => PdfLayoutLine(
            page: line.page,
            text: _normalizeLine(line.text),
            left: line.left,
            top: line.top,
            width: line.width,
            height: line.height,
          ),
        )
        .where((line) => line.text.isNotEmpty)
        .toList();
    if (lines.isEmpty) {
      return const PdfLayoutResult(
        text: '',
        detectedColumns: false,
        removedRepeatedMargins: false,
      );
    }

    final byPage = <int, List<PdfLayoutLine>>{};
    for (final line in lines) {
      byPage.putIfAbsent(line.page, () => []).add(line);
    }
    final repeatedMargins = _repeatedMarginKeys(byPage);
    var detectedColumns = false;
    final pageTexts = <String>[];

    for (final page in byPage.keys.toList()..sort()) {
      final pageLines = byPage[page]!
          .where((line) => !repeatedMargins.contains(_marginKey(line.text)))
          .toList();
      final ordered = _orderPage(pageLines);
      detectedColumns = detectedColumns || ordered.detectedColumns;
      final pageText = _dehyphenate(ordered.lines.join('\n')).trim();
      if (pageText.isNotEmpty) pageTexts.add(pageText);
    }

    return PdfLayoutResult(
      text: pageTexts.join('\n\n'),
      detectedColumns: detectedColumns,
      removedRepeatedMargins: repeatedMargins.isNotEmpty,
    );
  }

  static Set<String> _repeatedMarginKeys(Map<int, List<PdfLayoutLine>> byPage) {
    if (byPage.length < 2) return const {};
    final occurrences = <String, Set<int>>{};
    for (final entry in byPage.entries) {
      if (entry.value.isEmpty) continue;
      final sorted = [...entry.value]..sort((a, b) => a.top.compareTo(b.top));
      final minTop = sorted.first.top;
      final maxBottom = sorted
          .map((line) => line.bottom)
          .reduce((a, b) => a > b ? a : b);
      for (final line in sorted) {
        final nearTop = line.top <= minTop + 18;
        final nearBottom = line.bottom >= maxBottom - 18;
        final key = _marginKey(line.text);
        if ((nearTop || nearBottom) && key.length >= 3) {
          occurrences.putIfAbsent(key, () => {}).add(entry.key);
        }
      }
    }
    return {
      for (final entry in occurrences.entries)
        if (entry.value.length >= 2) entry.key,
    };
  }

  static ({List<String> lines, bool detectedColumns}) _orderPage(
    List<PdfLayoutLine> lines,
  ) {
    if (lines.isEmpty) return (lines: const [], detectedColumns: false);
    final minLeft = lines
        .map((line) => line.left)
        .reduce((a, b) => a < b ? a : b);
    final maxRight = lines
        .map((line) => line.right)
        .reduce((a, b) => a > b ? a : b);
    final pageWidth = maxRight - minLeft;
    final midpoint = minLeft + pageWidth / 2;
    final spanning = lines
        .where(
          (line) => line.left < midpoint - 12 && line.right > midpoint + 12,
        )
        .toList();
    final left = lines
        .where((line) => !spanning.contains(line) && line.left < midpoint)
        .toList();
    final right = lines
        .where((line) => !spanning.contains(line) && line.left >= midpoint)
        .toList();
    final isTwoColumn =
        pageWidth > 180 && left.length >= 4 && right.length >= 4;

    if (!isTwoColumn) {
      return (lines: _groupRows(lines), detectedColumns: false);
    }

    spanning.sort((a, b) => a.top.compareTo(b.top));
    final output = <String>[];
    var bandTop = double.negativeInfinity;
    for (final divider in spanning) {
      output.addAll(
        _columnBand(left, right, bandTop: bandTop, bandBottom: divider.top),
      );
      output.add(divider.text);
      bandTop = divider.bottom;
    }
    output.addAll(
      _columnBand(left, right, bandTop: bandTop, bandBottom: double.infinity),
    );
    return (lines: output, detectedColumns: true);
  }

  static List<String> _columnBand(
    List<PdfLayoutLine> left,
    List<PdfLayoutLine> right, {
    required double bandTop,
    required double bandBottom,
  }) {
    final leftBand = left
        .where((line) => line.top >= bandTop && line.top < bandBottom)
        .toList();
    final rightBand = right
        .where((line) => line.top >= bandTop && line.top < bandBottom)
        .toList();
    return [..._groupRows(leftBand), ..._groupRows(rightBand)];
  }

  static List<String> _groupRows(List<PdfLayoutLine> lines) {
    final sorted = [...lines]
      ..sort((a, b) {
        final vertical = a.top.compareTo(b.top);
        return vertical == 0 ? a.left.compareTo(b.left) : vertical;
      });
    final rows = <List<PdfLayoutLine>>[];
    for (final line in sorted) {
      if (rows.isEmpty) {
        rows.add([line]);
        continue;
      }
      final row = rows.last;
      final tolerance = (line.height < 4 ? 4.0 : line.height * 0.45).clamp(
        3.0,
        8.0,
      );
      if ((row.first.top - line.top).abs() <= tolerance) {
        row.add(line);
      } else {
        rows.add([line]);
      }
    }
    return rows.map((row) {
      row.sort((a, b) => a.left.compareTo(b.left));
      if (row.length == 1) return row.first.text;
      return row.map((line) => line.text).join(' | ');
    }).toList();
  }

  static String _normalizeLine(String text) => text
      .replaceAll('\u00a0', ' ')
      .replaceAll(RegExp(r'^[•●▪◦‣]\s*'), '• ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  static String _marginKey(String text) => text
      .toLowerCase()
      .replaceAll(RegExp(r'\b\d+\b'), '#')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  static String _dehyphenate(String text) => text.replaceAllMapped(
    RegExp(r'([A-Za-z]{3,})-\n([a-z][A-Za-z]*)'),
    (match) => '${match.group(1)}${match.group(2)}',
  );
}
