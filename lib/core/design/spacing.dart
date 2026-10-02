import 'package:flutter/widgets.dart';

/// Deliberate spacing scale strictly honoring 4 / 8 / 12 / 16 / 20 / 24 / 32 / 40 / 48
class AppSpacing {
  const AppSpacing._();

  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;
  static const double huge = 48.0;

  // Convenient standard insets
  static const EdgeInsets edgeInsetsScreen = EdgeInsets.fromLTRB(
    16,
    12,
    16,
    108,
  );
  static const EdgeInsets edgeInsetsCard = EdgeInsets.all(16);
  static const EdgeInsets edgeInsetsList = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 8,
  );
  static const EdgeInsets edgeInsetsModal = EdgeInsets.fromLTRB(20, 16, 20, 28);
}
