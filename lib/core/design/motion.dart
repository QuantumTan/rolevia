import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Spring-based and tactile motion definitions
class AppMotion {
  const AppMotion._();

  static bool hapticsEnabled = true;

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration standard = Duration(milliseconds: 240);
  static const Duration smooth = Duration(milliseconds: 320);
  static const Duration sheet = Duration(milliseconds: 380);

  static const Curve springCurve = Curves.easeOutCubic;
  static const Curve smoothCurve = Curves.fastOutSlowIn;

  static void selectionHaptic() {
    if (!hapticsEnabled) return;
    HapticFeedback.selectionClick();
  }

  static void lightHaptic() {
    if (!hapticsEnabled) return;
    HapticFeedback.lightImpact();
  }

  static void mediumHaptic() {
    if (!hapticsEnabled) return;
    HapticFeedback.mediumImpact();
  }

  static void errorHaptic() {
    if (!hapticsEnabled) return;
    HapticFeedback.heavyImpact();
  }

  static void successHaptic() {
    if (!hapticsEnabled) return;
    HapticFeedback.lightImpact();
  }
}
