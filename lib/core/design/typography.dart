import 'package:flutter/material.dart';

import 'colors.dart';

/// Semantic typography following Apple San Francisco hierarchy principles
/// using platform-native font rendering without bundling restricted files.
class AppTypography {
  const AppTypography._();

  static const String _fontFamily = 'Inter';

  static TextStyle get largeTitle => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
    height: 1.2,
  );

  static TextStyle get title1 => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    height: 1.25,
  );

  static TextStyle get title2 => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    height: 1.28,
  );

  static TextStyle get title3 => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static TextStyle get headline => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
    height: 1.35,
  );

  static TextStyle get body => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.4,
    height: 1.4,
  );

  static TextStyle get callout => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.3,
    height: 1.35,
  );

  static TextStyle get subheadline => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.2,
    height: 1.35,
  );

  static TextStyle get footnote => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.1,
    height: 1.35,
  );

  static TextStyle get caption => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.3,
  );

  /// Builds a complete Material TextTheme mapped directly to semantic mobile hierarchy.
  static TextTheme createTextTheme(Color defaultTextColor) {
    return TextTheme(
      displayLarge: largeTitle.copyWith(color: defaultTextColor),
      displayMedium: title1.copyWith(color: defaultTextColor),
      displaySmall: title2.copyWith(color: defaultTextColor),
      headlineMedium: title3.copyWith(color: defaultTextColor),
      headlineSmall: headline.copyWith(color: defaultTextColor),
      titleLarge: headline.copyWith(color: defaultTextColor),
      titleMedium: headline.copyWith(color: defaultTextColor),
      titleSmall: subheadline.copyWith(
        fontWeight: FontWeight.w600,
        color: defaultTextColor,
      ),
      bodyLarge: body.copyWith(color: defaultTextColor),
      bodyMedium: callout.copyWith(color: defaultTextColor),
      bodySmall: footnote.copyWith(color: defaultTextColor),
      labelLarge: subheadline.copyWith(
        fontWeight: FontWeight.w600,
        color: defaultTextColor,
      ),
      labelMedium: footnote.copyWith(
        fontWeight: FontWeight.w500,
        color: defaultTextColor,
      ),
      labelSmall: caption.copyWith(color: defaultTextColor),
    );
  }
}

extension AppTypographyContext on BuildContext {
  AppColors get _colors => AppColors.of(this);

  TextStyle get largeTitle =>
      AppTypography.largeTitle.copyWith(color: _colors.labelPrimary);
  TextStyle get title1 =>
      AppTypography.title1.copyWith(color: _colors.labelPrimary);
  TextStyle get title2 =>
      AppTypography.title2.copyWith(color: _colors.labelPrimary);
  TextStyle get title3 =>
      AppTypography.title3.copyWith(color: _colors.labelPrimary);
  TextStyle get headline =>
      AppTypography.headline.copyWith(color: _colors.labelPrimary);
  TextStyle get body =>
      AppTypography.body.copyWith(color: _colors.labelPrimary);
  TextStyle get callout =>
      AppTypography.callout.copyWith(color: _colors.labelPrimary);
  TextStyle get subheadline =>
      AppTypography.subheadline.copyWith(color: _colors.labelSecondary);
  TextStyle get footnote =>
      AppTypography.footnote.copyWith(color: _colors.labelTertiary);
  TextStyle get caption =>
      AppTypography.caption.copyWith(color: _colors.labelTertiary);
}
