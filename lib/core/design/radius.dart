import 'package:flutter/widgets.dart';

/// Intentional radii tokens for consistent iOS 27 Liquid Glass and solid card surfaces
class AppRadius {
  const AppRadius._();

  static const double xs = 6.0;
  static const double sm = 10.0;
  static const double md = 14.0;
  static const double card = 16.0;
  static const double lg = 18.0;
  static const double xl = 24.0;
  static const double sheet = 28.0;
  static const double capsule = 999.0;
  static const double full = 999.0;

  static const BorderRadius xsRadius = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smRadius = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdRadius = BorderRadius.all(Radius.circular(md));
  static const BorderRadius cardRadius = BorderRadius.all(
    Radius.circular(card),
  );
  static const BorderRadius lgRadius = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlRadius = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius sheetRadius = BorderRadius.vertical(
    top: Radius.circular(sheet),
  );
  static const BorderRadius capsuleRadius = BorderRadius.all(
    Radius.circular(capsule),
  );
  static const BorderRadius fullRadius = BorderRadius.all(
    Radius.circular(full),
  );
}
