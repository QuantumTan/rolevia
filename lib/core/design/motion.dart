import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Central motion system tokens and tactile feedback.
///
/// Rules:
/// - Animate transform and opacity, not layout.
/// - Stagger lists at 30 ms steps (cap at 8 items).
/// - Every animation has a reduce-motion variant (instant or simple fade).
/// - No animation over 700 ms; all animations interruptible.
class AppMotion {
  const AppMotion._();

  // Durations
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration quick = Duration(milliseconds: 180);
  static const Duration standard = Duration(milliseconds: 280);
  static const Duration emphasized = Duration(milliseconds: 420);
  static const Duration hero = Duration(milliseconds: 600);
  static const Duration shimmerLoop = Duration(milliseconds: 1200);
  static const Duration toastDuration = Duration(milliseconds: 2000);
  static const Duration staggerStep = Duration(milliseconds: 30);
  static const int staggerMaxItems = 8;

  // Curves
  static const Curve curveStandard = Curves.easeOutCubic;
  static const Curve curveEmphasized = Curves.easeOutQuart;
  static const Curve curveExit = Curves.easeInCubic;

  // Spring physics: mass 1, stiffness 380, damping 28
  static const SpringDescription spring = SpringDescription(
    mass: 1.0,
    stiffness: 380.0,
    damping: 28.0,
  );

  // Press feedback
  static const double pressScale = 0.98;

  // Backward-compatible duration aliases
  static const Duration fast = instant;
  static const Duration smooth = emphasized;
  static const Duration sheet = emphasized;
  static const Curve springCurve = curveStandard;
  static const Curve smoothCurve = curveEmphasized;

  /// User-controllable global toggle for haptics
  static bool hapticsEnabled = true;

  // Haptics Map (all behind hapticsEnabled toggle; never haptic on scroll)

  /// Segmented control and chip: selectionClick
  static void segmentedControlOrChip() {
    if (!hapticsEnabled) return;
    HapticFeedback.selectionClick();
  }

  /// Drag pickup: mediumImpact
  static void dragPickup() {
    if (!hapticsEnabled) return;
    HapticFeedback.mediumImpact();
  }

  /// Drop: lightImpact
  static void drop() {
    if (!hapticsEnabled) return;
    HapticFeedback.lightImpact();
  }

  /// Score settles: one lightImpact
  static void scoreSettles() {
    if (!hapticsEnabled) return;
    HapticFeedback.lightImpact();
  }

  /// Copy and save success: lightImpact
  static void copyAndSaveSuccess() {
    if (!hapticsEnabled) return;
    HapticFeedback.lightImpact();
  }

  /// Destructive confirm: heavyImpact once
  static void destructiveConfirm() {
    if (!hapticsEnabled) return;
    HapticFeedback.heavyImpact();
  }

  // Aliases for compatibility
  static void selectionHaptic() => segmentedControlOrChip();
  static void lightHaptic() => scoreSettles();
  static void mediumHaptic() => dragPickup();
  static void errorHaptic() => destructiveConfirm();
  static void successHaptic() => copyAndSaveSuccess();
}
