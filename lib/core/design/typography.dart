import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Semantic typography following "Engineered Editorial Utility":
/// iOS: platform system font (SF Pro)
/// Android/other: Inter bundled in assets/fonts
/// Data: Tabular figures for counts, percentages, currency, dates, diffs
/// Strict 5 canonical roles: Display, Title, Headline, Body, Caption.
class AppTypography {
  const AppTypography._();

  static String? get platformFontFamily =>
      defaultTargetPlatform == TargetPlatform.iOS ? null : 'Inter';

  /// Display 28/600/-0.5
  static TextStyle get display => TextStyle(
        fontFamily: platformFontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        height: 1.25,
      );

  /// Title 20/600/-0.3
  static TextStyle get title => TextStyle(
        fontFamily: platformFontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        height: 1.3,
      );

  /// Headline 17/600
  static TextStyle get headline => TextStyle(
        fontFamily: platformFontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.0,
        height: 1.35,
      );

  /// Body 15/400/1.45
  static TextStyle get body => TextStyle(
        fontFamily: platformFontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.2,
        height: 1.45,
      );

  /// Caption 12/500/+0.2
  static TextStyle get caption => TextStyle(
        fontFamily: platformFontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        height: 1.35,
      );

  /// Data typography with tabular numerals for percentages, counts, currency, dates, diffs
  static TextStyle get data => TextStyle(
        fontFamily: platformFontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        fontFeatures: const [FontFeature.tabularFigures()],
        height: 1.4,
      );

  /// Technical / Monospace for code, diffs, ATS tokens
  static TextStyle get mono => const TextStyle(
        fontFamily: 'monospace',
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.2,
        fontFeatures: [FontFeature.tabularFigures()],
        height: 1.4,
      );

  static TextStyle get monoData => mono;
  static TextStyle get monoBadge =>
      mono.copyWith(fontSize: 11, fontWeight: FontWeight.w600);
  static TextStyle get monoScore =>
      mono.copyWith(fontSize: 18, fontWeight: FontWeight.w700);

  // Backward-compatible semantic getters mapping to canonical roles
  static TextStyle get largeTitle => display;
  static TextStyle get title1 => display;
  static TextStyle get title2 => title;
  static TextStyle get title3 => title;
  static TextStyle get callout => body;
  static TextStyle get subheadline => body;
  static TextStyle get footnote => caption;

  /// Creates a Material 3 TextTheme mapped cleanly to our tokens
  static TextTheme createTextTheme(Color defaultColor) {
    return TextTheme(
      displayLarge: display.copyWith(color: defaultColor),
      displayMedium: display.copyWith(color: defaultColor),
      displaySmall: display.copyWith(color: defaultColor),
      headlineLarge: display.copyWith(color: defaultColor),
      headlineMedium: title.copyWith(color: defaultColor),
      headlineSmall: title.copyWith(color: defaultColor),
      titleLarge: title.copyWith(color: defaultColor),
      titleMedium: headline.copyWith(color: defaultColor),
      titleSmall: headline.copyWith(color: defaultColor),
      bodyLarge: body.copyWith(color: defaultColor),
      bodyMedium: body.copyWith(color: defaultColor),
      bodySmall: caption.copyWith(color: defaultColor),
      labelLarge: headline.copyWith(color: defaultColor),
      labelMedium: caption.copyWith(color: defaultColor),
      labelSmall: caption.copyWith(color: defaultColor),
    );
  }
}
