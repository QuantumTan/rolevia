import 'package:flutter/widgets.dart';

/// Intentional shape and radii tokens:
/// Card radius 16, chips and buttons capsule, avatar tile radius 10, sheets 28 top radius with a 36x5 grabber.
/// Hairline borders (0.5 logical px).
class AppRadius {
  const AppRadius._();

  static const double card = 16.0;
  static const double avatarTile = 10.0;
  static const double sheet = 28.0;
  static const double capsule = 999.0;
  static const double button = capsule;
  static const double chip = capsule;
  static const double grabberWidth = 36.0;
  static const double grabberHeight = 5.0;
  static const double hairline = 0.5;

  // Granular radius values
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double pill = capsule;
  static const double full = capsule;

  // BorderRadius shapes
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(card));
  static const BorderRadius avatarTileRadius = BorderRadius.all(Radius.circular(avatarTile));
  static const BorderRadius sheetRadius = BorderRadius.vertical(top: Radius.circular(sheet));
  static const BorderRadius capsuleRadius = BorderRadius.all(Radius.circular(capsule));
  static const BorderRadius buttonRadius = capsuleRadius;
  static const BorderRadius chipRadius = capsuleRadius;
  static const BorderRadius grabberRadius = BorderRadius.all(Radius.circular(grabberHeight / 2));

  static const BorderRadius xsRadius = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smRadius = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdRadius = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgRadius = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlRadius = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius fullRadius = capsuleRadius;
}
