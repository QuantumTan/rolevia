import 'package:flutter/material.dart';

import '../design/colors.dart';
import '../design/typography.dart';

/// Text rendered with tabular monospace figures for counts, currency, dates, and ATS tokens.
class MonoText extends StatelessWidget {
  const MonoText(
    this.text, {
    super.key,
    this.style,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  final String text;
  final TextStyle? style;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final baseStyle = style ?? AppTypography.mono;

    return Text(
      text,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      style: baseStyle.copyWith(
        color: color ?? colors.labelPrimary,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
