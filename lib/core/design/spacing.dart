import 'package:flutter/widgets.dart';

/// Deliberate spacing scale strictly honoring 4, 8, 12, 16, 24, 32, 48.
/// Screen margin 16.
class AppSpacing {
  const AppSpacing._();

  static const double s4 = 4.0;
  static const double s8 = 8.0;
  static const double s12 = 12.0;
  static const double s16 = 16.0;
  static const double s24 = 24.0;
  static const double s32 = 32.0;
  static const double s48 = 48.0;

  static const double screenMargin = 16.0;

  // Backward-compatible semantic aliases
  static const double xxs = s4;
  static const double xs = s8;
  static const double sm = s12;
  static const double md = s16;
  static const double lg = 20.0;
  static const double xl = s24;
  static const double xxl = s32;
  static const double xxxl = 40.0;
  static const double huge = s48;

  // Convenient standard insets
  static const EdgeInsets edgeInsetsScreen = EdgeInsets.symmetric(
    horizontal: screenMargin,
    vertical: s12,
  );
  static const EdgeInsets edgeInsetsCard = EdgeInsets.all(s16);
  static const EdgeInsets edgeInsetsList = EdgeInsets.symmetric(
    horizontal: screenMargin,
    vertical: s8,
  );
  static const EdgeInsets edgeInsetsModal = EdgeInsets.fromLTRB(s16, s12, s16, s24);
}
